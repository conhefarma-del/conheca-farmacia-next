export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <>
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-10 w-48 mx-auto rounded-2xl mb-3" style={{ ...pulse, opacity: 0.5 }} />
            <div className="h-5 w-64 mx-auto rounded-lg" style={{ ...pulse, opacity: 0.3 }} />
          </div>
        </div>
      </section>
      <section className="max-w-2xl mx-auto px-4 py-8">
        <div className="space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="profile-card-v2" style={{ minHeight: 120 }}>
              <div className="h-5 w-32 rounded mb-4" style={{ ...pulse, opacity: 0.4 }} />
              <div className="space-y-3">
                <div className="h-10 w-full rounded-lg" style={{ ...pulse, opacity: 0.2 }} />
                <div className="h-10 w-full rounded-lg" style={{ ...pulse, opacity: 0.2 }} />
              </div>
            </div>
          ))}
        </div>
      </section>
    </>
  )
}
