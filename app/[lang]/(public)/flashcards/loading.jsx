export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero — padrão /cientificos e /eventos (claro) */}
      <section className="py-12 md:py-16">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 text-center">
          <div className="h-14 w-80 max-w-full mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
          <div className="h-4 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          {/* Pesquisa */}
          <div className="h-12 max-w-2xl mx-auto mt-10 rounded-2xl" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.4 }} />
          {/* Filtros por deck */}
          <div className="flex flex-wrap justify-center gap-2.5 mt-6">
            {[0, 1, 2, 3].map((i) => (
              <div key={i} className="h-9 w-24 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            ))}
          </div>
        </div>
      </section>

      {/* Secção de cards — fundo alternado */}
      <section style={{ background: 'var(--color-brand-bg-alt)' }}>
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {/* Painel de revisão */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="rounded-2xl p-5" style={{ ...pulse, border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="h-8 w-16 rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="h-3.5 w-28 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
              </div>
            ))}
          </div>

          {/* Grid de decks */}
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="rounded-2xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="flex justify-between items-center px-5 pt-5 pb-3">
                  <div className="h-5 w-24 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                  <div className="h-3.5 w-16 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                </div>
                <div className="px-5 pb-4">
                  <div className="h-4.5 w-3/4 rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="h-3.5 w-full rounded mb-1.5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-3.5 w-2/3 rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-2 rounded-full w-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                </div>
                <div className="flex justify-between items-center px-5 py-3" style={{ borderTop: '1px solid var(--color-brand-divider)' }}>
                  <div className="h-3.5 w-20 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-8 w-20 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
