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
  status?: string | null;
  loan_amount?: number | string | null;
  loan_balance?: number | string | null;
  refundable_amount?: number | string | null;
  installment_amount?: number | string | null;
  arrears_balance?: number | string | null;
  due_date?: string | null;
  next_payment_date?: string | null;
};

type CollectionRow = {
  mf_loan_request_id: number | string;
  collected_amount?: number | string | null;
};

type ReportRow = {
  loanId: number;
  loanCode: string;
  customerNo: string;
  customerName: string;
  fieldOfficer: string;
  status: string;
  loanAmount: number;
  installmentAmount: number;
  refundableAmount: number;
  collectedAmount: number;
  outstandingAmount: number;
  arrearsAmount: number;
  dueDate: string;
  nextCollectionDate: string;
};

const API_BASE = 'http://localhost:8000/api';

const getTodayDateOnly = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const getTomorrowDateOnly = () => {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const year = tomorrow.getFullYear();
  const month = String(tomorrow.getMonth() + 1).padStart(2, '0');
  const day = String(tomorrow.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const normalizeDateOnly = (value?: string | null) => {
  const raw = String(value || '').trim();
  if (!raw) return '';

  const datePart = raw.includes('T') ? raw.split('T')[0] : raw.slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(datePart) ? datePart : '';
};

const normalizeText = (value: string) =>
  String(value || '')
    .toLowerCase()
    .trim()
    .replace(/\s+/g, ' ');

export default function NextCollectionReportPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [token, setToken] = useState('');
  const [loading, setLoading] = useState(true);
  const [rows, setRows] = useState<ReportRow[]>([]);
  const [officerOptions, setOfficerOptions] = useState<string[]>([]);
  const [keyword, setKeyword] = useState('');
  const [officerFilter, setOfficerFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [nextCollectionDate, setNextCollectionDate] = useState(() => getTomorrowDateOnly());

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

        const activeLoans = loans.filter((loan) => {
          const status = String(loan.status || '').toLowerCase();
          return status === 'approved' || status === 'released' || status === 'completed';
        });

        const officers = Array.from(
          new Set(
            activeLoans
              .map((loan) => String(loan.field_officer || '').trim())
              .filter((name) => name !== '')
          )
        ).sort((a, b) => a.localeCompare(b));
        setOfficerOptions(officers);

        const paidByLoan = new Map<number, number>();
        collections.forEach((collection) => {
          const loanId = Number(collection.mf_loan_request_id || 0);
          if (!loanId) return;
          paidByLoan.set(loanId, (paidByLoan.get(loanId) || 0) + Number(collection.collected_amount || 0));
        });

        const mapped = activeLoans
          .map((loan) => {
            const loanId = Number(loan.id || 0);
            const refundableAmount = Number(loan.refundable_amount || 0);
            const collectedAmount = paidByLoan.get(loanId) || 0;
            const fallbackOutstandingAmount = Math.max(refundableAmount - collectedAmount, 0);
            const rawLoanBalance = loan.loan_balance;
            const hasLoanBalance =
              rawLoanBalance !== null &&
              typeof rawLoanBalance !== 'undefined' &&
              String(rawLoanBalance).trim() !== '';
            const loanBalance = Number(rawLoanBalance);
            const outstandingAmount =
              hasLoanBalance && Number.isFinite(loanBalance)
                ? Math.max(loanBalance, 0)
                : fallbackOutstandingAmount;
            const dueDate = normalizeDateOnly(loan.due_date);
            const nextPaymentDate = normalizeDateOnly(loan.next_payment_date);
            const targetNextCollectionDate = nextPaymentDate || dueDate;

            return {
              loanId,
              loanCode: String(loan.loan_code || '').trim() || `LR-${loanId}`,
              customerNo: String(loan.customer_no || '-'),
              customerName: String(loan.customer_name || '-'),
              fieldOfficer: String(loan.field_officer || 'Unassigned').trim() || 'Unassigned',
              status: String(loan.status || '-'),
              loanAmount: Number(loan.loan_amount || 0),
              installmentAmount: Number(loan.installment_amount || 0),
              refundableAmount,
              collectedAmount,
              outstandingAmount,
              arrearsAmount: Math.max(Number(loan.arrears_balance || 0), 0),
              dueDate: dueDate || '-',
              nextCollectionDate: targetNextCollectionDate || '-',
            } as ReportRow;
          })
          .filter((row) => row.nextCollectionDate !== '-' && row.nextCollectionDate === nextCollectionDate)
          .filter((row) => row.outstandingAmount > 0)
          .sort((a, b) => b.outstandingAmount - a.outstandingAmount);

        setRows(mapped);
      } catch {
        setRows([]);
        setOfficerOptions([]);
      } finally {
        setLoading(false);
      }
    };

    loadReport();
  }, [token, branchId, nextCollectionDate]);

  const filteredRows = useMemo(() => {
    const search = keyword.trim().toLowerCase();
    const normalizedOfficerFilter = normalizeText(officerFilter);

    return rows.filter((row) => {
      if (officerFilter !== 'all') {
        const normalizedOfficer = normalizeText(row.fieldOfficer);
        const isExactMatch = normalizedOfficer === normalizedOfficerFilter;
        const isContainsMatch =
          normalizedOfficer.includes(normalizedOfficerFilter) || normalizedOfficerFilter.includes(normalizedOfficer);

        if (!isExactMatch && !isContainsMatch) {
          return false;
        }
      }

      if (!search) return true;

      const haystack = [row.loanCode, row.customerNo, row.customerName, row.fieldOfficer]
        .join(' ')
        .toLowerCase();

      return haystack.includes(search);
    });
  }, [rows, keyword, officerFilter]);

  useEffect(() => {
    if (officerFilter === 'all') return;

    const normalizedOptions = new Set(officerOptions.map((officer) => normalizeText(officer)));
    if (!normalizedOptions.has(normalizeText(officerFilter))) {
      setOfficerFilter('all');
    }
  }, [officerOptions, officerFilter]);

  useEffect(() => {
    setCurrentPage(1);
  }, [keyword, officerFilter, pageSize, nextCollectionDate]);

  const totalPages = useMemo(() => {
    return Math.max(1, Math.ceil(filteredRows.length / pageSize));
  }, [filteredRows.length, pageSize]);

  useEffect(() => {
    setCurrentPage((prev) => Math.min(prev, totalPages));
  }, [totalPages]);

  const pagedRows = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return filteredRows.slice(start, start + pageSize);
  }, [filteredRows, currentPage, pageSize]);

  const summary = useMemo(() => {
    return filteredRows.reduce(
      (acc, row) => {
        acc.loanCount += 1;
        acc.loanAmount += row.loanAmount;
        acc.collected += row.collectedAmount;
        acc.outstanding += row.outstandingAmount;
        acc.installment += row.installmentAmount;
        acc.arrears += row.arrearsAmount;
        return acc;
      },
      {
        loanCount: 0,
        loanAmount: 0,
        collected: 0,
        outstanding: 0,
        installment: 0,
        arrears: 0,
      }
    );
  }, [filteredRows]);

  const formatMoney = (value: number) => Number(value || 0).toFixed(2);

  const formatDate = (value: string) => {
    if (!value || value === '-') return '-';
    const parsed = new Date(`${value}T00:00:00`);
    if (Number.isNaN(parsed.getTime())) return value;

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
      'Status',
      'Loan Amount',
      'Installment',
      'Collected',
      'Outstanding',
      'Arrears',
      'Due Date',
      'Next Collection Date',
    ];

    const escapeCsv = (value: string | number) => {
      const text = String(value ?? '');
      if (text.includes(',') || text.includes('"') || text.includes('\n')) {
        return `"${text.replace(/"/g, '""')}"`;
      }
      return text;
    };

    const body = filteredRows.map((row) => [
      row.loanId,
      row.loanCode,
      row.customerNo,
      row.customerName,
      row.fieldOfficer,
      row.status,
      formatMoney(row.loanAmount),
      formatMoney(row.installmentAmount),
      formatMoney(row.collectedAmount),
      formatMoney(row.outstandingAmount),
      formatMoney(row.arrearsAmount),
      formatDate(row.dueDate),
      formatDate(row.nextCollectionDate),
    ]);

    const csv = [headers, ...body].map((line) => line.map(escapeCsv).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `next-collection-report-${nextCollectionDate || getReportFileDate()}.csv`;
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

    const officerText = officerFilter === 'all' ? 'Officer: All' : `Officer: ${officerFilter}`;
    const keywordText = keyword.trim() ? `Search: ${keyword.trim()}` : 'Search: All';

    doc.setFontSize(16);
    doc.text('Next Collection Report', 40, 40);
    doc.setFontSize(10);
    doc.text(`Next Collection Date: ${nextCollectionDate} | ${officerText} | ${keywordText} | Generated: ${generatedAt}`, 40, 58);

    autoTable(doc, {
      startY: 72,
      head: [[
        'Loan ID',
        'Loan Code',
        'Customer No',
        'Customer',
        'Officer',
        'Status',
        'Loan',
        'Installment',
        'Collected',
        'Outstanding',
        'Arrears',
        'Due Date',
        'Next Collection',
      ]],
      body: filteredRows.map((row) => [
        row.loanId,
        row.loanCode,
        row.customerNo,
        row.customerName,
        row.fieldOfficer,
        row.status,
        formatMoney(row.loanAmount),
        formatMoney(row.installmentAmount),
        formatMoney(row.collectedAmount),
        formatMoney(row.outstandingAmount),
        formatMoney(row.arrearsAmount),
        formatDate(row.dueDate),
        formatDate(row.nextCollectionDate),
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

    doc.save(`next-collection-report-${nextCollectionDate || getReportFileDate()}.pdf`);
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
              <h1 className="mt-3 text-2xl md:text-4xl font-black tracking-tight text-slate-900">Next Collection Report</h1>
              <p className="mt-1 max-w-2xl text-sm text-slate-600">Check which loans must be collected on the selected next collection date.</p>
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
                value={keyword}
                onChange={(e) => setKeyword(e.target.value)}
                placeholder="Loan code, customer no, customer name"
                className="mt-1 w-full rounded-xl border border-cyan-100 bg-white px-3 py-2.5 text-sm text-black focus:outline-none focus:ring-2 focus:ring-cyan-200"
              />
            </div>
            <div>
              <label className="text-xs font-semibold uppercase tracking-wide text-slate-500">Field Officer</label>
              <select
                value={officerFilter}
                onChange={(e) => setOfficerFilter(e.target.value)}
                className="mt-1 w-full rounded-xl border border-cyan-100 bg-white px-3 py-2.5 text-sm text-black focus:outline-none focus:ring-2 focus:ring-cyan-200"
              >
                <option value="all">All Officers</option>
                {officerOptions.map((officer) => (
                  <option key={officer} value={normalizeText(officer)}>
                    {officer}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-xs font-semibold uppercase tracking-wide text-slate-500">Next Collection Date</label>
              <input
                type="date"
                value={nextCollectionDate}
                onChange={(e) => setNextCollectionDate(e.target.value)}
                className="mt-1 w-full rounded-xl border border-cyan-100 bg-white px-3 py-2.5 text-sm text-black focus:outline-none focus:ring-2 focus:ring-cyan-200"
              />
            </div>
          </div>

          <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
            <div className="rounded-2xl border border-cyan-300/40 bg-gradient-to-br from-cyan-500 to-sky-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-cyan-100">Loans</p>
              <p className="mt-1 text-[14px] font-extrabold">{summary.loanCount}</p>
            </div>
            <div className="rounded-2xl border border-indigo-300/40 bg-gradient-to-br from-indigo-500 to-blue-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-indigo-100">Installment</p>
              <p className="mt-1 text-[14px] font-extrabold break-words tabular-nums">{formatMoney(summary.installment)}</p>
            </div>
            <div className="rounded-2xl border border-emerald-300/40 bg-gradient-to-br from-emerald-500 to-teal-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-emerald-100">Collected</p>
              <p className="mt-1 text-[14px] font-extrabold break-words tabular-nums">{formatMoney(summary.collected)}</p>
            </div>
            <div className="rounded-2xl border border-rose-300/40 bg-gradient-to-br from-rose-500 to-red-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-rose-100">Outstanding</p>
              <p className="mt-1 text-[14px] font-extrabold break-words tabular-nums">{formatMoney(summary.outstanding)}</p>
            </div>
            <div className="rounded-2xl border border-amber-300/40 bg-gradient-to-br from-amber-500 to-orange-600 p-4 text-white shadow-md">
              <p className="text-xs uppercase tracking-wide text-amber-100">Arrears</p>
              <p className="mt-1 text-[14px] font-extrabold break-words tabular-nums">{formatMoney(summary.arrears)}</p>
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
          ) : filteredRows.length === 0 ? (
            <div className="mt-2 rounded-2xl border border-cyan-100 bg-gradient-to-br from-cyan-100/60 to-teal-100/40 p-8 text-center text-sm text-slate-700">
              No next-day collection loans found for selected date.
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
                      <th className="px-3 py-2 font-semibold">Status</th>
                      <th className="px-3 py-2 font-semibold">Installment</th>
                      <th className="px-3 py-2 font-semibold">Collected</th>
                      <th className="px-3 py-2 font-semibold">Outstanding</th>
                      <th className="px-3 py-2 font-semibold">Arrears</th>
                      <th className="px-3 py-2 font-semibold">Due Date</th>
                      <th className="px-3 py-2 font-semibold">Next Collection</th>
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
                        <td className="px-3 py-2 capitalize">{row.status}</td>
                        <td className="px-3 py-2">{formatMoney(row.installmentAmount)}</td>
                        <td className="px-3 py-2 text-emerald-700 font-semibold tabular-nums">{formatMoney(row.collectedAmount)}</td>
                        <td className="px-3 py-2 text-rose-700 font-semibold tabular-nums">{formatMoney(row.outstandingAmount)}</td>
                        <td className="px-3 py-2 text-orange-700 font-semibold tabular-nums">{formatMoney(row.arrearsAmount)}</td>
                        <td className="px-3 py-2">{formatDate(row.dueDate)}</td>
                        <td className="px-3 py-2">{formatDate(row.nextCollectionDate)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="mt-3 flex flex-wrap items-center justify-between gap-3 text-sm text-slate-600">
                <div>
                  Showing {filteredRows.length === 0 ? 0 : (currentPage - 1) * pageSize + 1}
                  {' '}
                  to {Math.min(currentPage * pageSize, filteredRows.length)} of {filteredRows.length}
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
      </div>
    </div>
  );
}
