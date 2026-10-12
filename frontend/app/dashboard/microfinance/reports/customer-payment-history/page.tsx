'use client';

import axios from 'axios';
import { useEffect, useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

type LoanRow = {
  id: number;
  loan_code?: string | null;
  customer_no?: string | null;
  customer_name?: string | null;
  field_officer?: string | null;
  due_date?: string | null;
  next_payment_date?: string | null;
  installment_amount?: number | string | null;
  refundable_amount?: number | string | null;
  arrears_balance?: number | string | null;
};

type CollectionRow = {
  id: number;
  mf_loan_request_id: number | string;
  collection_date?: string | null;
  created_at?: string | null;
  collected_amount?: number | string | null;
  capital_amount?: number | string | null;
  interest_amount?: number | string | null;
  penalty_amount?: number | string | null;
  payment_type?: string | null;
  payment_reference?: string | null;
};

type HistoryRow = {
  id: number;
  date: string;
  loanId: number;
  loanCode: string;
  customerNo: string;
  customerName: string;
  fieldOfficer: string;
  collected: number;
  capital: number;
  interest: number;
  penalty: number;
  paymentType: string;
  reference: string;
};

type LoanSummaryRow = {
  loanId: number;
  loanCode: string;
  customerNo: string;
  customerName: string;
  fieldOfficer: string;
  installmentAmount: number;
  refundableAmount: number;
  outstandingAmount: number;
  transactionCount: number;
  collected: number;
  capital: number;
  interest: number;
  penalty: number;
  arrears: number;
  dueDate: string;
  nextPaymentDate: string;
  lastPaymentDate: string;
};

const API_BASE = 'http://localhost:8000/api';

const hasTimePart = (value: string) => /[T\s]\d{2}:\d{2}/.test(value);

const parseDateMs = (value: string) => {
  const text = String(value || '').trim();
  if (!text) return Number.NaN;

  if (/^\d{4}-\d{2}-\d{2}$/.test(text)) {
    const [year, month, day] = text.split('-').map(Number);
    return new Date(year, month - 1, day, 0, 0, 0).getTime();
  }

  return new Date(text).getTime();
};

export default function CustomerPaymentHistoryReportPage() {
  const router = useRouter();
  const [token, setToken] = useState('');
  const [loading, setLoading] = useState(true);
  const [historyRows, setHistoryRows] = useState<HistoryRow[]>([]);
  const [loanRows, setLoanRows] = useState<LoanRow[]>([]);
  const [search, setSearch] = useState('');
  const [fromDate, setFromDate] = useState('');
  const [toDate, setToDate] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [selectedLoan, setSelectedLoan] = useState<LoanSummaryRow | null>(null);

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
          }),
          axios.get(`${API_BASE}/microfinance/collections`, {
            headers: {
              Authorization: `Bearer ${token}`,
              Accept: 'application/json',
            },
          }),
        ]);

        const loans: LoanRow[] = Array.isArray(loanRes.data) ? loanRes.data : [];
        const collections: CollectionRow[] = Array.isArray(collectionRes.data) ? collectionRes.data : [];

        const loanMap = new Map<number, LoanRow>();
        loans.forEach((loan) => {
          loanMap.set(Number(loan.id), loan);
        });

        const mapped: HistoryRow[] = collections
          .map((collection) => {
            const loanId = Number(collection.mf_loan_request_id || 0);
            const loan = loanMap.get(loanId);
            const collectionDate = String(collection.collection_date || '').trim();
            const createdAt = String(collection.created_at || '').trim();

            // Prefer the actual timestamp when collection_date is date-only.
            const effectiveDate = collectionDate
              ? (hasTimePart(collectionDate) ? collectionDate : (createdAt || collectionDate))
              : createdAt;

            return {
              id: Number(collection.id || 0),
              date: effectiveDate,
              loanId,
              loanCode: String(loan?.loan_code || '').trim() || `LR-${loanId}`,
              customerNo: String(loan?.customer_no || '-'),
              customerName: String(loan?.customer_name || '-'),
              fieldOfficer: String(loan?.field_officer || 'Unassigned'),
              collected: Number(collection.collected_amount || 0),
              capital: Number(collection.capital_amount || 0),
              interest: Number(collection.interest_amount || 0),
              penalty: Number(collection.penalty_amount || 0),
              paymentType: String(collection.payment_type || '-').replace('_', ' '),
              reference: String(collection.payment_reference || '-'),
            };
          })
          .sort((a, b) => {
            const aTime = parseDateMs(a.date);
            const bTime = parseDateMs(b.date);
            return (Number.isNaN(bTime) ? 0 : bTime) - (Number.isNaN(aTime) ? 0 : aTime);
          });

        setHistoryRows(mapped);
        setLoanRows(loans);
      } catch {
        setHistoryRows([]);
        setLoanRows([]);
      } finally {
        setLoading(false);
      }
    };

    loadReport();
  }, [token]);

  const dateFilteredHistoryRows = useMemo(() => {
    const from = fromDate ? new Date(`${fromDate}T00:00:00`) : null;
    const to = toDate ? new Date(`${toDate}T23:59:59`) : null;

    return historyRows.filter((row) => {
      const rowMs = parseDateMs(row.date);
      const rowDate = Number.isNaN(rowMs) ? null : new Date(rowMs);

      if (from && rowDate && !Number.isNaN(rowDate.getTime()) && rowDate < from) {
        return false;
      }

      if (to && rowDate && !Number.isNaN(rowDate.getTime()) && rowDate > to) {
        return false;
      }

      return true;
    });
  }, [historyRows, fromDate, toDate]);

  const loanTableRows = useMemo(() => {
    const keyword = search.trim().toLowerCase();
    const grouped = new Map<number, HistoryRow[]>();
    const paidAllByLoan = new Map<number, number>();

    historyRows.forEach((row) => {
      paidAllByLoan.set(row.loanId, (paidAllByLoan.get(row.loanId) || 0) + Number(row.collected || 0));
    });

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    dateFilteredHistoryRows.forEach((row) => {
      const list = grouped.get(row.loanId) || [];
      list.push(row);
      grouped.set(row.loanId, list);
    });

    return loanRows
      .map((loan) => {
        const loanId = Number(loan.id || 0);
        const matchedHistory = grouped.get(loanId) || [];
        const totals = matchedHistory.reduce(
          (acc, row) => {
            acc.collected += row.collected;
            acc.capital += row.capital;
            acc.interest += row.interest;
            acc.penalty += row.penalty;
            return acc;
          },
          { collected: 0, capital: 0, interest: 0, penalty: 0 }
        );

        const dueDateText = String(loan.due_date || '').slice(0, 10);
        const dueDate = dueDateText ? new Date(`${dueDateText}T00:00:00`) : null;
        const overdueDays =
          dueDate && !Number.isNaN(dueDate.getTime())
            ? Math.max(Math.floor((today.getTime() - dueDate.getTime()) / (1000 * 60 * 60 * 24)), 0)
            : 0;

        const rawArrears = Math.max(Number(loan.arrears_balance || 0), 0);
        const installment = Math.max(Number(loan.installment_amount || 0), 0);
        const refundableAmount = Math.max(Number(loan.refundable_amount || 0), 0);
        const paidAll = Math.max(paidAllByLoan.get(loanId) || 0, 0);
        const pendingAmount = Math.max(refundableAmount - paidAll, 0);
        const scheduledArrears = overdueDays > 0 ? overdueDays * installment : 0;
        const arrearsBase = scheduledArrears > 0 ? scheduledArrears : rawArrears;
        const arrears = Math.min(Math.max(arrearsBase, 0), pendingAmount);

        const lastPaymentDate = matchedHistory
          .map((row) => row.date)
          .sort((a, b) => {
            const aTime = parseDateMs(a);
            const bTime = parseDateMs(b);
            return (Number.isNaN(bTime) ? 0 : bTime) - (Number.isNaN(aTime) ? 0 : aTime);
          })[0] || '';

        return {
          loanId,
          loanCode: String(loan.loan_code || '').trim() || `LR-${loanId}`,
          customerNo: String(loan.customer_no || '-'),
          customerName: String(loan.customer_name || '-'),
          fieldOfficer: String(loan.field_officer || 'Unassigned'),
          installmentAmount: installment,
          refundableAmount,
          outstandingAmount: pendingAmount,
          transactionCount: matchedHistory.length,
          collected: totals.collected,
          capital: totals.capital,
          interest: totals.interest,
          penalty: totals.penalty,
          arrears,
          dueDate: dueDateText || '',
          nextPaymentDate: String(loan.next_payment_date || '').slice(0, 10),
          lastPaymentDate,
        };
      })
      .filter((row) => {
        const haystack = [row.loanCode, row.customerNo, row.customerName, row.fieldOfficer]
          .join(' ')
          .toLowerCase();

        if (keyword && !haystack.includes(keyword)) {
          return false;
        }

        // Keep only loans that have history rows for chosen date range.
        return row.transactionCount > 0;
      })
      .sort((a, b) => {
        const aTime = a.lastPaymentDate ? parseDateMs(a.lastPaymentDate) : 0;
        const bTime = b.lastPaymentDate ? parseDateMs(b.lastPaymentDate) : 0;
        return (Number.isNaN(bTime) ? 0 : bTime) - (Number.isNaN(aTime) ? 0 : aTime);
      });
  }, [loanRows, dateFilteredHistoryRows, historyRows, search]);

  useEffect(() => {
    setCurrentPage(1);
  }, [search, fromDate, toDate, pageSize]);

  const totalPages = useMemo(() => {
    return Math.max(1, Math.ceil(loanTableRows.length / pageSize));
  }, [loanTableRows.length, pageSize]);

  useEffect(() => {
    setCurrentPage((prev) => Math.min(prev, totalPages));
  }, [totalPages]);

  const pagedRows = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return loanTableRows.slice(start, start + pageSize);
  }, [loanTableRows, currentPage, pageSize]);

  const summary = useMemo(() => {
    const customers = new Set<string>();

    const sums = loanTableRows.reduce(
      (acc, row) => {
        acc.transactions += row.transactionCount;
        acc.collected += row.collected;
        acc.capital += row.capital;
        acc.interest += row.interest;
        acc.penalty += row.penalty;
        customers.add(row.customerNo);
        return acc;
      },
      {
        transactions: 0,
        collected: 0,
        capital: 0,
        interest: 0,
        penalty: 0,
      }
    );

    return {
      ...sums,
      customers,
      loans: loanTableRows.length,
    };
  }, [loanTableRows]);

  const selectedLoanHistoryRows = useMemo(() => {
    if (!selectedLoan) return [];

    return historyRows
      .filter((row) => row.loanId === selectedLoan.loanId)
      .sort((a, b) => {
        const aTime = parseDateMs(a.date);
        const bTime = parseDateMs(b.date);
        return (Number.isNaN(bTime) ? 0 : bTime) - (Number.isNaN(aTime) ? 0 : aTime);
      });
  }, [historyRows, selectedLoan]);

  const formatMoney = (value: number) => Number(value || 0).toFixed(2);

  const formatDateTime = (value: string) => {
    const parsedMs = parseDateMs(value);
    if (Number.isNaN(parsedMs)) {
      return value || '-';
    }

    const parsed = new Date(parsedMs);
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

  const formatDateOnly = (value: string) => {
    const parsedMs = parseDateMs(value);
    if (Number.isNaN(parsedMs)) {
      return value || '-';
    }

    const parsed = new Date(parsedMs);
    if (Number.isNaN(parsed.getTime())) {
      return value || '-';
    }

    return new Intl.DateTimeFormat('en-LK', {
      year: 'numeric',
      month: 'short',
      day: '2-digit',
    }).format(parsed);
  };

  const getReportFileDate = () => new Date().toISOString().slice(0, 10);

  const handleDownloadCsv = () => {
    const headers = [
      'Loan ID',
      'Loan Code',
      'Customer No',
      'Customer Name',
      'Field Officer',
      'Transactions',
      'Collected',
      'Capital',
      'Profit',
      'Penalty',
      'Arrears',
      'Last Payment Date',
    ];

    const escapeCsv = (value: string | number) => {
      const text = String(value ?? '');
      if (text.includes(',') || text.includes('"') || text.includes('\n')) {
        return `"${text.replace(/"/g, '""')}"`;
      }
      return text;
    };

    const body = loanTableRows.map((row) => [
      row.loanId,
      row.loanCode,
      row.customerNo,
      row.customerName,
      row.fieldOfficer,
      row.transactionCount,
      formatMoney(row.collected),
      formatMoney(row.capital),
      formatMoney(row.interest + row.penalty),
      formatMoney(row.penalty),
      formatMoney(row.arrears),
      formatDateTime(row.lastPaymentDate),
    ]);

    const csv = [headers, ...body].map((line) => line.map(escapeCsv).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `loan-payment-summary-${getReportFileDate()}.csv`;
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

    const searchText = search.trim() ? `Search: ${search.trim()}` : 'Search: All';
    const fromText = fromDate ? `From: ${fromDate}` : 'From: -';
    const toText = toDate ? `To: ${toDate}` : 'To: -';

    doc.setFontSize(16);
    doc.text('Loan Payment Summary Report', 40, 40);
    doc.setFontSize(10);
    doc.text(`${searchText} | ${fromText} | ${toText} | Generated: ${generatedAt}`, 40, 58);

    autoTable(doc, {
      startY: 72,
      head: [[
        'Loan ID',
        'Loan Code',
        'Customer No',
        'Customer',
        'Officer',
        'Txns',
        'Collected',
        'Capital',
        'Profit',
        'Penalty',
        'Arrears',
        'Last Payment',
      ]],
      body: loanTableRows.map((row) => [
        row.loanId,
        row.loanCode,
        row.customerNo,
        row.customerName,
        row.fieldOfficer,
        row.transactionCount,
        formatMoney(row.collected),
        formatMoney(row.capital),
        formatMoney(row.interest + row.penalty),
        formatMoney(row.penalty),
        formatMoney(row.arrears),
        formatDateTime(row.lastPaymentDate),
      ]),
      styles: {
        fontSize: 8,
        cellPadding: 4,
      },
      headStyles: {
        fillColor: [8, 47, 73],
        textColor: [255, 255, 255],
      },
      alternateRowStyles: {
        fillColor: [236, 254, 255],
      },
      margin: { left: 24, right: 24, top: 72, bottom: 24 },
      theme: 'striped',
    });

    doc.save(`loan-payment-summary-${getReportFileDate()}.pdf`);
  };

  const handleDownloadSelectedLoanPdf = () => {
    if (!selectedLoan) return;

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

    doc.setFontSize(16);
    doc.text('Loan Payment History', 40, 40);
    doc.setFontSize(10);
    doc.text(
      `Loan ID: ${selectedLoan.loanId} | Loan: ${selectedLoan.loanCode} | Customer: ${selectedLoan.customerNo} - ${selectedLoan.customerName} | Generated: ${generatedAt}`,
      40,
      58
    );

    autoTable(doc, {
      startY: 72,
      head: [['Field', 'Value', 'Field', 'Value']],
      body: [
        ['Loan Code', selectedLoan.loanCode, 'Customer No', selectedLoan.customerNo],
        ['Customer', selectedLoan.customerName, 'Field Officer', selectedLoan.fieldOfficer],
        ['Installment', formatMoney(selectedLoan.installmentAmount), 'Refundable', formatMoney(selectedLoan.refundableAmount)],
        ['Outstanding', formatMoney(selectedLoan.outstandingAmount), 'Arrears', formatMoney(selectedLoan.arrears)],
        ['Collected', formatMoney(selectedLoan.collected), 'Capital', formatMoney(selectedLoan.capital)],
        ['Interest', formatMoney(selectedLoan.interest), 'Penalty', formatMoney(selectedLoan.penalty)],
        ['Due Date', formatDateOnly(selectedLoan.dueDate), 'Next Payment', formatDateOnly(selectedLoan.nextPaymentDate)],
        ['Transactions', String(selectedLoan.transactionCount), 'Last Payment', formatDateTime(selectedLoan.lastPaymentDate)],
      ],
      styles: {
        fontSize: 8,
        cellPadding: 4,
      },
      headStyles: {
        fillColor: [8, 47, 73],
        textColor: [255, 255, 255],
      },
      margin: { left: 24, right: 24, top: 72, bottom: 24 },
      theme: 'grid',
    });

    const detailTableEndY =
      (doc as jsPDF & { lastAutoTable?: { finalY?: number } }).lastAutoTable?.finalY ?? 130;

    autoTable(doc, {
      startY: detailTableEndY + 14,
      head: [[
        'Date & Time',
        'Pay Type',
        'Reference',
        'Collected',
        'Capital',
        'Interest',
        'Penalty',
      ]],
      body: selectedLoanHistoryRows.map((row) => [
        formatDateTime(row.date),
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
        fillColor: [8, 47, 73],
        textColor: [255, 255, 255],
      },
      alternateRowStyles: {
        fillColor: [236, 254, 255],
      },
      margin: { left: 24, right: 24, top: 72, bottom: 24 },
      theme: 'striped',
    });

    doc.save(`loan-history-${selectedLoan.loanCode}-${getReportFileDate()}.pdf`);
  };

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,#dbeafe_0%,#ecfeff_35%,#f0fdfa_100%)] p-4 md:p-6 relative overflow-hidden">
      <div className="pointer-events-none absolute inset-0 opacity-50">
        <div className="absolute -top-24 left-10 h-80 w-80 rounded-full bg-sky-300/70 blur-3xl"></div>
        <div className="absolute top-24 right-4 h-96 w-96 rounded-full bg-cyan-300/60 blur-3xl"></div>
        <div className="absolute -bottom-10 left-1/3 h-80 w-80 rounded-full bg-emerald-300/55 blur-3xl"></div>
      </div>
      <div className="pointer-events-none absolute inset-0 opacity-20 [background-image:linear-gradient(to_right,rgba(8,145,178,0.15)_1px,transparent_1px),linear-gradient(to_bottom,rgba(8,145,178,0.15)_1px,transparent_1px)] [background-size:26px_26px]"></div>

      <div className="relative z-10 mx-auto max-w-7xl space-y-6">
        <div className="relative overflow-hidden rounded-3xl border border-white/80 bg-white/85 p-6 md:p-7 shadow-[0_24px_70px_-34px_rgba(14,116,144,0.5)] backdrop-blur-xl">
          <div className="pointer-events-none absolute -right-24 -top-24 h-56 w-56 rounded-full bg-cyan-200/60 blur-3xl"></div>
          <div className="pointer-events-none absolute -left-16 bottom-0 h-40 w-40 rounded-full bg-amber-200/50 blur-2xl"></div>
          <div className="flex items-center justify-between gap-3 flex-wrap">
            <div>
              <span className="inline-flex rounded-full bg-gradient-to-r from-cyan-600 to-sky-600 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.16em] text-white shadow">
                Reports Desk
              </span>
              <h1 className="mt-3 text-2xl md:text-4xl font-black tracking-tight text-slate-900">Customer Payment History Report</h1>
              <p className="mt-1 max-w-2xl text-sm text-slate-600">Loan-level payment summary with one-click transaction history per loan.</p>
            </div>
            <button
              type="button"
              onClick={() => router.back()}
              className="rounded-xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white shadow-md hover:bg-slate-700"
            >
              Back
            </button>
          </div>
        </div>

        <div className="rounded-3xl border border-cyan-100 bg-white/88 p-4 md:p-5 shadow-[0_18px_48px_-24px_rgba(14,116,144,0.45)] backdrop-blur-xl">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div>
              <label className="text-xs font-semibold uppercase tracking-wide text-slate-500">Search</label>
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Customer no, customer name, loan code"
                className="mt-1 w-full rounded-xl border border-cyan-100 bg-white px-3 py-2.5 text-sm text-black focus:outline-none focus:ring-2 focus:ring-cyan-200"
              />
            </div>
            <div>
              <label className="text-xs font-semibold uppercase tracking-wide text-slate-500">From Date</label>
              <input
                type="date"
                value={fromDate}
                onChange={(e) => setFromDate(e.target.value)}
                className="mt-1 w-full rounded-xl border border-cyan-100 bg-white px-3 py-2.5 text-sm text-black focus:outline-none focus:ring-2 focus:ring-cyan-200"
              />
            </div>
            <div>
              <label className="text-xs font-semibold uppercase tracking-wide text-slate-500">To Date</label>
              <input
                type="date"
                value={toDate}
                onChange={(e) => setToDate(e.target.value)}
                className="mt-1 w-full rounded-xl border border-cyan-100 bg-white px-3 py-2.5 text-sm text-black focus:outline-none focus:ring-2 focus:ring-cyan-200"
              />
            </div>
          </div>

          <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
            <div className="rounded-2xl border border-cyan-300/40 bg-gradient-to-br from-cyan-500 to-sky-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-cyan-100">Transactions</p>
              <p className="mt-1 text-[14px] font-extrabold">{summary.transactions}</p>
            </div>
            <div className="rounded-2xl border border-indigo-300/40 bg-gradient-to-br from-indigo-500 to-blue-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-indigo-100">Loans</p>
              <p className="mt-1 text-[14px] font-extrabold">{summary.loans}</p>
            </div>
            <div className="rounded-2xl border border-emerald-300/40 bg-gradient-to-br from-emerald-500 to-teal-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-emerald-100">Collected</p>
              <p className="mt-1 text-[14px] font-extrabold break-words tabular-nums">{formatMoney(summary.collected)}</p>
            </div>
            <div className="rounded-2xl border border-teal-300/40 bg-gradient-to-br from-teal-500 to-cyan-700 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-teal-100">Customers</p>
              <p className="mt-1 text-[14px] font-extrabold">{summary.customers.size}</p>
            </div>
            <div className="rounded-2xl border border-amber-300/40 bg-gradient-to-br from-amber-500 to-orange-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-amber-100">Profit</p>
              <p className="mt-1 text-[14px] font-extrabold break-words tabular-nums">{formatMoney(summary.interest + summary.penalty)}</p>
            </div>
          </div>
        </div>

        <div className="rounded-3xl border border-cyan-100 bg-white/90 p-4 backdrop-blur-xl shadow-[0_18px_48px_-24px_rgba(14,116,144,0.45)]">
          <div className="mb-3 flex items-center justify-end gap-2">
            <button
              type="button"
              onClick={handleDownloadCsv}
              className="px-3 py-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 text-white text-sm font-semibold border border-emerald-400 shadow-sm"
            >
              Download CSV
            </button>
            <button
              type="button"
              onClick={handleDownloadPdf}
              className="px-3 py-2 rounded-xl bg-gradient-to-r from-cyan-500 to-sky-600 hover:from-cyan-600 hover:to-sky-700 text-white text-sm font-semibold border border-cyan-400 shadow-sm"
            >
              Download PDF
            </button>
          </div>

          {loading ? (
            <div className="py-8 flex items-center justify-center">
              <div className="h-10 w-10 animate-spin rounded-full border-4 border-cyan-200 border-t-cyan-600"></div>
            </div>
          ) : loanTableRows.length === 0 ? (
            <div className="mt-2 rounded-2xl border border-cyan-100 bg-gradient-to-br from-cyan-100/60 to-teal-100/40 p-8 text-center text-sm text-slate-700">
              No loans found for selected filters.
            </div>
          ) : (
            <>
              <div className="overflow-x-auto rounded-2xl border border-cyan-100 bg-white shadow-inner">
                <table className="min-w-full text-sm text-left text-slate-700 bg-white">
                  <thead className="bg-gradient-to-r from-slate-900 via-slate-800 to-cyan-800 text-white sticky top-0">
                    <tr>
                      <th className="px-3 py-2 font-semibold">Loan ID</th>
                      <th className="px-3 py-2 font-semibold">Loan Code</th>
                      <th className="px-3 py-2 font-semibold">Customer No</th>
                      <th className="px-3 py-2 font-semibold">Customer</th>
                      <th className="px-3 py-2 font-semibold">Field Officer</th>
                      <th className="px-3 py-2 font-semibold">Transactions</th>
                      <th className="px-3 py-2 font-semibold">Last Payment</th>
                      <th className="px-3 py-2 font-semibold">Collected</th>
                      <th className="px-3 py-2 font-semibold">Capital</th>
                      <th className="px-3 py-2 font-semibold">Profit</th>
                      <th className="px-3 py-2 font-semibold">Penalty</th>
                      <th className="px-3 py-2 font-semibold">Arrears</th>
                      <th className="px-3 py-2 font-semibold">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {pagedRows.map((row) => (
                      <tr key={row.loanId} className="border-b border-cyan-100 last:border-b-0 odd:bg-white even:bg-cyan-50/25 hover:bg-cyan-50/60 transition-colors">
                        <td className="px-3 py-2 font-semibold text-slate-900">{row.loanId}</td>
                        <td className="px-3 py-2 font-semibold text-slate-900">{row.loanCode}</td>
                        <td className="px-3 py-2">{row.customerNo}</td>
                        <td className="px-3 py-2">{row.customerName}</td>
                        <td className="px-3 py-2">{row.fieldOfficer}</td>
                        <td className="px-3 py-2 font-semibold text-slate-800">{row.transactionCount}</td>
                        <td className="px-3 py-2">{formatDateTime(row.lastPaymentDate)}</td>
                        <td className="px-3 py-2 text-cyan-700 font-semibold tabular-nums">{formatMoney(row.collected)}</td>
                        <td className="px-3 py-2 text-emerald-700 font-semibold tabular-nums">{formatMoney(row.capital)}</td>
                        <td className="px-3 py-2 tabular-nums">{formatMoney(row.interest + row.penalty)}</td>
                        <td className="px-3 py-2 tabular-nums">{formatMoney(row.penalty)}</td>
                        <td className="px-3 py-2 text-orange-700 font-semibold tabular-nums">{formatMoney(row.arrears)}</td>
                        <td className="px-3 py-2">
                          <button
                            type="button"
                            onClick={() => setSelectedLoan(row)}
                            className="rounded-lg border border-cyan-300 bg-cyan-50 px-3 py-1.5 text-xs font-semibold text-cyan-700 hover:bg-cyan-100"
                          >
                            View History
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="mt-3 flex flex-wrap items-center justify-between gap-3 text-sm text-slate-600">
                <div>
                  Showing {loanTableRows.length === 0 ? 0 : (currentPage - 1) * pageSize + 1}
                  {' '}
                  to {Math.min(currentPage * pageSize, loanTableRows.length)} of {loanTableRows.length}
                </div>
                <div className="flex items-center gap-2">
                  <label className="text-xs font-semibold uppercase tracking-wide text-slate-500">Rows</label>
                  <select
                    value={pageSize}
                    onChange={(e) => setPageSize(Number(e.target.value))}
                    className="px-2 py-1.5 rounded-lg border border-cyan-100 bg-white text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-cyan-200"
                  >
                    <option value={10}>10</option>
                    <option value={25}>25</option>
                    <option value={50}>50</option>
                  </select>
                  <button
                    type="button"
                    onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                    disabled={currentPage <= 1}
                    className="px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-slate-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Prev
                  </button>
                  <span className="min-w-20 text-center text-slate-700 font-semibold">
                    {currentPage} / {totalPages}
                  </span>
                  <button
                    type="button"
                    onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                    disabled={currentPage >= totalPages}
                    className="px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-slate-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Next
                  </button>
                </div>
              </div>
            </>
          )}
        </div>

        {selectedLoan && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
            <div className="w-full max-w-6xl rounded-3xl border border-cyan-100 bg-white shadow-2xl">
              <div className="flex items-center justify-between gap-3 border-b border-cyan-100 p-4 md:p-5">
                <div>
                  <h2 className="text-lg font-black text-slate-900">Loan Payment History</h2>
                  <p className="text-xs text-slate-600 mt-0.5">
                    Loan ID: {selectedLoan.loanId} | {selectedLoan.loanCode} | {selectedLoan.customerNo} | {selectedLoan.customerName}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={handleDownloadSelectedLoanPdf}
                    className="rounded-lg border border-cyan-300 bg-cyan-50 px-3 py-1.5 text-sm font-semibold text-cyan-700 hover:bg-cyan-100"
                  >
                    Download PDF
                  </button>
                  <button
                    type="button"
                    onClick={() => setSelectedLoan(null)}
                    className="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                  >
                    Close
                  </button>
                </div>
              </div>

              <div className="p-4 md:p-5">
                <div className="mb-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-2 rounded-2xl border border-cyan-100 bg-cyan-50/25 p-3">
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Installment</p>
                    <p className="font-semibold text-slate-900 tabular-nums">{formatMoney(selectedLoan.installmentAmount)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Refundable</p>
                    <p className="font-semibold text-slate-900 tabular-nums">{formatMoney(selectedLoan.refundableAmount)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Outstanding</p>
                    <p className="font-semibold text-rose-700 tabular-nums">{formatMoney(selectedLoan.outstandingAmount)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Arrears</p>
                    <p className="font-semibold text-orange-700 tabular-nums">{formatMoney(selectedLoan.arrears)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Collected</p>
                    <p className="font-semibold text-cyan-700 tabular-nums">{formatMoney(selectedLoan.collected)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Capital</p>
                    <p className="font-semibold text-emerald-700 tabular-nums">{formatMoney(selectedLoan.capital)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Profit (I+P)</p>
                    <p className="font-semibold text-slate-900 tabular-nums">{formatMoney(selectedLoan.interest + selectedLoan.penalty)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Penalty</p>
                    <p className="font-semibold text-fuchsia-700 tabular-nums">{formatMoney(selectedLoan.penalty)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Due Date</p>
                    <p className="font-semibold text-slate-900">{formatDateOnly(selectedLoan.dueDate)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Next Payment</p>
                    <p className="font-semibold text-slate-900">{formatDateOnly(selectedLoan.nextPaymentDate)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Last Payment</p>
                    <p className="font-semibold text-slate-900">{formatDateTime(selectedLoan.lastPaymentDate)}</p>
                  </div>
                  <div className="rounded-xl border border-cyan-100 bg-white p-2">
                    <p className="text-[11px] uppercase tracking-wide text-slate-500">Transactions</p>
                    <p className="font-semibold text-slate-900">{selectedLoan.transactionCount}</p>
                  </div>
                </div>

                {selectedLoanHistoryRows.length === 0 ? (
                  <div className="rounded-2xl border border-cyan-100 bg-cyan-50/40 p-6 text-center text-sm text-slate-600">
                    No payment history available for this loan.
                  </div>
                ) : (
                  <div className="overflow-x-auto rounded-2xl border border-cyan-100">
                    <table className="min-w-full text-sm text-left text-slate-700 bg-white">
                      <thead className="bg-cyan-50 text-slate-800">
                        <tr>
                          <th className="px-3 py-2 font-semibold">Date & Time</th>
                          <th className="px-3 py-2 font-semibold">Pay Type</th>
                          <th className="px-3 py-2 font-semibold">Reference</th>
                          <th className="px-3 py-2 font-semibold">Collected</th>
                          <th className="px-3 py-2 font-semibold">Capital</th>
                          <th className="px-3 py-2 font-semibold">Interest</th>
                          <th className="px-3 py-2 font-semibold">Penalty</th>
                        </tr>
                      </thead>
                      <tbody>
                        {selectedLoanHistoryRows.map((row) => (
                          <tr key={row.id} className="border-b border-cyan-100 last:border-b-0 odd:bg-white even:bg-cyan-50/25">
                            <td className="px-3 py-2">{formatDateTime(row.date)}</td>
                            <td className="px-3 py-2 capitalize">{row.paymentType}</td>
                            <td className="px-3 py-2">{row.reference}</td>
                            <td className="px-3 py-2 text-cyan-700 font-semibold tabular-nums">{formatMoney(row.collected)}</td>
                            <td className="px-3 py-2 text-emerald-700 font-semibold tabular-nums">{formatMoney(row.capital)}</td>
                            <td className="px-3 py-2 tabular-nums">{formatMoney(row.interest)}</td>
                            <td className="px-3 py-2 tabular-nums">{formatMoney(row.penalty)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
