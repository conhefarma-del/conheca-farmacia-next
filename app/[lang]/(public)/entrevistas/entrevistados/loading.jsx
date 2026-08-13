export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-5 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="max-w-2xl mx-auto mt-10">
              <div className="h-12 w-full rounded-2xl" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
            </div>
          </div>
        </div>
      </section>

      {/* Lista de entrevistados */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1100px] mx-auto px-6 md:px-12 py-12">
          <div className="flex justify-end gap-3 mb-8">
            <div className="h-9 w-56 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
          <div className="sci-authors-index-grid">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="rounded-xl p-4" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="flex items-center gap-3 mb-4">
                  <div className="h-10 w-10 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="space-y-2 flex-1">
                    <div className="h-4 w-2/3 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                    <div className="h-3 w-1/2 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                  </div>
                </div>
                <div className="flex justify-between items-center pt-3" style={{ borderTop: '1px solid var(--color-brand-divider)' }}>
                  <div className="h-5 w-20 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-3.5 w-16 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
