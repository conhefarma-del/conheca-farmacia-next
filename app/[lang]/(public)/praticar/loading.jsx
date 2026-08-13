export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="py-12 md:py-16">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 text-center">
          <div className="h-14 w-72 max-w-full mx-auto rounded-lg mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
          <div className="h-4 w-96 max-w-full mx-auto rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
        </div>
      </section>

      {/* Dois cartões */}
      <section style={{ background: 'var(--color-brand-bg-alt)' }}>
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {[0, 1].map((i) => (
              <div key={i} className="rounded-2xl p-6" style={{ ...pulse, border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="flex justify-between items-center mb-4">
                  <div className="h-14 w-14 rounded-2xl" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-4 w-28 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                </div>
                <div className="h-6 w-40 rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="h-3.5 w-full rounded mb-1.5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                <div className="h-3.5 w-2/3 rounded mb-5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                <div className="h-9 w-36 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
