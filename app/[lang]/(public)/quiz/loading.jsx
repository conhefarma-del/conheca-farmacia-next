export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero + toggle */}
      <section className="py-12 md:py-16">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 text-center">
          <div className="h-14 w-64 max-w-full mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
          <div className="h-4 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          <div className="flex justify-center gap-2.5 mt-8">
            <div className="h-10 w-40 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-10 w-36 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
        </div>
      </section>

      <section style={{ background: 'var(--color-brand-bg-alt)' }}>
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {/* Modo rápido */}
          <div className="h-20 rounded-2xl mb-10" style={{ ...pulse, background: 'rgba(15, 26, 20, 0.75)' }} />
          {/* Título */}
          <div className="h-6 w-64 rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-10">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="rounded-2xl p-4" style={{ ...pulse, border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="h-4 w-20 rounded-full mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                <div className="h-4 w-3/4 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
              </div>
            ))}
          </div>
          {/* Título tipos */}
          <div className="h-6 w-64 rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="rounded-2xl p-5" style={{ ...pulse, border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="h-6 w-6 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                <div className="h-4 w-2/3 rounded mb-1.5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
                <div className="h-3.5 w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
