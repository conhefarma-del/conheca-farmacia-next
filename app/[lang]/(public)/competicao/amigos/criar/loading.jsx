export default function Loading() {
  const pulse = {
    background: 'var(--color-brand-divider)',
    animation: 'pulse 1.5s ease-in-out infinite',
  }

  return (
    <section className="py-16 bg-background min-h-screen">
      <div className="container-center max-w-xl mx-auto px-4">
        {/* Back link */}
        <div className="h-4 w-28 rounded mb-6" style={{ ...pulse, opacity: 0.3 }} />

        {/* Title */}
        <div className="h-8 w-56 rounded-lg mb-2" style={{ ...pulse, opacity: 0.6 }} />
        <div className="h-5 w-72 rounded mb-8" style={{ ...pulse, opacity: 0.3 }} />

        {/* Name field */}
        <div className="mb-6">
          <div className="h-4 w-28 rounded mb-2" style={{ ...pulse, opacity: 0.5 }} />
          <div className="h-12 w-full rounded-xl" style={{ ...pulse, opacity: 0.3 }} />
        </div>

        {/* Config grid */}
        <div className="grid grid-cols-3 gap-4 mb-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i}>
              <div className="h-4 w-20 rounded mb-2" style={{ ...pulse, opacity: 0.5 }} />
              <div className="h-12 w-full rounded-xl" style={{ ...pulse, opacity: 0.3 }} />
            </div>
          ))}
        </div>

        {/* Question types */}
        <div className="mb-8">
          <div className="h-4 w-36 rounded mb-3" style={{ ...pulse, opacity: 0.5 }} />
          <div className="flex flex-wrap gap-2">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="h-9 rounded-lg" style={{ ...pulse, opacity: 0.2, width: 80 + i * 10 }} />
            ))}
          </div>
        </div>

        {/* Create button */}
        <div className="h-14 w-full rounded-2xl" style={{ ...pulse, opacity: 0.5 }} />
      </div>
    </section>
  )
}
