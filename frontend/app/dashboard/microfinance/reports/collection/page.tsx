'use client';

import axios from 'axios';
import { useEffect, useMemo, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

type LoanRow = {
  id: number;
  loan_code?: string | null;
  customer_no?: string | null;
  customer_name?: string | null;
  field_officer?: string | null;
  loan_amount?: number | string | null;
  net_disbursed_amount?: number | string | null;
  loan_balance?: number | string | null;
  installment_amount?: number | string | null;
  terms_count?: number | string | null;
  refund_option?: 'day' | 'week' | 'month' | string | null;
  loan_end_date?: string | null;
  due_date?: string | null;
  next_payment_date?: string | null;
  penalty_rate?: number | string | null;
  penalty_grace_days?: number | string | null;
};

type CollectionRow = {
  id: number;
  mf_loan_request_id: number | string;
  collection_date?: string | null;
  created_at?: string | null;
  collected_amount?: number | string;
  capital_amount?: number | string;
  interest_amount?: number | string;
  penalty_amount?: number | string;
  payment_type?: string | null;
  payment_reference?: string | null;
  loan_request?: {
    id?: number | string;
    loan_code?: string | null;
    customer_no?: string | null;
    customer_name?: string | null;
    field_officer?: string | null;
    loan_amount?: number | string | null;
    net_disbursed_amount?: number | string | null;
    loan_balance?: number | string | null;
  } | null;
};

type ReportRow = {
  id: number;
  loanRequestId: number;
  date: string;
  loanCode: string;
  customerNo: string;
  customerName: string;
  fieldOfficer: string;
  loanAmount: number;
  investmentAmount: number;
  collected: number;
  capital: number;
  interest: number;
  penalty: number;
  paymentType: string;
  reference: string;
};

const API_BASE = 'http://localhost:8000/api';

const parseDateOnlyParts = (value?: string | null) => {
  const raw = String(value || '').trim();
  if (!raw) return null;

  const datePart = raw.includes('T') ? raw.split('T')[0] : raw.slice(0, 10);
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(datePart);
  if (!match) return null;

  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  if (!Number.isFinite(year) || !Number.isFinite(month) || !Number.isFinite(day)) return null;

  return { year, month, day };
};

const parseDateOnlyToUtc = (value?: string | null) => {
  const parts = parseDateOnlyParts(value);
  if (!parts) return null;
  return new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
};

const shiftDateByRefundOptionUtc = (date: Date, refundOption: string, steps = 1) => {
  const shifted = new Date(date.getTime());
  const normalizedOption = String(refundOption || 'month').toLowerCase();

  if (normalizedOption === 'day') {
    shifted.setUTCDate(shifted.getUTCDate() + steps);
    return shifted;
  }

  if (normalizedOption === 'week') {
    shifted.setUTCDate(shifted.getUTCDate() + steps * 7);
    return shifted;
  }

  shifted.setUTCMonth(shifted.getUTCMonth() + steps);
  return shifted;
};

const resolveFirstDueDateFromLoan = (loan: LoanRow) => {
  const refundOption = String(loan.refund_option || 'month');
  const termCount = Math.max(Number(loan.terms_count || 1), 1);

  const loanEndDate = parseDateOnlyToUtc(loan.loan_end_date);
  if (loanEndDate) {
    if (termCount <= 1) return loanEndDate;
    return shiftDateByRefundOptionUtc(loanEndDate, refundOption, 0 - (termCount - 1));
  }

  const nextPaymentDate = parseDateOnlyToUtc(loan.next_payment_date);
  if (nextPaymentDate) return nextPaymentDate;

  return parseDateOnlyToUtc(loan.due_date);
};

const roundMoney = (value: number) => Math.round(value * 100) / 100;

const buildRecalculatedPenaltyMap = (loans: LoanRow[], collections: CollectionRow[]) => {
  const loanById = new Map<number, LoanRow>();
  loans.forEach((loan) => {
    loanById.set(Number(loan.id || 0), loan);
  });

  const groupedCollections = new Map<number, CollectionRow[]>();
  collections.forEach((row) => {
    const loanId = Number(row.mf_loan_request_id || 0);
    if (!loanId) return;

    const existing = groupedCollections.get(loanId) || [];
    existing.push(row);
    groupedCollections.set(loanId, existing);
  });

  const penaltyByCollectionId = new Map<number, number>();
  const msPerDay = 1000 * 60 * 60 * 24;

  groupedCollections.forEach((loanCollections, loanId) => {
    const loan = loanById.get(loanId);
    if (!loan) return;

    const installmentAmount = Number(loan.installment_amount || 0);
    const penaltyRate = Number(loan.penalty_rate || 0);
    const graceDays = Math.max(Number(loan.penalty_grace_days ?? 2), 0);
    const refundOption = String(loan.refund_option || 'month');
    const loanEndDate = parseDateOnlyToUtc(loan.loan_end_date);

    if (installmentAmount <= 0) return;

    const initialDueCursor = resolveFirstDueDateFromLoan(loan);
    if (!initialDueCursor) return;
    let dueCursor = initialDueCursor;

    let arrearsBalance = 0;

    const sortedLoanCollections = [...loanCollections].sort((a, b) => {
      const aDate = parseDateOnlyToUtc(a.collection_date || a.created_at || '')?.getTime() || 0;
      const bDate = parseDateOnlyToUtc(b.collection_date || b.created_at || '')?.getTime() || 0;
      if (aDate === bDate) return Number(a.id || 0) - Number(b.id || 0);
      return aDate - bDate;
    });

    sortedLoanCollections.forEach((row) => {
      const rowId = Number(row.id || 0);
      const collectionDate = parseDateOnlyToUtc(row.collection_date || row.created_at || '');
      if (!rowId || !collectionDate) return;

      const dueDateForPenalty = new Date(dueCursor.getTime());
      let accrualCapDate = collectionDate;
      if (loanEndDate && loanEndDate.getTime() < accrualCapDate.getTime()) {
        accrualCapDate = loanEndDate;
      }

      let guard = 0;
      while (dueCursor.getTime() <= accrualCapDate.getTime()) {
        arrearsBalance += installmentAmount;
        dueCursor = shiftDateByRefundOptionUtc(dueCursor, refundOption, 1);
        guard += 1;
        if (guard > 5000) break;
      }

      const arrearsOutstandingBefore = Math.max(arrearsBalance, 0);
      const dayDiff = Math.floor((collectionDate.getTime() - dueDateForPenalty.getTime()) / msPerDay);
      const lateDays = dayDiff > graceDays ? dayDiff - graceDays : 0;
      const penaltyAssessed = lateDays > 0 && penaltyRate > 0 ? (arrearsOutstandingBefore * penaltyRate) / 100 : 0;
      const collectedAmount = Math.max(Number(row.collected_amount || 0), 0);
      const penaltyAmount = Math.min(collectedAmount, Math.max(penaltyAssessed, 0));

      penaltyByCollectionId.set(rowId, roundMoney(penaltyAmount));

      const amountAfterPenalty = Math.max(collectedAmount - penaltyAmount, 0);
      arrearsBalance = roundMoney(arrearsBalance - amountAfterPenalty);
    });
  });

  return penaltyByCollectionId;
};

export default function CollectionReportPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [token, setToken] = useState('');
  const [loading, setLoading] = useState(true);
  const [rows, setRows] = useState<ReportRow[]>([]);
  const [fromDate, setFromDate] = useState('');
  const [toDate, setToDate] = useState('');
  const [pageSize, setPageSize] = useState(10);
  const [currentPage, setCurrentPage] = useState(1);

  const branchId = Number(searchParams.get('branch_id') || 0) || undefined;

  const handleBack = () => router.back();

  useEffect(() => {
    const storedToken = localStorage.getItem('token');
    if (!storedToken) {
      router.push('/');
      return;
    }

    setToken(storedToken);
  }, [router]);

  useEffect(() => {
    if (!token) return;

    const loadReport = async () => {
      setLoading(true);
      try {
        const [loanRes, collectionRes] = await Promise.all([
          axios.get(`${API_BASE}/microfinance/loan-requests`, {
            headers: {
              Authorization: `Bearer ${token}`,
              Accept: 'application/json',
            },
            params: {
              branch_id: branchId,
            },
          }),
          axios.get(`${API_BASE}/microfinance/collections`, {
            headers: {
              Authorization: `Bearer ${token}`,
              Accept: 'application/json',
            },
            params: {
              branch_id: branchId,
            },
          }),
        ]);

        const loans: LoanRow[] = Array.isArray(loanRes.data) ? loanRes.data : [];
        const collections: CollectionRow[] = Array.isArray(collectionRes.data) ? collectionRes.data : [];
        const recalculatedPenaltyByCollectionId = buildRecalculatedPenaltyMap(loans, collections);

        const loanMap = new Map<number, LoanRow>();
        loans.forEach((loan) => {
          loanMap.set(Number(loan.id), loan);
        });

        const mapped: ReportRow[] = collections
          .map((collection) => {
            const loanId = Number(collection.mf_loan_request_id || 0);
            const loan = loanMap.get(loanId);
            const relationLoan = collection.loan_request || null;
            const issuedAmount = Number(
              loan?.net_disbursed_amount ??
              loan?.loan_amount ??
              relationLoan?.net_disbursed_amount ??
              relationLoan?.loan_amount ??
              0
            );
            const loanBalance = Number(loan?.loan_balance ?? relationLoan?.loan_balance ?? Number.NaN);
            const normalizedInvestment = Number.isFinite(loanBalance)
              ? Math.max(loanBalance, 0)
              : Number.isFinite(issuedAmount)
                ? Math.max(issuedAmount, 0)
                : 0;
            const collectionId = Number(collection.id || 0);
            const storedPenalty = Number(collection.penalty_amount || 0);
            const recalculatedPenalty = recalculatedPenaltyByCollectionId.get(collectionId);

            return {
              id: collectionId,
              loanRequestId: loanId,
              date: String(collection.collection_date || collection.created_at || ''),
              loanCode: String(loan?.loan_code || relationLoan?.loan_code || `LR-${loanId || 0}`),
              customerNo: String(loan?.customer_no || relationLoan?.customer_no || '-'),
              customerName: String(loan?.customer_name || relationLoan?.customer_name || '-'),
              fieldOfficer: String(loan?.field_officer || relationLoan?.field_officer || 'Unassigned'),
              loanAmount: Number.isFinite(issuedAmount) ? issuedAmount : 0,
              investmentAmount: normalizedInvestment,
              collected: Number(collection.collected_amount || 0),
              capital: Number(collection.capital_amount || 0),
              interest: Number(collection.interest_amount || 0),
              penalty: typeof recalculatedPenalty === 'number' ? recalculatedPenalty : storedPenalty,
              paymentType: String(collection.payment_type || '-').replace('_', ' '),
              reference: String(collection.payment_reference || '-'),
            };
          })
          .sort((a, b) => {
            const aTime = new Date(a.date).getTime();
            const bTime = new Date(b.date).getTime();
            return (Number.isNaN(bTime) ? 0 : bTime) - (Number.isNaN(aTime) ? 0 : aTime);
          });

        setRows(mapped);
      } catch {
        setRows([]);
      } finally {
        setLoading(false);
      }
    };

    loadReport();
  }, [token, branchId]);

  const filteredRows = useMemo(() => {
    const from = fromDate ? new Date(`${fromDate}T00:00:00`) : null;
    const to = toDate ? new Date(`${toDate}T23:59:59`) : null;

    return rows.filter((row) => {
      const rowDate = row.date ? new Date(row.date) : null;

      if (from && rowDate && !Number.isNaN(rowDate.getTime()) && rowDate < from) {
        return false;
      }

      if (to && rowDate && !Number.isNaN(rowDate.getTime()) && rowDate > to) {
        return false;
      }

      return true;
    });
  }, [rows, fromDate, toDate]);

  const summary = useMemo(() => {
    let totalCollected = 0;
    let totalCapital = 0;
    let totalInterest = 0;
    let totalPenalty = 0;
    let totalInvestment = 0;

    const today = new Date().toISOString().slice(0, 10);
    let todayCollected = 0;

    const officers = new Set<string>();
    const investmentByLoan = new Map<number, number>();

    filteredRows.forEach((row) => {
      totalCollected += row.collected;
      totalCapital += row.capital;
      totalInterest += row.interest;
      totalPenalty += row.penalty;

      if (String(row.date).slice(0, 10) === today) {
        todayCollected += row.collected;
      }

      if (row.fieldOfficer && row.fieldOfficer !== 'Unassigned') {
        officers.add(row.fieldOfficer);
      }

      if (row.loanRequestId > 0 && !investmentByLoan.has(row.loanRequestId)) {
        investmentByLoan.set(row.loanRequestId, Number(row.investmentAmount || 0));
      }
    });

    investmentByLoan.forEach((amount) => {
      totalInvestment += amount;
    });

    return {
      totalCollected,
      totalInvestment,
      totalCapital,
      totalInterest,
      totalPenalty,
      todayCollected,
      transactionCount: filteredRows.length,
      officerCount: officers.size,
    };
  }, [filteredRows]);

  const totalPages = Math.max(1, Math.ceil(filteredRows.length / pageSize));

  const pagedRows = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return filteredRows.slice(start, start + pageSize);
  }, [filteredRows, currentPage, pageSize]);

  useEffect(() => {
    setCurrentPage(1);
  }, [fromDate, toDate, pageSize]);

  useEffect(() => {
    if (currentPage > totalPages) {
      setCurrentPage(totalPages);
    }
  }, [currentPage, totalPages]);

  const formatDateTime = (value: string) => {
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) {
      return value || '-';
    }

    return new Intl.DateTimeFormat('en-LK', {
      year: 'numeric',
      month: 'short',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false,
    }).format(parsed);
  };

  const formatMoney = (value: number) => Number(value || 0).toFixed(2);

  const getReportFileDate = () => new Date().toISOString().slice(0, 10);

  const handleDownloadCsv = () => {
    const headers = [
      'Date & Time',
      'Loan Code',
      'Customer No',
      'Customer',
      'Field Officer',
      'Loan Amount',
      'Payment Type',
      'Reference',
      'Collected',
      'Capital',
      'Interest',
      'Penalty',
    ];

    const escapeCsv = (value: string | number) => {
      const text = String(value ?? '');
      if (text.includes(',') || text.includes('"') || text.includes('\n')) {
        return `"${text.replace(/"/g, '""')}"`;
      }
      return text;
    };

    const body = filteredRows.map((row) => [
      formatDateTime(row.date),
      row.loanCode,
      row.customerNo,
      row.customerName,
      row.fieldOfficer,
      formatMoney(row.loanAmount),
      row.paymentType,
      row.reference,
      formatMoney(row.collected),
      formatMoney(row.capital),
      formatMoney(row.interest),
      formatMoney(row.penalty),
    ]);

    const csv = [headers, ...body].map((line) => line.map(escapeCsv).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `collection-report-${getReportFileDate()}.csv`;
    link.click();
    URL.revokeObjectURL(link.href);
  };

  const handleDownloadPdf = () => {
    const doc = new jsPDF({ orientation: 'landscape', unit: 'pt', format: 'a4' });
    const generatedAt = new Intl.DateTimeFormat('en-LK', {
      year: 'numeric',
      month: 'short',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false,
    }).format(new Date());

    const dateFilterText =
      fromDate || toDate
        ? `Range: ${fromDate || 'Start'} to ${toDate || 'End'}`
        : 'Range: All Dates';

    doc.setFontSize(16);
    doc.text('Collection Report', 40, 40);
    doc.setFontSize(10);
    doc.text(`${dateFilterText} | Generated: ${generatedAt}`, 40, 58);

    autoTable(doc, {
      startY: 72,
      head: [[
        'Date & Time',
        'Loan Code',
        'Customer No',
        'Customer',
        'Field Officer',
        'Loan Amount',
        'Payment Type',
        'Reference',
        'Collected',
        'Capital',
        'Interest',
        'Penalty',
      ]],
      body: filteredRows.map((row) => [
        formatDateTime(row.date),
        row.loanCode,
        row.customerNo,
        row.customerName,
        row.fieldOfficer,
        formatMoney(row.loanAmount),
        row.paymentType,
        row.reference,
        formatMoney(row.collected),
        formatMoney(row.capital),
        formatMoney(row.interest),
        formatMoney(row.penalty),
      ]),
      styles: {
        fontSize: 8,
        cellPadding: 4,
      },
      headStyles: {
        fillColor: [8, 145, 178],
        textColor: [255, 255, 255],
      },
      alternateRowStyles: {
        fillColor: [241, 250, 252],
      },
      margin: { left: 24, right: 24, top: 72, bottom: 24 },
      theme: 'striped',
    });

    doc.save(`collection-report-${getReportFileDate()}.pdf`);
  };

  if (!token || loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-cyan-50 to-teal-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-cyan-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-sky-50 via-cyan-50 to-emerald-50 px-3 py-4 sm:px-4 sm:py-6 md:px-6 relative overflow-hidden">
      <div className="pointer-events-none absolute inset-0 opacity-45">
        <div className="absolute -top-20 left-14 h-72 w-72 rounded-full bg-sky-300 blur-3xl"></div>
        <div className="absolute top-20 right-8 h-80 w-80 rounded-full bg-cyan-300 blur-3xl"></div>
        <div className="absolute bottom-0 left-1/3 h-72 w-72 rounded-full bg-emerald-300 blur-3xl"></div>
      </div>
      <div className="pointer-events-none absolute inset-0 opacity-20 [background-image:radial-gradient(circle_at_1px_1px,rgba(14,116,144,0.38)_1px,transparent_1px)] [background-size:24px_24px]">
      </div>

      <div className="relative z-10 max-w-7xl mx-auto space-y-6">
        <div className="bg-white/82 backdrop-blur-xl rounded-3xl border border-white/70 shadow-[0_20px_60px_-30px_rgba(14,116,144,0.45)] p-6 md:p-7">
          <div className="flex items-start justify-between gap-4 flex-wrap">
            <div>
              <span className="inline-flex rounded-full bg-white px-3 py-1 text-[11px] font-bold uppercase tracking-[0.16em] text-cyan-700 border border-cyan-100 shadow-sm">
                Reports Desk
              </span>
              <h1 className="text-2xl sm:text-3xl md:text-4xl font-black text-slate-900 mt-3 tracking-tight">Collection Report</h1>
              <p className="text-sm sm:text-base text-slate-600 mt-2 max-w-2xl">Period-wise collection performance with capital, interest, and penalty breakdown.</p>
            </div>
            <button
              onClick={handleBack}
              className="px-4 py-2.5 rounded-xl bg-white hover:bg-slate-50 text-slate-700 text-sm font-semibold border border-slate-200 shadow-sm w-full sm:w-auto"
            >
              Back
            </button>
          </div>

          <div className="mt-5 h-1.5 w-40 rounded-full bg-gradient-to-r from-cyan-500 via-sky-500 to-emerald-500"></div>

          <div className="mt-5 grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3">
            <div className="relative overflow-hidden rounded-2xl border border-cyan-100 bg-gradient-to-br from-white via-cyan-50/60 to-sky-50/70 p-4 shadow-sm">
              <div className="absolute -right-7 -top-7 h-16 w-16 rounded-full bg-cyan-200/40 blur-xl"></div>
              <div className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-cyan-100 text-cyan-700 text-xs font-bold">TX</div>
              <p className="mt-2 text-[11px] uppercase tracking-wide text-slate-500">Transactions</p>
              <p className="text-lg sm:text-xl font-bold text-slate-900 mt-1">{summary.transactionCount}</p>
            </div>
            <div className="relative overflow-hidden rounded-2xl border border-emerald-100 bg-gradient-to-br from-white via-emerald-50/70 to-teal-50/70 p-4 shadow-sm">
              <div className="absolute -right-7 -top-7 h-16 w-16 rounded-full bg-emerald-200/40 blur-xl"></div>
              <div className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700 text-xs font-bold">TC</div>
              <p className="mt-2 text-[11px] uppercase tracking-wide text-slate-500">Total Collected</p>
              <p className="text-sm sm:text-base font-bold text-emerald-700 mt-1 break-words [overflow-wrap:anywhere]">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.totalCollected)}
              </p>
            </div>
            <div className="relative overflow-hidden rounded-2xl border border-indigo-100 bg-gradient-to-br from-white via-indigo-50/65 to-cyan-50/70 p-4 shadow-sm">
              <div className="absolute -right-7 -top-7 h-16 w-16 rounded-full bg-indigo-200/40 blur-xl"></div>
              <div className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-indigo-100 text-indigo-700 text-xs font-bold">TI</div>
              <p className="mt-2 text-[11px] uppercase tracking-wide text-slate-500">Total Investment</p>
              <p className="text-sm sm:text-base font-bold text-indigo-700 mt-1 break-words [overflow-wrap:anywhere]">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.totalInvestment)}
              </p>
            </div>
            <div className="relative overflow-hidden rounded-2xl border border-sky-100 bg-gradient-to-br from-white via-sky-50/70 to-cyan-50/70 p-4 shadow-sm">
              <div className="absolute -right-7 -top-7 h-16 w-16 rounded-full bg-sky-200/40 blur-xl"></div>
              <div className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-sky-100 text-sky-700 text-xs font-bold">CP</div>
              <p className="mt-2 text-[11px] uppercase tracking-wide text-slate-500">Capital</p>
              <p className="text-sm sm:text-base font-bold text-slate-900 mt-1 break-words [overflow-wrap:anywhere]">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.totalCapital)}
              </p>
            </div>
            <div className="relative overflow-hidden rounded-2xl border border-cyan-100 bg-gradient-to-br from-white via-cyan-50/70 to-blue-50/70 p-4 shadow-sm">
              <div className="absolute -right-7 -top-7 h-16 w-16 rounded-full bg-cyan-200/40 blur-xl"></div>
              <div className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-cyan-100 text-cyan-700 text-xs font-bold">IN</div>
              <p className="mt-2 text-[11px] uppercase tracking-wide text-slate-500">Interest</p>
              <p className="text-sm sm:text-base font-bold text-slate-900 mt-1 break-words [overflow-wrap:anywhere]">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.totalInterest)}
              </p>
            </div>
            <div className="relative overflow-hidden rounded-2xl border border-rose-100 bg-gradient-to-br from-white via-rose-50/70 to-orange-50/70 p-4 shadow-sm sm:col-span-2">
              <div className="absolute -right-7 -top-7 h-16 w-16 rounded-full bg-rose-200/40 blur-xl"></div>
              <div className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-rose-100 text-rose-700 text-xs font-bold">PN</div>
              <p className="mt-2 text-[11px] uppercase tracking-wide text-slate-500">Penalty</p>
              <p className="text-sm sm:text-base font-bold text-rose-700 mt-1 break-words [overflow-wrap:anywhere]">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.totalPenalty)}
              </p>
            </div>
            <div className="relative overflow-hidden rounded-2xl border border-teal-100 bg-gradient-to-br from-white via-teal-50/70 to-cyan-50/70 p-4 shadow-sm sm:col-span-2">
              <div className="absolute -right-7 -top-7 h-16 w-16 rounded-full bg-teal-200/40 blur-xl"></div>
              <div className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-teal-100 text-teal-700 text-xs font-bold">TD</div>
              <p className="mt-2 text-[11px] uppercase tracking-wide text-slate-500">Today / Officers</p>
              <p className="text-sm sm:text-base font-bold text-cyan-800 mt-1 break-words [overflow-wrap:anywhere]">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.todayCollected)} / {summary.officerCount}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white/86 backdrop-blur-xl rounded-3xl border border-cyan-100 shadow-[0_18px_40px_-24px_rgba(14,116,144,0.5)] p-4 md:p-5">
          <div className="flex items-center justify-between gap-3 flex-wrap">
            <h2 className="text-lg font-bold text-slate-900">Collection Transactions</h2>
            <div className="flex flex-col sm:flex-row sm:items-end gap-2 w-full lg:w-auto lg:flex-wrap">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 w-full lg:w-auto">
                <div>
                  <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">From Date</label>
                  <input
                    type="date"
                    value={fromDate}
                    onChange={(e) => setFromDate(e.target.value)}
                    className="mt-1 w-full px-3 py-2.5 rounded-xl border border-cyan-100 bg-white text-sm text-slate-900"
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">To Date</label>
                  <input
                    type="date"
                    value={toDate}
                    onChange={(e) => setToDate(e.target.value)}
                    className="mt-1 w-full px-3 py-2.5 rounded-xl border border-cyan-100 bg-white text-sm text-slate-900"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 w-full sm:w-auto">
                <button
                  type="button"
                  onClick={() => {
                    setFromDate('');
                    setToDate('');
                  }}
                  className="px-3 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-semibold"
                >
                  Reset
                </button>
                <button
                  type="button"
                  onClick={handleDownloadCsv}
                  className="px-3 py-2.5 rounded-xl bg-emerald-100 hover:bg-emerald-200 text-emerald-800 text-sm font-semibold border border-emerald-200"
                >
                  Download CSV
                </button>
                <button
                  type="button"
                  onClick={handleDownloadPdf}
                  className="px-3 py-2.5 rounded-xl bg-cyan-100 hover:bg-cyan-200 text-cyan-800 text-sm font-semibold border border-cyan-200"
                >
                  Download PDF
                </button>
              </div>
            </div>
          </div>

          <div className="mt-3 rounded-xl border border-cyan-100 bg-gradient-to-r from-cyan-50/80 via-sky-50/70 to-emerald-50/70 px-3 py-2 text-xs sm:text-sm text-slate-600">
            Showing <span className="font-bold text-slate-800">{pagedRows.length}</span> of <span className="font-bold text-slate-800">{filteredRows.length}</span> transaction(s)
            {fromDate || toDate ? ` for ${fromDate || 'Start'} to ${toDate || 'End'}` : ' for all dates'}.
          </div>

          <div className="mt-3 flex items-center justify-between gap-3 flex-wrap">
            <div className="flex items-center gap-2 text-sm text-slate-700">
              <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">Rows</label>
              <select
                value={pageSize}
                onChange={(e) => setPageSize(Number(e.target.value))}
                className="px-2.5 py-1.5 rounded-lg border border-cyan-100 bg-white text-sm text-slate-800"
              >
                <option value={10}>10</option>
                <option value={25}>25</option>
                <option value={50}>50</option>
                <option value={100}>100</option>
              </select>
            </div>

            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
                disabled={currentPage <= 1}
                className="px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Previous
              </button>
              <span className="text-sm text-slate-700 font-semibold">
                Page {currentPage} of {totalPages}
              </span>
              <button
                type="button"
                onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
                disabled={currentPage >= totalPages}
                className="px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next
              </button>
            </div>
          </div>

          {filteredRows.length === 0 ? (
            <div className="mt-4 rounded-2xl border border-cyan-100 bg-gradient-to-br from-cyan-100/60 to-teal-100/40 p-8 text-sm text-slate-700 text-center">
              No collection data found for selected period.
            </div>
          ) : (
            <>
              <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3 lg:hidden">
                {pagedRows.map((row) => (
                  <div
                    key={row.id}
                    className="rounded-2xl border border-cyan-100 bg-white/90 p-4 shadow-sm"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <p className="text-xs uppercase tracking-wide text-slate-500">Date & Time</p>
                        <p className="text-sm font-semibold text-slate-900">{formatDateTime(row.date)}</p>
                      </div>
                      <span className="rounded-full bg-cyan-50 border border-cyan-100 px-2 py-0.5 text-[11px] font-semibold text-cyan-700">
                        {row.loanCode}
                      </span>
                    </div>

                    <div className="mt-3 grid grid-cols-2 gap-x-3 gap-y-2 text-sm">
                      <p className="text-slate-500">Loan Code</p>
                      <p className="font-semibold text-slate-900 text-right">{row.loanCode}</p>

                      <p className="text-slate-500">Customer No</p>
                      <p className="font-semibold text-slate-900 text-right">{row.customerNo}</p>

                      <p className="text-slate-500">Customer</p>
                      <p className="font-semibold text-slate-900 text-right">{row.customerName}</p>

                      <p className="text-slate-500">Officer</p>
                      <p className="text-slate-800 text-right">{row.fieldOfficer}</p>

                      <p className="text-slate-500">Loan Amount</p>
                      <p className="font-semibold text-slate-900 text-right">{formatMoney(row.loanAmount)}</p>

                      <p className="text-slate-500">Payment</p>
                      <p className="capitalize text-slate-800 text-right">{row.paymentType}</p>

                      <p className="text-slate-500">Reference</p>
                      <p className="text-slate-800 text-right break-words [overflow-wrap:anywhere]">{row.reference}</p>
                    </div>

                    <div className="mt-3 rounded-xl border border-cyan-100 bg-cyan-50/40 p-3 grid grid-cols-2 gap-2 text-sm">
                      <div>
                        <p className="text-[11px] uppercase tracking-wide text-slate-500">Collected</p>
                        <p className="font-bold text-emerald-700">{formatMoney(row.collected)}</p>
                      </div>
                      <div>
                        <p className="text-[11px] uppercase tracking-wide text-slate-500">Capital</p>
                        <p className="font-semibold text-slate-900">{formatMoney(row.capital)}</p>
                      </div>
                      <div>
                        <p className="text-[11px] uppercase tracking-wide text-slate-500">Interest</p>
                        <p className="font-semibold text-slate-900">{formatMoney(row.interest)}</p>
                      </div>
                      <div>
                        <p className="text-[11px] uppercase tracking-wide text-slate-500">Penalty</p>
                        <p className="font-semibold text-rose-700">{formatMoney(row.penalty)}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-4 overflow-x-auto rounded-2xl border border-cyan-100 hidden lg:block">
                <table className="min-w-full text-sm text-left text-slate-700 bg-white">
                  <thead className="bg-cyan-50/70 text-slate-700 sticky top-0">
                    <tr>
                      <th className="px-3 py-2 font-semibold">Date & Time</th>
                      <th className="px-3 py-2 font-semibold">Loan Code</th>
                      <th className="px-3 py-2 font-semibold">Customer No</th>
                      <th className="px-3 py-2 font-semibold">Customer</th>
                      <th className="px-3 py-2 font-semibold">Field Officer</th>
                      <th className="px-3 py-2 font-semibold">Loan Amount</th>
                      <th className="px-3 py-2 font-semibold">Payment Type</th>
                      <th className="px-3 py-2 font-semibold">Reference</th>
                      <th className="px-3 py-2 font-semibold">Collected</th>
                      <th className="px-3 py-2 font-semibold">Capital</th>
                      <th className="px-3 py-2 font-semibold">Interest</th>
                      <th className="px-3 py-2 font-semibold">Penalty</th>
                    </tr>
                  </thead>
                  <tbody>
                    {pagedRows.map((row) => (
                      <tr key={row.id} className="border-b border-cyan-100 last:border-b-0 hover:bg-cyan-50/40 transition-colors">
                        <td className="px-3 py-2">{formatDateTime(row.date)}</td>
                        <td className="px-3 py-2 font-semibold text-slate-900">{row.loanCode}</td>
                        <td className="px-3 py-2">{row.customerNo}</td>
                        <td className="px-3 py-2">{row.customerName}</td>
                        <td className="px-3 py-2">{row.fieldOfficer}</td>
                        <td className="px-3 py-2">{formatMoney(row.loanAmount)}</td>
                        <td className="px-3 py-2 capitalize">{row.paymentType}</td>
                        <td className="px-3 py-2">{row.reference}</td>
                        <td className="px-3 py-2 font-semibold text-emerald-700">{formatMoney(row.collected)}</td>
                        <td className="px-3 py-2">{formatMoney(row.capital)}</td>
                        <td className="px-3 py-2">{formatMoney(row.interest)}</td>
                        <td className="px-3 py-2">{formatMoney(row.penalty)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
