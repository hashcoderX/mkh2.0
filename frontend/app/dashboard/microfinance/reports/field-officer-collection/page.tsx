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

type TransactionRow = {
  id: number;
  date: string;
  loanId: number;
  loanCode: string;
  customerNo: string;
  customerName: string;
  fieldOfficer: string;
  loanAmount: number;
  loanBalance: number;
  collected: number;
  capital: number;
  interest: number;
  penalty: number;
  paymentType: string;
  reference: string;
};

const toNullableNumber = (value: unknown): number | null => {
  if (value === null || typeof value === 'undefined' || value === '') return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
};

const API_BASE = 'http://localhost:8000/api';

export default function FieldOfficerCollectionReportPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [token, setToken] = useState('');
  const [loading, setLoading] = useState(true);
  const [rows, setRows] = useState<TransactionRow[]>([]);
  const [fromDate, setFromDate] = useState('');
  const [toDate, setToDate] = useState('');
  const [officerFilter, setOfficerFilter] = useState('all');
  const [pageSize, setPageSize] = useState(10);
  const [currentPage, setCurrentPage] = useState(1);

  const branchId = Number(searchParams.get('branch_id') || 0) || undefined;

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

        const loanMap = new Map<number, LoanRow>();
        loans.forEach((loan) => {
          loanMap.set(Number(loan.id), loan);
        });

        const capitalCollectedByLoan = new Map<number, number>();
        collections.forEach((collection) => {
          const loanId = Number(collection.mf_loan_request_id || 0);
          if (!loanId) return;
          const existing = capitalCollectedByLoan.get(loanId) || 0;
          capitalCollectedByLoan.set(loanId, existing + Number(collection.capital_amount || 0));
        });

        const mapped: TransactionRow[] = collections
          .map((collection) => {
            const loanId = Number(collection.mf_loan_request_id || 0);
            const loan = loanMap.get(loanId);
            const relationLoan = collection.loan_request || null;

            const issuedAmountRaw =
              toNullableNumber(loan?.net_disbursed_amount) ??
              toNullableNumber(loan?.loan_amount) ??
              toNullableNumber(relationLoan?.net_disbursed_amount) ??
              toNullableNumber(relationLoan?.loan_amount) ??
              0;

            const storedBalance =
              toNullableNumber(loan?.loan_balance) ??
              toNullableNumber(relationLoan?.loan_balance);

            const derivedBalance = Math.max(
              issuedAmountRaw - Number(capitalCollectedByLoan.get(loanId) || 0),
              0
            );

            return {
              id: Number(collection.id),
              date: String(collection.collection_date || collection.created_at || ''),
              loanId,
              loanCode: String(loan?.loan_code || relationLoan?.loan_code || `LR-${loanId || 0}`),
              customerNo: String(loan?.customer_no || relationLoan?.customer_no || '-'),
              customerName: String(loan?.customer_name || relationLoan?.customer_name || '-'),
              fieldOfficer: String(loan?.field_officer || relationLoan?.field_officer || 'Unassigned'),
              loanAmount: issuedAmountRaw,
              loanBalance: storedBalance === null ? derivedBalance : storedBalance,
              collected: Number(collection.collected_amount || 0),
              capital: Number(collection.capital_amount || 0),
              interest: Number(collection.interest_amount || 0),
              penalty: Number(collection.penalty_amount || 0),
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

  const officerOptions = useMemo(() => {
    return Array.from(new Set(rows.map((row) => row.fieldOfficer))).sort((a, b) => a.localeCompare(b));
  }, [rows]);

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

      if (officerFilter !== 'all') {
        return row.fieldOfficer.toLowerCase() === officerFilter;
      }

      return true;
    });
  }, [rows, fromDate, toDate, officerFilter]);

  const officerSummaries = useMemo(() => {
    const map = new Map<string, {
      officer: string;
      transactions: number;
      collected: number;
      capital: number;
      interest: number;
      penalty: number;
      loanIds: Set<number>;
    }>();

    filteredRows.forEach((row) => {
      const key = row.fieldOfficer || 'Unassigned';
      const existing = map.get(key) || {
        officer: key,
        transactions: 0,
        collected: 0,
        capital: 0,
        interest: 0,
        penalty: 0,
        loanIds: new Set<number>(),
      };

      existing.transactions += 1;
      existing.collected += row.collected;
      existing.capital += row.capital;
      existing.interest += row.interest;
      existing.penalty += row.penalty;
      if (row.loanId) {
        existing.loanIds.add(row.loanId);
      }

      map.set(key, existing);
    });

    return Array.from(map.values())
      .map((item) => ({
        ...item,
        loanCount: item.loanIds.size,
      }))
      .sort((a, b) => b.collected - a.collected);
  }, [filteredRows]);

  const summary = useMemo(() => {
    const totals = filteredRows.reduce(
      (acc, row) => {
        acc.collected += row.collected;
        acc.capital += row.capital;
        acc.interest += row.interest;
        acc.penalty += row.penalty;
        return acc;
      },
      { collected: 0, capital: 0, interest: 0, penalty: 0 }
    );

    return {
      ...totals,
      transactionCount: filteredRows.length,
      officerCount: officerSummaries.length,
    };
  }, [filteredRows, officerSummaries.length]);

  const totalPages = Math.max(1, Math.ceil(filteredRows.length / pageSize));

  const pagedRows = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return filteredRows.slice(start, start + pageSize);
  }, [filteredRows, currentPage, pageSize]);

  useEffect(() => {
    setCurrentPage(1);
  }, [officerFilter, fromDate, toDate, pageSize]);

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
      'Field Officer',
      'Loan ID',
      'Loan Code',
      'Customer',
      'Loan Amount',
      'Loan Balance',
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
      row.fieldOfficer,
      row.loanId || '-',
      row.loanCode,
      row.customerName,
      formatMoney(row.loanAmount),
      formatMoney(row.loanBalance),
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
    link.download = `field-officer-collection-report-${getReportFileDate()}.csv`;
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

    const officerText = officerFilter === 'all' ? 'Officer: All' : `Officer: ${officerFilter}`;

    doc.setFontSize(16);
    doc.text('Field Officer Collection Report', 40, 40);
    doc.setFontSize(10);
    doc.text(`${dateFilterText} | ${officerText} | Generated: ${generatedAt}`, 40, 58);

    autoTable(doc, {
      startY: 72,
      head: [[
        'Date & Time',
        'Field Officer',
        'Loan ID',
        'Loan Code',
        'Customer',
        'Loan Amount',
        'Loan Balance',
        'Payment Type',
        'Reference',
        'Collected',
        'Capital',
        'Interest',
        'Penalty',
      ]],
      body: filteredRows.map((row) => [
        formatDateTime(row.date),
        row.fieldOfficer,
        row.loanId || '-',
        row.loanCode,
        row.customerName,
        formatMoney(row.loanAmount),
        formatMoney(row.loanBalance),
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
        fillColor: [2, 132, 199],
        textColor: [255, 255, 255],
      },
      alternateRowStyles: {
        fillColor: [241, 245, 249],
      },
      margin: { left: 24, right: 24, top: 72, bottom: 24 },
      theme: 'striped',
    });

    doc.save(`field-officer-collection-report-${getReportFileDate()}.pdf`);
  };

  if (!token || loading) {
    return (
      <div className="min-h-screen bg-[radial-gradient(circle_at_top,#dbeafe_0%,#ecfeff_45%,#f0fdfa_100%)] flex items-center justify-center">
        <div className="h-14 w-14 animate-spin rounded-full border-4 border-cyan-200 border-t-cyan-600 shadow-lg"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,#e0f2fe_0%,#ecfeff_35%,#f0fdfa_100%)] p-4 md:p-6 relative overflow-hidden">
      <div className="pointer-events-none absolute inset-0 opacity-50">
        <div className="absolute -top-24 left-10 h-80 w-80 rounded-full bg-sky-300/70 blur-3xl"></div>
        <div className="absolute top-24 right-4 h-96 w-96 rounded-full bg-cyan-300/60 blur-3xl"></div>
        <div className="absolute -bottom-10 left-1/3 h-80 w-80 rounded-full bg-emerald-300/55 blur-3xl"></div>
      </div>
      <div className="pointer-events-none absolute inset-0 opacity-20 [background-image:linear-gradient(to_right,rgba(8,145,178,0.15)_1px,transparent_1px),linear-gradient(to_bottom,rgba(8,145,178,0.15)_1px,transparent_1px)] [background-size:26px_26px]">
      </div>

      <div className="relative z-10 max-w-7xl mx-auto space-y-6">
        <div className="relative overflow-hidden bg-white/85 backdrop-blur-xl rounded-3xl border border-white/80 shadow-[0_24px_70px_-34px_rgba(14,116,144,0.5)] p-6 md:p-7">
          <div className="pointer-events-none absolute -right-24 -top-24 h-56 w-56 rounded-full bg-cyan-200/60 blur-3xl"></div>
          <div className="pointer-events-none absolute -left-16 bottom-0 h-40 w-40 rounded-full bg-emerald-200/60 blur-2xl"></div>
          <div className="flex items-center justify-between gap-4 flex-wrap">
            <div>
              <span className="inline-flex rounded-full bg-gradient-to-r from-cyan-600 to-sky-600 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.16em] text-white shadow">
                Reports Desk
              </span>
              <h1 className="text-2xl md:text-4xl font-black text-slate-900 mt-3 tracking-tight">Field Officer Collection Report</h1>
              <p className="text-sm text-slate-600 mt-1 max-w-2xl">Measure collection outcomes by officer with contribution trends, recovery quality, and portfolio discipline.</p>
            </div>
            <button
              onClick={() => router.back()}
              className="px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-700 text-white text-sm font-semibold shadow-md"
            >
              Back
            </button>
          </div>

          <div className="mt-5 grid grid-cols-1 md:grid-cols-3 xl:grid-cols-6 gap-3">
            <div className="rounded-2xl bg-gradient-to-br from-cyan-500 to-sky-600 border border-cyan-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-cyan-100">Transactions</p>
              <p className="text-base font-extrabold mt-1">{summary.transactionCount}</p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-indigo-500 to-blue-600 border border-indigo-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-indigo-100">Officers</p>
              <p className="text-base font-extrabold mt-1">{summary.officerCount}</p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 border border-emerald-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-emerald-100">Collected</p>
              <p className="text-sm font-extrabold mt-1">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.collected)}
              </p>
            </div>
            <div className="rounded-2xl bg-white/90 border border-cyan-100 shadow-sm p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Capital</p>
              <p className="text-sm font-extrabold text-slate-900 mt-1">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.capital)}
              </p>
            </div>
            <div className="rounded-2xl bg-white/90 border border-cyan-100 shadow-sm p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Interest</p>
              <p className="text-sm font-extrabold text-slate-900 mt-1">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.interest)}
              </p>
            </div>
            <div className="rounded-2xl bg-white/90 border border-rose-100 shadow-sm p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Penalty</p>
              <p className="text-sm font-extrabold text-rose-700 mt-1">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.penalty)}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white/88 backdrop-blur-xl rounded-3xl border border-cyan-100 shadow-[0_18px_48px_-24px_rgba(14,116,144,0.45)] p-4 md:p-5">
          <div className="flex items-center justify-between gap-3 flex-wrap">
            <h2 className="text-lg font-bold text-slate-900">Officer Performance Summary</h2>
            <div className="flex items-end gap-2 flex-wrap rounded-2xl bg-slate-50/80 border border-slate-100 p-2">
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
              <div>
                <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">Officer</label>
                <select
                  value={officerFilter}
                  onChange={(e) => setOfficerFilter(e.target.value)}
                  className="mt-1 px-3 py-2 rounded-xl border border-cyan-100 bg-white text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-cyan-200"
                >
                  <option value="all">All Officers</option>
                  {officerOptions.map((officer) => (
                    <option key={officer} value={officer.toLowerCase()}>
                      {officer}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">From Date</label>
                <input
                  type="date"
                  value={fromDate}
                  onChange={(e) => setFromDate(e.target.value)}
                  className="mt-1 px-3 py-2 rounded-xl border border-cyan-100 bg-white text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-cyan-200"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">To Date</label>
                <input
                  type="date"
                  value={toDate}
                  onChange={(e) => setToDate(e.target.value)}
                  className="mt-1 px-3 py-2 rounded-xl border border-cyan-100 bg-white text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-cyan-200"
                />
              </div>
              <button
                type="button"
                onClick={() => {
                  setOfficerFilter('all');
                  setFromDate('');
                  setToDate('');
                }}
                className="px-3 py-2 rounded-xl bg-white hover:bg-slate-100 text-slate-700 text-sm font-semibold border border-slate-200"
              >
                Reset
              </button>
            </div>
          </div>

          {officerSummaries.length === 0 ? (
            <div className="mt-4 rounded-2xl border border-cyan-100 bg-gradient-to-br from-cyan-100/60 to-teal-100/40 p-8 text-sm text-slate-700 text-center">
              No data found for selected filters.
            </div>
          ) : (
            <div className="mt-4 overflow-x-auto rounded-2xl border border-cyan-100 bg-white shadow-inner">
              <table className="min-w-full text-sm text-left text-slate-700 bg-white">
                <thead className="bg-gradient-to-r from-cyan-600 to-sky-600 text-white">
                  <tr>
                    <th className="px-3 py-2 font-semibold">Field Officer</th>
                    <th className="px-3 py-2 font-semibold">Transactions</th>
                    <th className="px-3 py-2 font-semibold">Loans Covered</th>
                    <th className="px-3 py-2 font-semibold">Collected</th>
                    <th className="px-3 py-2 font-semibold">Capital</th>
                    <th className="px-3 py-2 font-semibold">Interest</th>
                    <th className="px-3 py-2 font-semibold">Penalty</th>
                  </tr>
                </thead>
                <tbody>
                  {officerSummaries.map((item) => (
                    <tr key={item.officer} className="border-b border-cyan-100 last:border-b-0 odd:bg-white even:bg-cyan-50/30 hover:bg-cyan-50/60 transition-colors">
                      <td className="px-3 py-2 font-semibold text-slate-900">{item.officer}</td>
                      <td className="px-3 py-2">{item.transactions}</td>
                      <td className="px-3 py-2">{item.loanCount}</td>
                      <td className="px-3 py-2 font-semibold text-emerald-700">{formatMoney(item.collected)}</td>
                      <td className="px-3 py-2">{formatMoney(item.capital)}</td>
                      <td className="px-3 py-2">{formatMoney(item.interest)}</td>
                      <td className="px-3 py-2">{formatMoney(item.penalty)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        <div className="bg-white/88 backdrop-blur-xl rounded-3xl border border-cyan-100 shadow-[0_18px_48px_-24px_rgba(14,116,144,0.45)] p-4 md:p-5">
          <div className="flex items-center justify-between gap-3 flex-wrap">
            <h2 className="text-lg font-bold text-slate-900">Transaction Details</h2>
            <div className="flex items-center gap-2 text-sm text-slate-700">
              <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">Rows</label>
              <select
                value={pageSize}
                onChange={(e) => setPageSize(Number(e.target.value))}
                className="px-2.5 py-1.5 rounded-lg border border-cyan-100 bg-white text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-cyan-200"
              >
                <option value={10}>10</option>
                <option value={25}>25</option>
                <option value={50}>50</option>
                <option value={100}>100</option>
              </select>
            </div>
          </div>

          <div className="mt-3 rounded-xl border border-cyan-100 bg-gradient-to-r from-cyan-50/80 via-sky-50/70 to-emerald-50/70 px-3 py-2 text-xs sm:text-sm text-slate-600">
            Showing <span className="font-bold text-slate-800">{pagedRows.length}</span> of <span className="font-bold text-slate-800">{filteredRows.length}</span> transaction(s).
          </div>

          {filteredRows.length === 0 ? (
            <div className="mt-4 rounded-2xl border border-cyan-100 bg-gradient-to-br from-cyan-100/60 to-teal-100/40 p-8 text-sm text-slate-700 text-center">
              No transactions available.
            </div>
          ) : (
            <>
              <div className="mt-4 overflow-x-auto rounded-2xl border border-cyan-100 bg-white shadow-inner">
                <table className="min-w-full text-sm text-left text-slate-700 bg-white">
                  <thead className="bg-gradient-to-r from-slate-900 via-slate-800 to-cyan-800 text-white sticky top-0">
                    <tr>
                      <th className="px-3 py-2 font-semibold">Date & Time</th>
                      <th className="px-3 py-2 font-semibold">Field Officer</th>
                      <th className="px-3 py-2 font-semibold">Loan ID</th>
                      <th className="px-3 py-2 font-semibold">Loan Code</th>
                      <th className="px-3 py-2 font-semibold">Customer</th>
                      <th className="px-3 py-2 font-semibold">Loan Amount</th>
                      <th className="px-3 py-2 font-semibold">Loan Balance</th>
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
                      <tr key={row.id} className="border-b border-cyan-100 last:border-b-0 odd:bg-white even:bg-cyan-50/25 hover:bg-cyan-50/60 transition-colors">
                        <td className="px-3 py-2">{formatDateTime(row.date)}</td>
                        <td className="px-3 py-2">{row.fieldOfficer}</td>
                        <td className="px-3 py-2">{row.loanId || '-'}</td>
                        <td className="px-3 py-2 font-semibold text-slate-900">{row.loanCode}</td>
                        <td className="px-3 py-2">{row.customerName}</td>
                        <td className="px-3 py-2">{formatMoney(row.loanAmount)}</td>
                        <td className="px-3 py-2">{formatMoney(row.loanBalance)}</td>
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

              <div className="mt-3 flex items-center justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
                  disabled={currentPage <= 1}
                  className="px-3 py-1.5 rounded-lg bg-white border border-slate-200 hover:bg-slate-100 text-slate-700 text-sm font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                <span className="text-sm text-white font-semibold rounded-md bg-slate-800 px-2.5 py-1">Page {currentPage} of {totalPages}</span>
                <button
                  type="button"
                  onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
                  disabled={currentPage >= totalPages}
                  className="px-3 py-1.5 rounded-lg bg-white border border-slate-200 hover:bg-slate-100 text-slate-700 text-sm font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
