export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Hero — 2 columns: text left + animated card right */}
      <section className="hero">
        <div className="hero-container">
          <div className="hero-content">
            <div className="h-12 w-80 rounded-lg mb-6" style={pulse} />
            <div className="h-12 w-64 rounded-lg mb-6" style={pulse} />
            <div className="h-5 w-96 rounded mb-4" style={{ ...pulse, opacity: 0.6 }} />
            <div className="h-5 w-72 rounded mb-10" style={{ ...pulse, opacity: 0.6 }} />
            <div className="h-12 w-48 rounded-lg" style={pulse} />
          </div>
          <div className="h-80 w-full rounded-2xl" style={pulse} />
        </div>
      </section>

      {/* Featured Articles — bg-brand-bg-alt, 3-col grid */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="h-8 w-64 mx-auto rounded mb-10" style={pulse} />
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="rounded-xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="h-48" style={pulse} />
                <div className="p-5 space-y-3">
                  <div className="h-4 w-20 rounded" style={pulse} />
                  <div className="h-5 w-3/4 rounded" style={pulse} />
                  <div className="h-4 w-full rounded" style={pulse} />
                  <div className="h-4 w-2/3 rounded" style={pulse} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Featured Events — bg-brand-bg, 2-col grid */}
      <section className="section-padding bg-brand-bg">
        <div className="container-center">
          <div className="h-8 w-64 mx-auto rounded mb-10" style={pulse} />
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {Array.from({ length: 2 }).map((_, i) => (
              <div key={i} className="rounded-xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="h-48" style={pulse} />
                <div className="p-5 space-y-3">
                  <div className="h-4 w-24 rounded" style={pulse} />
                  <div className="h-5 w-3/4 rounded" style={pulse} />
                  <div className="h-4 w-full rounded" style={pulse} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Featured Lives — bg-brand-bg-alt, 2-col grid */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="h-8 w-64 mx-auto rounded mb-10" style={pulse} />
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {Array.from({ length: 2 }).map((_, i) => (
              <div key={i} className="rounded-xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="h-48" style={pulse} />
                <div className="p-5 space-y-3">
                  <div className="h-4 w-24 rounded" style={pulse} />
                  <div className="h-5 w-3/4 rounded" style={pulse} />
                  <div className="h-4 w-full rounded" style={pulse} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="stats-section">
        <div className="container-center">
          <div className="stats-grid">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="stat-item">
                <div className="h-10 w-20 mx-auto rounded mb-2" style={pulse} />
                <div className="h-4 w-28 mx-auto rounded" style={pulse} />
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
