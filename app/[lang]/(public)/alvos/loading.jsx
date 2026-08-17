export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero — título + subtítulo centrados */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={pulse} />
            <div className="h-5 w-96 max-w-full mx-auto rounded" style={{ ...pulse, opacity: 0.6 }} />
          </div>
        </div>
      </section>

      {/* Toolbar — pesquisa + filtros */}
      <section className="events-hero">
        <div className="container-center pb-10">
          <div className="h-12 w-full rounded-2xl mb-4" style={{ ...pulse, opacity: 0.7 }} />
          <div className="flex flex-wrap items-center gap-3">
            {[0, 1, 2, 3, 4, 5].map((i) => (
              <div key={i} className="h-9 w-28 rounded-full" style={{ ...pulse, opacity: i === 0 ? 0.7 : 0.5 }} />
            ))}
          </div>
        </div>
      </section>

      {/* Grid de cards de alvos */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="rounded-2xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="p-5 space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="h-6 w-24 rounded-full" style={{ ...pulse, opacity: 0.6 }} />
                    <div className="h-3.5 w-28 rounded" style={{ ...pulse, opacity: 0.5 }} />
                  </div>
                  <div className="h-6 w-2/3 rounded" style={pulse} />
                  <div className="h-4 w-full rounded" style={{ ...pulse, opacity: 0.6 }} />
                  <div className="h-4 w-4/5 rounded" style={{ ...pulse, opacity: 0.6 }} />
                  <div className="h-3.5 w-20 rounded pt-3" style={{ ...pulse, opacity: 0.5 }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
