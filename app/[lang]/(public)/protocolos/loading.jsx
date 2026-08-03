export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Hero — título + subtítulo centrados */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={pulse} />
            <div className="h-5 w-96 mx-auto rounded" style={{ ...pulse, opacity: 0.6 }} />
          </div>
        </div>
      </section>

      {/* Pesquisa + filtros de categoria */}
      <section className="articles-filter-section">
        <div className="container-center">
          <div className="max-w-4xl mx-auto">
            <div className="h-14 w-full rounded-2xl mb-8" style={pulse} />
            <div className="flex flex-wrap justify-center gap-3 pb-8">
              {Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="h-9 w-24 rounded-full" style={pulse} />
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Grid de protocolos — espelha protocol-card (faixa de topo + corpo) */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="protocolos-grid">
            {Array.from({ length: 6 }).map((_, i) => (
              <div
                key={i}
                className="rounded-2xl overflow-hidden"
                style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-bg)' }}
              >
                <div className="h-1.5" style={pulse} />
                <div className="p-5">
                  <div className="h-4 w-16 rounded mb-3" style={pulse} />
                  <div className="h-5 w-3/4 rounded mb-3" style={pulse} />
                  <div className="h-4 w-full rounded mb-2" style={pulse} />
                  <div className="h-4 w-2/3 rounded" style={pulse} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
