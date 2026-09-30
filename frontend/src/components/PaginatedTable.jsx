import { useState } from 'react';

const PAGE_SIZE = 20;

export default function PaginatedTable({ data = [], resetKey, children }) {
  const [pagination, setPagination] = useState({ page: 1, resetKey });
  const totalPages = Math.max(1, Math.ceil(data.length / PAGE_SIZE));
  const page = pagination.resetKey === resetKey
    ? Math.min(pagination.page, totalPages)
    : 1;

  // Keep the stored page valid after filtering or deleting the last row.
  if (pagination.resetKey !== resetKey || pagination.page !== page) {
    setPagination({ page, resetKey });
  }

  const startIndex = (page - 1) * PAGE_SIZE;
  const endIndex = Math.min(startIndex + PAGE_SIZE, data.length);
  const goToPage = (nextPage) => setPagination({ page: nextPage, resetKey });
  const buttonClass = 'px-3 py-1.5 rounded-lg border border-slate-200 text-slate-700 hover:bg-teal-50 disabled:opacity-40 disabled:cursor-not-allowed focus-visible:outline-teal-600';

  return (
    <div>
      <div className="overflow-x-auto">
        {children(data.slice(startIndex, endIndex), startIndex)}
      </div>
      <nav aria-label="Phân trang bảng" className="flex flex-wrap items-center justify-between gap-3 border-t border-slate-200 bg-white px-3.5 py-3 text-xs">
        <span className="text-slate-500" aria-live="polite">
          Hiển thị {data.length === 0 ? 0 : startIndex + 1}–{endIndex} / {data.length} bản ghi
        </span>
        <div className="flex flex-wrap items-center gap-2">
          <button type="button" className={buttonClass} disabled={page === 1} onClick={() => goToPage(1)}>Đầu</button>
          <button type="button" className={buttonClass} disabled={page === 1} onClick={() => goToPage(page - 1)}>Trước</button>
          <span className="text-slate-600">Trang {page} / {totalPages}</span>
          <button type="button" className={buttonClass} disabled={page === totalPages} onClick={() => goToPage(page + 1)}>Sau</button>
          <button type="button" className={buttonClass} disabled={page === totalPages} onClick={() => goToPage(totalPages)}>Cuối</button>
        </div>
      </nav>
    </div>
  );
}
