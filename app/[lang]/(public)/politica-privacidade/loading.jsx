export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-5 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
        </div>
      </section>

      {/* Layout 2 colunas: TOC + conteúdo */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="privacy-layout">
            <aside className="privacy-layout-toc">
              <div className="rounded-xl p-5" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="h-3.5 w-24 rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                {Array.from({ length: 6 }).map((_, i) => (
                  <div key={i} className="h-3.5 w-3/4 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                ))}
              </div>
            </aside>

            <div className="privacy-layout-content">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="rounded-xl p-6 mb-6" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                  <div className="h-5 w-1/2 rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="space-y-2">
                    <div className="h-3.5 w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                    <div className="h-3.5 w-11/12 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                    <div className="h-3.5 w-5/6 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
