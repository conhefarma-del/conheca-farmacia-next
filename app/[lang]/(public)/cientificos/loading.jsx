export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero (estilo /eventos) */}
      <section className="bg-brand-bg py-12 md:py-16">
        <div className="container-center text-center">
          <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
          <div className="h-5 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          {/* Pesquisa */}
          <div className="max-w-3xl mx-auto mt-10">
            <div className="h-12 w-full rounded-2xl" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
          </div>
          {/* Filtros */}
          <div className="flex justify-center gap-3 mt-8">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-9 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            ))}
          </div>
        </div>
      </section>

      {/* Grid de cards */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {/* Barra ordenação */}
          <div className="flex justify-end mb-8">
            <div className="h-9 w-56 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {Array.from({ length: 6 }).map((_, i) => (
              <div
                key={i}
                className="rounded-xl p-5"
                style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}
              >
                <div className="flex justify-between mb-4">
                  <div className="h-5 w-24 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="h-5 w-8 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                </div>
                <div className="h-4 w-full rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="h-4 w-2/3 rounded mb-5" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="h-3 w-full rounded mb-1.5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                <div className="h-3 w-5/6 rounded mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                <div className="flex gap-2 pt-3" style={{ borderTop: '1px solid var(--color-brand-divider)' }}>
                  <div className="h-4 w-24 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-4 w-14 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
