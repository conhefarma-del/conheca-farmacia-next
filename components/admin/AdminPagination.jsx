'use client'

/**
 * AdminPagination — controlos de paginação (anterior/próxima + números).
 * Gera uma janela compacta de números à volta da página atual.
 */
export default function AdminPagination({ page, totalPages, onPageChange }) {
  if (totalPages <= 1) return null

  const pages = []
  const start = Math.max(1, page - 2)
  const end = Math.min(totalPages, page + 2)
  if (start > 1) pages.push(1)
  if (start > 2) pages.push('…')
  for (let i = start; i <= end; i++) pages.push(i)
  if (end < totalPages - 1) pages.push('…')
  if (end < totalPages) pages.push(totalPages)

  return (
    <nav className="admin-pagination" aria-label="Paginação">
      <button
        type="button"
        className="admin-pagination-btn"
        disabled={page <= 1}
        onClick={() => onPageChange(page - 1)}
      >
        ← Anterior
      </button>
      <div className="admin-pagination-pages">
        {pages.map((p, idx) =>
          p === '…' ? (
            <span key={`e${idx}`} className="admin-pagination-ellipsis">…</span>
          ) : (
            <button
              key={p}
              type="button"
              className={`admin-pagination-num${p === page ? ' is-active' : ''}`}
              aria-current={p === page ? 'page' : undefined}
              onClick={() => onPageChange(p)}
            >
              {p}
            </button>
          )
        )}
      </div>
      <button
        type="button"
        className="admin-pagination-btn"
        disabled={page >= totalPages}
        onClick={() => onPageChange(page + 1)}
      >
        Próxima →
      </button>
    </nav>
  )
}
