export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <>
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-48 mx-auto rounded-2xl mb-3" style={{ ...pulse, opacity: 0.5 }} />
            <div className="h-5 w-64 mx-auto rounded-lg" style={{ ...pulse, opacity: 0.3 }} />
          </div>
        </div>
      </section>
      <section className="max-w-7xl mx-auto px-4 py-8">
        <div className="max-w-md mx-auto mb-6">
          <div className="h-12 w-full rounded-lg" style={{ ...pulse, opacity: 0.2 }} />
        </div>
        <div className="flex gap-2 justify-center flex-wrap">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="h-9 rounded-lg" style={{ ...pulse, opacity: 0.2, width: 70 + i * 12 }} />
          ))}
        </div>
      </section>
      <section className="max-w-7xl mx-auto px-4 pb-16">
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="p-4 rounded-xl" style={{ border: '1px solid var(--color-brand-divider)' }}>
              <div className="h-4 w-36 rounded mb-2" style={{ ...pulse, opacity: 0.4 }} />
              <div className="h-3 w-full rounded mb-1.5" style={{ ...pulse, opacity: 0.2 }} />
              <div className="h-3 w-2/3 rounded" style={{ ...pulse, opacity: 0.15 }} />
            </div>
          ))}
        </div>
      </section>
    </>
  )
}
