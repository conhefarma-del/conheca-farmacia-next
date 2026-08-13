export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-72 mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-5 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
        </div>
      </section>

      {/* Tabs + FAQ */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center max-w-3xl">
          {/* Tabs */}
          <div className="flex flex-wrap gap-2 mb-8">
            {[0, 1, 2].map((i) => (
              <div key={i} className="h-9 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: i === 0 ? 0.7 : 0.5 }} />
            ))}
          </div>

          {/* Accordion items */}
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="rounded-xl p-5" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="flex items-center justify-between gap-4 mb-3">
                  <div className="h-4 w-3/4 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="h-4 w-4 rounded-full flex-shrink-0" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                </div>
                {i % 2 === 0 && (
                  <div className="space-y-2">
                    <div className="h-3.5 w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                    <div className="h-3.5 w-5/6 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
