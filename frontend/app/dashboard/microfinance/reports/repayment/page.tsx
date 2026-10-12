'use client';

import axios from 'axios';
import { useEffect, useMemo, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

type LoanRow = {
  id: number;
  customer_no?: string | null;
  customer_name?: string | null;
  field_officer?: string | null;
  status?: string | null;
  refundable_amount?: number | string | null;
  loan_amount?: number | string | null;
  loan_balance?: number | string | null;
  due_date?: string | null;
  next_payment_date?: string | null;
};

type CollectionRow = {
  mf_loan_request_id: number | string;
  collected_amount?: number | string | null;
};

type RepaymentRow = {
  loanId: number;
  customerNo: string;
  customerName: string;
  fieldOfficer: string;
  loanStatus: string;
  loanAmount: number;
  refundableAmount: number;
  collectedAmount: number;
  outstandingAmount: number;
  repaymentRate: number;
  dueDate: string;
  nextPaymentDate: string;
  overdueDays: number;
  repaymentStatus: 'excellent' | 'good' | 'watch' | 'critical';
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

const normalizeDateOnly = (value?: string | null) => {
  const parts = parseDateOnlyParts(value);
  if (!parts) return '';
  const year = String(parts.year).padStart(4, '0');
  const month = String(parts.month).padStart(2, '0');
  const day = String(parts.day).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const diffDateOnlyInDays = (fromDate: string, toDate: string) => {
  const from = parseDateOnlyParts(fromDate);
  const to = parseDateOnlyParts(toDate);
  if (!from || !to) return null;

  const fromUtc = Date.UTC(from.year, from.month - 1, from.day);
  const toUtc = Date.UTC(to.year, to.month - 1, to.day);
  return Math.floor((toUtc - fromUtc) / (1000 * 60 * 60 * 24));
};

const getTodayDateOnly = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

export default function RepaymentReportPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [token, setToken] = useState('');
  const [loading, setLoading] = useState(true);
  const [rows, setRows] = useState<RepaymentRow[]>([]);
  const [officerFilter, setOfficerFilter] = useState('all');
  const [repaymentFilter, setRepaymentFilter] = useState<'all' | 'excellent' | 'good' | 'watch' | 'critical'>('all');

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

        const paidByLoan = new Map<number, number>();
        collections.forEach((collection) => {
          const loanId = Number(collection.mf_loan_request_id || 0);
          if (!loanId) return;
          paidByLoan.set(loanId, (paidByLoan.get(loanId) || 0) + Number(collection.collected_amount || 0));
        });

        const todayDateOnly = getTodayDateOnly();

        const mapped: RepaymentRow[] = loans
          .filter((loan) => {
            const status = String(loan.status || '').toLowerCase();
            return status === 'approved' || status === 'released' || status === 'completed';
          })
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
            const repaymentRate = refundableAmount > 0 ? (collectedAmount / refundableAmount) * 100 : 0;

            const dueDateText = normalizeDateOnly(loan.due_date);
            const nextPaymentDateText = normalizeDateOnly(loan.next_payment_date);
            const effectiveDueDateText = dueDateText || nextPaymentDateText;
            const dayDiff =
              effectiveDueDateText && outstandingAmount > 0
                ? diffDateOnlyInDays(effectiveDueDateText, todayDateOnly)
                : null;
            const overdueDays =
              dayDiff !== null && outstandingAmount > 0
                ? Math.max(dayDiff, 0)
                : 0;

            let repaymentStatus: RepaymentRow['repaymentStatus'] = 'good';
            if (repaymentRate >= 90) repaymentStatus = 'excellent';
            else if (repaymentRate >= 70) repaymentStatus = 'good';
            else if (repaymentRate >= 40 || overdueDays <= 15) repaymentStatus = 'watch';
            else repaymentStatus = 'critical';

            return {
              loanId,
              customerNo: String(loan.customer_no || '-'),
              customerName: String(loan.customer_name || '-'),
              fieldOfficer: String(loan.field_officer || 'Unassigned'),
              loanStatus: String(loan.status || '-'),
              loanAmount: Number(loan.loan_amount || 0),
              refundableAmount,
              collectedAmount,
              outstandingAmount,
              repaymentRate,
              dueDate: effectiveDueDateText || '-',
              nextPaymentDate: nextPaymentDateText || '-',
              overdueDays,
              repaymentStatus,
            };
          })
          .filter((row) => row.outstandingAmount > 0)
          .sort((a, b) => b.outstandingAmount - a.outstandingAmount);

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
    return rows.filter((row) => {
      if (officerFilter !== 'all' && row.fieldOfficer.toLowerCase() !== officerFilter) {
        return false;
      }

      if (repaymentFilter !== 'all' && row.repaymentStatus !== repaymentFilter) {
        return false;
      }

      return true;
    });
  }, [rows, officerFilter, repaymentFilter]);

  const summary = useMemo(() => {
    return filteredRows.reduce(
      (acc, row) => {
        acc.count += 1;
        acc.loanAmount += row.loanAmount;
        acc.refundable += row.refundableAmount;
        acc.collected += row.collectedAmount;
        acc.outstanding += row.outstandingAmount;
        acc.repaymentRate += row.repaymentRate;
        if (row.repaymentStatus === 'excellent') acc.excellent += 1;
        if (row.repaymentStatus === 'good') acc.good += 1;
        if (row.repaymentStatus === 'watch') acc.watch += 1;
        if (row.repaymentStatus === 'critical') acc.critical += 1;
        return acc;
      },
      {
        count: 0,
        loanAmount: 0,
        refundable: 0,
        collected: 0,
        outstanding: 0,
        repaymentRate: 0,
        excellent: 0,
        good: 0,
        watch: 0,
        critical: 0,
      }
    );
  }, [filteredRows]);

  const averageRepaymentRate = summary.count > 0 ? summary.repaymentRate / summary.count : 0;

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
      'Customer No',
      'Customer Name',
      'Field Officer',
      'Loan Status',
      'Loan Amount',
      'Refundable Amount',
      'Collected Amount',
      'Outstanding Amount',
      'Repayment Rate (%)',
      'Due Date',
      'Next Payment Date',
      'Overdue Days',
      'Repayment Status',
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
      row.customerNo,
      row.customerName,
      row.fieldOfficer,
      row.loanStatus,
      formatMoney(row.loanAmount),
      formatMoney(row.refundableAmount),
      formatMoney(row.collectedAmount),
      formatMoney(row.outstandingAmount),
      row.repaymentRate.toFixed(2),
      formatDate(row.dueDate),
      formatDate(row.nextPaymentDate),
      row.overdueDays,
      row.repaymentStatus,
    ]);

    const csv = [headers, ...body].map((line) => line.map(escapeCsv).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `repayment-report-${getReportFileDate()}.csv`;
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
    const statusText = `Repayment Status: ${repaymentFilter}`;

    doc.setFontSize(16);
    doc.text('Re-Payment Report', 40, 40);
    doc.setFontSize(10);
    doc.text(`${officerText} | ${statusText} | Generated: ${generatedAt}`, 40, 58);

    autoTable(doc, {
      startY: 72,
      head: [[
        'Loan ID',
        'Customer No',
        'Customer',
        'Officer',
        'Refundable',
        'Collected',
        'Outstanding',
        'Rate %',
        'Overdue Days',
        'Status',
      ]],
      body: filteredRows.map((row) => [
        row.loanId,
        row.customerNo,
        row.customerName,
        row.fieldOfficer,
        formatMoney(row.refundableAmount),
        formatMoney(row.collectedAmount),
        formatMoney(row.outstandingAmount),
        row.repaymentRate.toFixed(2),
        row.overdueDays,
        row.repaymentStatus,
      ]),
      styles: {
        fontSize: 8,
        cellPadding: 4,
      },
      headStyles: {
        fillColor: [67, 56, 202],
        textColor: [255, 255, 255],
      },
      alternateRowStyles: {
        fillColor: [238, 242, 255],
      },
      margin: { left: 24, right: 24, top: 72, bottom: 24 },
      theme: 'striped',
    });

    doc.save(`repayment-report-${getReportFileDate()}.pdf`);
  };

  if (!token || loading) {
    return (
      <div className="min-h-screen bg-[radial-gradient(circle_at_top,#e0f2fe_0%,#ecfeff_45%,#f0fdfa_100%)] flex items-center justify-center">
        <div className="h-14 w-14 animate-spin rounded-full border-4 border-cyan-200 border-t-cyan-600 shadow-lg"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,#dbeafe_0%,#ecfeff_35%,#f0fdfa_100%)] p-4 md:p-6 relative overflow-hidden">
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
          <div className="pointer-events-none absolute -left-16 bottom-0 h-40 w-40 rounded-full bg-amber-200/50 blur-2xl"></div>
          <div className="flex items-center justify-between gap-4 flex-wrap">
            <div>
              <span className="inline-flex rounded-full bg-gradient-to-r from-cyan-600 to-sky-600 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.16em] text-white shadow">
                Reports Desk
              </span>
              <h1 className="text-2xl md:text-4xl font-black text-slate-900 mt-3 tracking-tight">Re-Payment Report</h1>
              <p className="text-sm text-slate-600 mt-1 max-w-2xl">Review repayment performance, overdue pressure, and recovery progress by account.</p>
            </div>
            <button
              onClick={() => router.back()}
              className="px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-700 text-white text-sm font-semibold shadow-md"
            >
              Back
            </button>
          </div>

          <div className="mt-5 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-6 gap-3">
            <div className="rounded-2xl bg-gradient-to-br from-cyan-500 to-sky-600 border border-cyan-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-cyan-100">Active Accounts</p>
              <p className="text-[14px] font-extrabold mt-1">{summary.count}</p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-amber-500 to-orange-600 border border-amber-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-amber-100">Refundable</p>
              <p className="text-[14px] font-extrabold mt-1">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.refundable)}
              </p>
            </div>
            <div className="rounded-2xl bg-white/90 border border-emerald-100 shadow-sm p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Collected</p>
              <p className="text-[14px] font-extrabold text-emerald-700 mt-1">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.collected)}
              </p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-rose-500 to-red-600 border border-rose-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-rose-100">Outstanding</p>
              <p className="text-[14px] font-extrabold mt-1">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.outstanding)}
              </p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-violet-500 to-indigo-600 border border-violet-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-violet-100">Avg Repayment %</p>
              <p className="text-[14px] font-extrabold mt-1">{averageRepaymentRate.toFixed(2)}%</p>
            </div>
            <div className="rounded-2xl bg-white/90 border border-cyan-100 shadow-sm p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Excellent / Critical</p>
              <p className="text-[14px] font-extrabold text-slate-900 mt-1">{summary.excellent} / {summary.critical}</p>
            </div>
          </div>
        </div>

        <div className="bg-white/88 backdrop-blur-xl rounded-3xl border border-cyan-100 shadow-[0_18px_48px_-24px_rgba(14,116,144,0.45)] p-4 md:p-5">
          <div className="flex items-center justify-between gap-3 flex-wrap">
            <h2 className="text-lg font-bold text-slate-900">Repayment Accounts</h2>
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
                <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">Repayment</label>
                <select
                  value={repaymentFilter}
                  onChange={(e) => setRepaymentFilter(e.target.value as 'all' | 'excellent' | 'good' | 'watch' | 'critical')}
                  className="mt-1 px-3 py-2 rounded-xl border border-cyan-100 bg-white text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-cyan-200"
                >
                  <option value="all">All</option>
                  <option value="excellent">Excellent</option>
                  <option value="good">Good</option>
                  <option value="watch">Watch</option>
                  <option value="critical">Critical</option>
                </select>
              </div>
              <button
                type="button"
                onClick={() => {
                  setOfficerFilter('all');
                  setRepaymentFilter('all');
                }}
                className="px-3 py-2 rounded-xl bg-white hover:bg-slate-100 text-slate-700 text-sm font-semibold border border-slate-200"
              >
                Reset
              </button>
            </div>
          </div>

          {filteredRows.length === 0 ? (
            <div className="mt-4 rounded-2xl border border-cyan-100 bg-gradient-to-br from-cyan-100/60 to-teal-100/40 p-8 text-sm text-slate-700 text-center">
              No repayment data found for selected filters.
            </div>
          ) : (
            <div className="mt-4 overflow-x-auto rounded-2xl border border-cyan-100 bg-white shadow-inner">
              <table className="min-w-full text-sm text-left text-slate-700 bg-white">
                <thead className="bg-gradient-to-r from-slate-900 via-slate-800 to-cyan-800 text-white sticky top-0">
                  <tr>
                    <th className="px-3 py-2 font-semibold">Loan ID</th>
                    <th className="px-3 py-2 font-semibold">Customer No</th>
                    <th className="px-3 py-2 font-semibold">Customer</th>
                    <th className="px-3 py-2 font-semibold">Field Officer</th>
                    <th className="px-3 py-2 font-semibold">Loan Status</th>
                    <th className="px-3 py-2 font-semibold">Refundable</th>
                    <th className="px-3 py-2 font-semibold">Collected</th>
                    <th className="px-3 py-2 font-semibold">Outstanding</th>
                    <th className="px-3 py-2 font-semibold">Repayment %</th>
                    <th className="px-3 py-2 font-semibold">Due Date</th>
                    <th className="px-3 py-2 font-semibold">Next Payment</th>
                    <th className="px-3 py-2 font-semibold">Overdue Days</th>
                    <th className="px-3 py-2 font-semibold">Repayment Status</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredRows.map((row) => (
                    <tr key={row.loanId} className="border-b border-cyan-100 last:border-b-0 odd:bg-white even:bg-cyan-50/25 hover:bg-cyan-50/60 transition-colors">
                      <td className="px-3 py-2">{row.loanId}</td>
                      <td className="px-3 py-2 font-semibold text-slate-900">{row.customerNo}</td>
                      <td className="px-3 py-2">{row.customerName}</td>
                      <td className="px-3 py-2">{row.fieldOfficer}</td>
                      <td className="px-3 py-2 capitalize">{row.loanStatus}</td>
                      <td className="px-3 py-2">{formatMoney(row.refundableAmount)}</td>
                      <td className="px-3 py-2 text-emerald-700 font-semibold">{formatMoney(row.collectedAmount)}</td>
                      <td className="px-3 py-2 text-rose-700 font-semibold">{formatMoney(row.outstandingAmount)}</td>
                      <td className="px-3 py-2 font-semibold text-indigo-700">{row.repaymentRate.toFixed(2)}%</td>
                      <td className="px-3 py-2">{formatDate(row.dueDate)}</td>
                      <td className="px-3 py-2">{formatDate(row.nextPaymentDate)}</td>
                      <td className="px-3 py-2">{row.overdueDays}</td>
                      <td className="px-3 py-2">
                        <span className={`inline-flex rounded-full border px-2 py-0.5 text-xs font-semibold capitalize ${
                          row.repaymentStatus === 'excellent'
                            ? 'border-emerald-200 bg-emerald-50 text-emerald-800'
                            : row.repaymentStatus === 'good'
                            ? 'border-cyan-200 bg-cyan-50 text-cyan-800'
                            : row.repaymentStatus === 'watch'
                            ? 'border-amber-200 bg-amber-50 text-amber-800'
                            : 'border-rose-200 bg-rose-50 text-rose-800'
                        }`}>
                          {row.repaymentStatus}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
