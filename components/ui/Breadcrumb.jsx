import Link from 'next/link'

export default function Breadcrumb({ items = [] }) {
  if (!items.length) return null

  return (
    <nav aria-label="Breadcrumb">
      <ol className="breadcrumb-list">
        {items.map((item, i) => (
          <li key={i} className="breadcrumb-item">
            {i > 0 && (
              <span className="breadcrumb-separator" aria-hidden="true">
                &gt;
              </span>
            )}
            {item.href ? (
              <Link href={item.href} className="breadcrumb-link">
                {item.label}
              </Link>
            ) : (
              <span className="breadcrumb-current" aria-current="page">
                {item.label}
              </span>
            )}
          </li>
        ))}
      </ol>
    </nav>
  )
}
