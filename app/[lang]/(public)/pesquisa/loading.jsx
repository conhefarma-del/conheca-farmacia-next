export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Hero — centered like articles-hero */}
      <section className="articles-hero">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 text-center">
          <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={pulse} />
          <div className="h-5 w-96 mx-auto rounded" style={{ ...pulse, opacity: 0.6 }} />
        </div>
      </section>

      {/* Search Section */}
      <section className="search-page" style={{ marginTop: '-2rem' }}>
        <div className="search-container">
          {/* Search input bar */}
          <div className="search-hero">
            <div className="search-input-wrapper">
              <div className="h-12 w-full rounded-lg" style={pulse} />
            </div>
          </div>

          {/* Filters: 4 pill buttons + sort dropdown */}
          <div className="search-filters">
            <div className="search-type-filters">
              {['todos', 'artigos', 'eventos', 'lives'].map((key) => (
                <div key={key} className="h-9 w-20 rounded-full" style={pulse} />
              ))}
            </div>
            <div className="search-sort">
              <div className="h-9 w-36 rounded" style={pulse} />
            </div>
          </div>

          {/* Skeleton result cards */}
          <div className="search-results">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="search-skeleton">
                <div className="skeleton-image" />
                <div className="skeleton-body">
                  <div className="skeleton-line" style={{ width: 60 }} />
                  <div className="skeleton-line skeleton-line-long" />
                  <div className="skeleton-line skeleton-line-long" />
                  <div className="skeleton-line skeleton-line-short" />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
