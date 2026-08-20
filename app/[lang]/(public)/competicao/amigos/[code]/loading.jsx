export default function Loading() {
  const pulse = {
    background: 'var(--color-brand-divider)',
    animation: 'pulse 1.5s ease-in-out infinite',
  }

  return (
    <section className="py-16 bg-background min-h-screen">
      <div className="container-center max-w-xl mx-auto px-4">
        {/* Challenge title */}
        <div className="text-center mb-8">
          <div className="h-8 w-64 mx-auto rounded-lg mb-2" style={{ ...pulse, opacity: 0.6 }} />
          <div className="h-4 w-32 mx-auto rounded" style={{ ...pulse, opacity: 0.3 }} />
        </div>

        {/* Players skeleton */}
        <div className="space-y-3 mb-8">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="flex items-center gap-3 p-4 rounded-xl" style={{ border: '1px solid var(--color-brand-divider)' }}>
              <div className="w-10 h-10 rounded-full flex-shrink-0" style={{ ...pulse, opacity: 0.2 }} />
              <div className="flex-1">
                <div className="h-4 w-28 rounded mb-1.5" style={{ ...pulse, opacity: 0.5 }} />
                <div className="h-3 w-20 rounded" style={{ ...pulse, opacity: 0.3 }} />
              </div>
              <div className="w-6 h-6 rounded-full" style={{ ...pulse, opacity: 0.15 }} />
            </div>
          ))}
        </div>

        {/* Ready button */}
        <div className="h-14 w-full rounded-2xl" style={{ ...pulse, opacity: 0.4 }} />

        {/* Share code */}
        <div className="mt-6 text-center">
          <div className="h-4 w-48 mx-auto rounded mb-3" style={{ ...pulse, opacity: 0.3 }} />
          <div className="h-12 w-48 mx-auto rounded-xl" style={{ ...pulse, opacity: 0.2 }} />
        </div>
      </div>
    </section>
  )
}
