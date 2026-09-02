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
  refundable_amount?: number | string | null;
  loan_amount?: number | string | null;
  installment_amount?: number | string | null;
  loan_balance?: number | string | null;
  arrears_balance?: number | string | null;
  due_date?: string | null;
  next_payment_date?: string | null;
};

type CollectionRow = {
  mf_loan_request_id: number | string;
  collected_amount?: number | string | null;
  penalty_amount?: number | string | null;
};

type RecoveryRow = {
  loanId: number;
  loanCode: string;
  customerNo: string;
  customerName: string;
  fieldOfficer: string;
  loanStatus: string;
  loanAmount: number;
  loanBalance: number;
  refundableAmount: number;
  collectedAmount: number;
  penaltyAmount: number;
  pendingAmount: number;
  arrearsAmount: number;
  dueDate: string;
  nextPaymentDate: string;
  overdueDays: number;
  recoveryPriority: 'urgent' | 'high' | 'medium' | 'low';
};

const API_BASE = 'http://localhost:8000/api';

export default function RecoveryReportPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [token, setToken] = useState('');
  const [loading, setLoading] = useState(true);
  const [rows, setRows] = useState<RecoveryRow[]>([]);
  const [officerFilter, setOfficerFilter] = useState('all');
  const [priorityFilter, setPriorityFilter] = useState<'all' | 'urgent' | 'high' | 'medium' | 'low'>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);

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
        const penaltyByLoan = new Map<number, number>();
        collections.forEach((collection) => {
          const loanId = Number(collection.mf_loan_request_id || 0);
          if (!loanId) return;
          paidByLoan.set(loanId, (paidByLoan.get(loanId) || 0) + Number(collection.collected_amount || 0));
          penaltyByLoan.set(loanId, (penaltyByLoan.get(loanId) || 0) + Number(collection.penalty_amount || 0));
        });

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const mapped: RecoveryRow[] = loans
          .filter((loan) => {
            const status = String(loan.status || '').toLowerCase();
            return status === 'approved' || status === 'released' || status === 'completed';
          })
          .map((loan) => {
            const loanId = Number(loan.id || 0);
            const refundableAmount = Number(loan.refundable_amount || 0);
            const collectedAmount = paidByLoan.get(loanId) || 0;
            const penaltyAmount = Math.max(penaltyByLoan.get(loanId) || 0, 0);
            const pendingAmount = Math.max(refundableAmount - collectedAmount, 0);
            const rawLoanBalance = Number(loan.loan_balance || 0);
            const loanBalance = rawLoanBalance > 0 ? rawLoanBalance : pendingAmount;

            const dueDateText = String(loan.due_date || '').slice(0, 10);
            const dueDate = dueDateText ? new Date(`${dueDateText}T00:00:00`) : null;
            const overdueDays =
              dueDate && !Number.isNaN(dueDate.getTime()) && pendingAmount > 0
                ? Math.max(Math.floor((today.getTime() - dueDate.getTime()) / (1000 * 60 * 60 * 24)), 0)
                : 0;

            const rawArrearsAmount = Math.max(Number(loan.arrears_balance || 0), 0);
            const installmentAmount = Math.max(Number(loan.installment_amount || 0), 0);
            const scheduledArrearsAmount = overdueDays > 0 ? overdueDays * installmentAmount : 0;
            const arrearsBaseAmount = scheduledArrearsAmount > 0 ? scheduledArrearsAmount : rawArrearsAmount;
            const arrearsAmount = Math.min(arrearsBaseAmount, pendingAmount);

            let recoveryPriority: RecoveryRow['recoveryPriority'] = 'low';
            if (arrearsAmount >= 100000 || overdueDays >= 60 || pendingAmount >= 500000) {
              recoveryPriority = 'urgent';
            } else if (arrearsAmount > 0 || overdueDays >= 30 || pendingAmount >= 250000) {
              recoveryPriority = 'high';
            } else if (overdueDays > 0 || pendingAmount > 0) {
              recoveryPriority = 'medium';
            }

            return {
              loanId,
              loanCode: String(loan.loan_code || loan.customer_no || `LR-${loanId || 0}`),
              customerNo: String(loan.customer_no || '-'),
              customerName: String(loan.customer_name || '-'),
              fieldOfficer: String(loan.field_officer || 'Unassigned'),
              loanStatus: String(loan.status || '-'),
              loanAmount: Number(loan.loan_amount || 0),
              loanBalance,
              refundableAmount,
              collectedAmount,
              penaltyAmount,
              pendingAmount,
              arrearsAmount,
              dueDate: dueDateText || '-',
              nextPaymentDate: String(loan.next_payment_date || '').slice(0, 10) || '-',
              overdueDays,
              recoveryPriority,
            };
          })
          .filter((row) => row.pendingAmount > 0 || row.arrearsAmount > 0)
          .sort((a, b) => {
            const rank = { urgent: 4, high: 3, medium: 2, low: 1 };
            if (rank[b.recoveryPriority] !== rank[a.recoveryPriority]) {
              return rank[b.recoveryPriority] - rank[a.recoveryPriority];
            }
            return b.pendingAmount + b.arrearsAmount - (a.pendingAmount + a.arrearsAmount);
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
    return rows.filter((row) => {
      if (officerFilter !== 'all' && row.fieldOfficer.toLowerCase() !== officerFilter) {
        return false;
      }

      if (priorityFilter !== 'all' && row.recoveryPriority !== priorityFilter) {
        return false;
      }

      return true;
    });
  }, [rows, officerFilter, priorityFilter]);

  useEffect(() => {
    setCurrentPage(1);
  }, [officerFilter, priorityFilter, pageSize]);

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
        acc.count += 1;
        acc.loanAmount += row.loanAmount;
        acc.refundable += row.refundableAmount;
        acc.collected += row.collectedAmount;
        acc.pending += row.pendingAmount;
        acc.arrears += row.arrearsAmount;
        if (row.recoveryPriority === 'urgent') acc.urgent += 1;
        if (row.recoveryPriority === 'high') acc.high += 1;
        if (row.recoveryPriority === 'medium') acc.medium += 1;
        if (row.recoveryPriority === 'low') acc.low += 1;
        return acc;
      },
      {
        count: 0,
        loanAmount: 0,
        refundable: 0,
        collected: 0,
        pending: 0,
        arrears: 0,
        urgent: 0,
        high: 0,
        medium: 0,
        low: 0,
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
      'Loan Status',
      'Loan Amount',
      'Loan Balance',
      'Refundable Amount',
      'Collected Amount',
      'Penalty Amount',
      'Pending Amount',
      'Arrears Amount',
      'Due Date',
      'Next Payment Date',
      'Overdue Days',
      'Recovery Priority',
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
      row.loanStatus,
      formatMoney(row.loanAmount),
      formatMoney(row.loanBalance),
      formatMoney(row.refundableAmount),
      formatMoney(row.collectedAmount),
      formatMoney(row.penaltyAmount),
      formatMoney(row.pendingAmount),
      formatMoney(row.arrearsAmount),
      formatDate(row.dueDate),
      formatDate(row.nextPaymentDate),
      row.overdueDays,
      row.recoveryPriority,
    ]);

    const csv = [headers, ...body].map((line) => line.map(escapeCsv).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `recovery-report-${getReportFileDate()}.csv`;
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
    const priorityText = `Priority: ${priorityFilter}`;

    doc.setFontSize(16);
    doc.text('Recovery Report', 40, 40);
    doc.setFontSize(10);
    doc.text(`${officerText} | ${priorityText} | Generated: ${generatedAt}`, 40, 58);

    autoTable(doc, {
      startY: 72,
      head: [[
        'Loan ID',
        'Loan Code',
        'Customer No',
        'Customer',
        'Officer',
        'Loan',
        'Balance',
        'Penalty',
        'Pending',
        'Arrears',
        'Overdue Days',
        'Priority',
      ]],
      body: filteredRows.map((row) => [
        row.loanId,
        row.loanCode,
        row.customerNo,
        row.customerName,
        row.fieldOfficer,
        formatMoney(row.loanAmount),
        formatMoney(row.loanBalance),
        formatMoney(row.penaltyAmount),
        formatMoney(row.pendingAmount),
        formatMoney(row.arrearsAmount),
        row.overdueDays,
        row.recoveryPriority,
      ]),
      styles: {
        fontSize: 8,
        cellPadding: 4,
      },
      headStyles: {
        fillColor: [13, 148, 136],
        textColor: [255, 255, 255],
      },
      alternateRowStyles: {
        fillColor: [240, 253, 250],
      },
      margin: { left: 24, right: 24, top: 72, bottom: 24 },
      theme: 'striped',
    });

    doc.save(`recovery-report-${getReportFileDate()}.pdf`);
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
              <h1 className="text-2xl md:text-4xl font-black text-slate-900 mt-3 tracking-tight">Recovery Report</h1>
              <p className="text-sm text-slate-600 mt-1 max-w-2xl">Monitor recovery portfolio, prioritize accounts, and track pending and arrears exposure.</p>
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
              <p className="text-xs uppercase tracking-wide text-cyan-100">Recovery Accounts</p>
              <p className="text-[14px] font-extrabold mt-1">{summary.count}</p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-rose-500 to-red-600 border border-rose-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-rose-100">Pending</p>
              <p className="text-[14px] font-extrabold mt-1 break-words tabular-nums">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.pending)}
              </p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-amber-500 to-orange-600 border border-amber-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-amber-100">Arrears</p>
              <p className="text-[14px] font-extrabold mt-1 break-words tabular-nums">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.arrears)}
              </p>
            </div>
            <div className="rounded-2xl bg-gradient-to-br from-red-500 to-rose-600 border border-red-300/40 shadow-md p-4 text-white">
              <p className="text-xs uppercase tracking-wide text-red-100">Urgent / High</p>
              <p className="text-[14px] font-extrabold mt-1">{summary.urgent} / {summary.high}</p>
            </div>
            <div className="rounded-2xl bg-white/90 border border-cyan-100 shadow-sm p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Medium / Low</p>
              <p className="text-[14px] font-extrabold text-cyan-700 mt-1">{summary.medium} / {summary.low}</p>
            </div>
            <div className="rounded-2xl bg-white/90 border border-emerald-100 shadow-sm p-4">
              <p className="text-xs uppercase tracking-wide text-slate-500">Collected</p>
              <p className="text-[14px] font-extrabold text-emerald-700 mt-1 break-words tabular-nums">
                {new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 2 }).format(summary.collected)}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white/88 backdrop-blur-xl rounded-3xl border border-cyan-100 shadow-[0_18px_48px_-24px_rgba(14,116,144,0.45)] p-4 md:p-5">
          <div className="flex items-center justify-between gap-3 flex-wrap">
            <h2 className="text-lg font-bold text-slate-900">Recovery Portfolio</h2>
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
                <label className="text-xs font-semibold text-slate-600 uppercase tracking-wide">Priority</label>
                <select
                  value={priorityFilter}
                  onChange={(e) => setPriorityFilter(e.target.value as 'all' | 'urgent' | 'high' | 'medium' | 'low')}
                  className="mt-1 px-3 py-2 rounded-xl border border-cyan-100 bg-white text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-cyan-200"
                >
                  <option value="all">All</option>
                  <option value="urgent">Urgent</option>
                  <option value="high">High</option>
                  <option value="medium">Medium</option>
                  <option value="low">Low</option>
                </select>
              </div>
              <button
                type="button"
                onClick={() => {
                  setOfficerFilter('all');
                  setPriorityFilter('all');
                }}
                className="px-3 py-2 rounded-xl bg-white hover:bg-slate-100 text-slate-700 text-sm font-semibold border border-slate-200"
              >
                Reset
              </button>
            </div>
          </div>

          {filteredRows.length === 0 ? (
            <div className="mt-4 rounded-2xl border border-cyan-100 bg-gradient-to-br from-cyan-100/60 to-teal-100/40 p-8 text-sm text-slate-700 text-center">
              No recovery data found for selected filters.
            </div>
          ) : (
            <>
              <div className="mt-4 overflow-x-auto rounded-2xl border border-cyan-100 bg-white shadow-inner">
                <table className="min-w-full text-sm text-left text-slate-700 bg-white">
                  <thead className="bg-gradient-to-r from-slate-900 via-slate-800 to-cyan-800 text-white sticky top-0">
                    <tr>
                      <th className="px-3 py-2 font-semibold">Loan ID</th>
                      <th className="px-3 py-2 font-semibold">Loan Code</th>
                      <th className="px-3 py-2 font-semibold">Customer No</th>
                      <th className="px-3 py-2 font-semibold">Customer</th>
                      <th className="px-3 py-2 font-semibold">Field Officer</th>
                      <th className="px-3 py-2 font-semibold">Loan Status</th>
                      <th className="px-3 py-2 font-semibold">Loan Amount</th>
                      <th className="px-3 py-2 font-semibold">Loan Balance</th>
                      <th className="px-3 py-2 font-semibold">Pending</th>
                      <th className="px-3 py-2 font-semibold">Penalty</th>
                      <th className="px-3 py-2 font-semibold">Arrears</th>
                      <th className="px-3 py-2 font-semibold">Due Date</th>
                      <th className="px-3 py-2 font-semibold">Next Payment</th>
                      <th className="px-3 py-2 font-semibold">Overdue Days</th>
                      <th className="px-3 py-2 font-semibold">Priority</th>
                    </tr>
                  </thead>
                  <tbody>
                    {pagedRows.map((row) => (
                      <tr key={row.loanId} className="border-b border-cyan-100 last:border-b-0 odd:bg-white even:bg-cyan-50/25 hover:bg-cyan-50/60 transition-colors">
                        <td className="px-3 py-2">{row.loanId}</td>
                        <td className="px-3 py-2 font-semibold text-slate-900">{row.loanCode}</td>
                        <td className="px-3 py-2 font-semibold text-slate-900">{row.customerNo}</td>
                        <td className="px-3 py-2">{row.customerName}</td>
                        <td className="px-3 py-2">{row.fieldOfficer}</td>
                        <td className="px-3 py-2 capitalize">{row.loanStatus}</td>
                        <td className="px-3 py-2">{formatMoney(row.loanAmount)}</td>
                        <td className="px-3 py-2 font-semibold text-cyan-700">{formatMoney(row.loanBalance)}</td>
                        <td className="px-3 py-2 text-rose-700 font-semibold">{formatMoney(row.pendingAmount)}</td>
                        <td className="px-3 py-2 text-fuchsia-700 font-semibold">{formatMoney(row.penaltyAmount)}</td>
                        <td className="px-3 py-2 text-orange-700 font-semibold">{formatMoney(row.arrearsAmount)}</td>
                        <td className="px-3 py-2">{formatDate(row.dueDate)}</td>
                        <td className="px-3 py-2">{formatDate(row.nextPaymentDate)}</td>
                        <td className="px-3 py-2">{row.overdueDays}</td>
                        <td className="px-3 py-2">
                          <span className={`inline-flex rounded-full border px-2 py-0.5 text-xs font-semibold capitalize ${
                            row.recoveryPriority === 'urgent'
                              ? 'border-red-200 bg-red-50 text-red-800'
                              : row.recoveryPriority === 'high'
                              ? 'border-orange-200 bg-orange-50 text-orange-800'
                              : row.recoveryPriority === 'medium'
                              ? 'border-amber-200 bg-amber-50 text-amber-800'
                              : 'border-emerald-200 bg-emerald-50 text-emerald-800'
                          }`}>
                            {row.recoveryPriority}
                          </span>
                        </td>
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
