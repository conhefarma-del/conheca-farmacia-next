export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Hero — centered */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={pulse} />
            <div className="h-5 w-96 mx-auto rounded" style={{ ...pulse, opacity: 0.6 }} />
          </div>
        </div>
      </section>

      {/* Nossa Missao — bg-brand-bg-alt, centered text */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="h-8 w-48 mx-auto rounded mb-10" style={pulse} />
          <div className="max-w-2xl mx-auto space-y-4">
            <div className="h-4 w-full rounded" style={pulse} />
            <div className="h-4 w-full rounded" style={pulse} />
            <div className="h-4 w-3/4 rounded" style={pulse} />
          </div>
        </div>
      </section>

      {/* O Que Fazemos — 2-card grid */}
      <section className="section-padding bg-brand-bg">
        <div className="container-center">
          <div className="h-8 w-56 mx-auto rounded mb-10" style={pulse} />
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {Array.from({ length: 2 }).map((_, i) => (
              <div key={i} className="rounded-xl p-6" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="h-14 w-14 rounded-full mx-auto mb-4" style={pulse} />
                <div className="h-5 w-40 mx-auto rounded mb-3" style={pulse} />
                <div className="h-4 w-full rounded mb-2" style={pulse} />
                <div className="h-4 w-3/4 mx-auto rounded" style={pulse} />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Publico-Alvo — 4-item grid, bg-brand-bg-alt */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="h-8 w-48 mx-auto rounded mb-10" style={pulse} />
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="text-center">
                <div className="h-14 w-14 rounded-full mx-auto mb-3" style={pulse} />
                <div className="h-4 w-24 mx-auto rounded" style={pulse} />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pull Quote */}
      <section className="pull-quote-section">
        <div className="pull-quote-container">
          <div className="h-6 w-3/4 mx-auto rounded mb-3" style={pulse} />
          <div className="h-6 w-1/2 mx-auto rounded" style={pulse} />
        </div>
      </section>
    </div>
  )
}
