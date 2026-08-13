export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero — eventos-hero com pesquisa + filtros */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-5 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="max-w-3xl mx-auto mt-10">
              <div className="h-12 w-full rounded-2xl" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
            </div>
            <div className="flex flex-wrap items-center justify-center gap-3 mt-6">
              {[0, 1, 2, 3, 4].map((i) => (
                <div key={i} className="h-9 w-24 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: i === 0 ? 0.7 : 0.5 }} />
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Grid de cards */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          <div className="flex justify-end gap-3 mb-8">
            <div className="h-9 w-56 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="rounded-2xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="w-full" style={{ aspectRatio: '16 / 9', ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
                <div className="p-5 space-y-3">
                  <div className="h-3.5 w-24 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-5 w-5/6 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="h-4 w-4/5 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                  <div className="flex justify-between items-center pt-3" style={{ borderTop: '1px solid var(--color-brand-divider)' }}>
                    <div className="flex items-center gap-2">
                      <div className="h-6 w-6 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                      <div className="h-3.5 w-20 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                    </div>
                    <div className="h-3.5 w-16 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
