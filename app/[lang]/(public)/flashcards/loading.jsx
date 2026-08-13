export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="py-16" style={{ background: 'linear-gradient(135deg, #0f1a14 0%, #143528 100%)' }}>
        <div className="max-w-[1100px] mx-auto px-6 text-center">
          <div className="h-3.5 w-36 mx-auto rounded-full mb-5" style={{ ...pulse, background: 'rgba(255,255,255,0.25)' }} />
          <div className="h-12 w-80 max-w-full mx-auto rounded-lg mb-5" style={{ ...pulse, background: 'rgba(255,255,255,0.18)' }} />
          <div className="h-4 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'rgba(255,255,255,0.15)' }} />
        </div>
      </section>

      {/* Painel de revisão */}
      <section className="max-w-[1100px] mx-auto px-6 -mt-10 relative z-10">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="rounded-2xl p-5" style={{ ...pulse, border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
              <div className="h-8 w-16 rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
              <div className="h-3.5 w-28 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            </div>
          ))}
        </div>
      </section>

      {/* Filtros + pesquisa */}
      <section className="max-w-[1100px] mx-auto px-6 mt-10">
        <div className="flex flex-wrap gap-2.5">
          <div className="h-9 w-20 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          <div className="h-9 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          <div className="h-9 w-32 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          <div className="h-9 w-48 rounded-full ml-auto" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
        </div>
      </section>

      {/* Grid de decks */}
      <section className="max-w-[1100px] mx-auto px-6 py-10">
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
      </section>
    </div>
  )
}
