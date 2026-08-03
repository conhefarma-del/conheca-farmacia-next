export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Breadcrumb + Hero do curso — título + stats */}
      <section className="article-hero">
        <div className="container-center">
          <div className="h-5 w-56 rounded mb-6" style={{ ...pulse, opacity: 0.6 }} />
          <div className="h-10 w-2/3 max-w-xl rounded-lg mb-4" style={pulse} />
          <div className="h-5 w-96 max-w-full rounded" style={{ ...pulse, opacity: 0.6 }} />
          <div className="guide-hero-stats">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="guide-hero-stat" style={{ opacity: 0.5 }}>
                <div className="w-4 h-4 rounded-full" style={pulse} />
                <div className="h-4 w-20 rounded" style={pulse} />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Layout 2 colunas: plano por fases + sidebar */}
      <div className="guide-detail-layout">
        <div className="guide-detail-main">
          <div className="guide-section-heading">
            <div className="w-5 h-5 rounded" style={pulse} />
            <div className="h-6 w-48 rounded" style={pulse} />
          </div>
          {Array.from({ length: 3 }).map((_, i) => (
            <div
              key={i}
              className="rounded-xl p-5 mb-4"
              style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-bg)' }}
            >
              <div className="h-5 w-40 rounded mb-3" style={pulse} />
              <div className="h-4 w-full rounded mb-2" style={pulse} />
              <div className="h-4 w-2/3 rounded" style={pulse} />
            </div>
          ))}
        </div>

        <aside className="guide-sidebar">
          <div
            className="rounded-xl p-5"
            style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-bg)' }}
          >
            <div className="h-5 w-32 rounded mb-4" style={pulse} />
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-4 w-full rounded mb-3" style={pulse} />
            ))}
            <div className="h-4 w-1/2 rounded" style={pulse} />
          </div>
        </aside>
      </div>
    </div>
  )
}
