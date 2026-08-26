export default function Loading() {
  return (
    <>
      {/* Hero skeleton */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="w-20 h-20 rounded-full mx-auto mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.3 }} />
            <div className="h-10 w-80 mx-auto rounded-lg mb-4" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.3 }} />
            <div className="h-5 w-96 mx-auto rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.2 }} />
          </div>
        </div>
      </section>
      {/* Content skeleton */}
      <section className="bg-background">
        <div className="max-w-3xl mx-auto px-6 py-12">
          <div className="space-y-4 mb-10">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="flex items-start gap-4 p-5 rounded-2xl" style={{ background: 'var(--color-brand-divider)', opacity: 0.08 }}>
                <div className="w-10 h-10 rounded-xl" style={{ background: 'var(--color-brand-accent)', opacity: 0.15 }} />
                <div className="flex-1">
                  <div className="h-4 w-32 rounded mb-2" style={{ background: 'var(--color-brand-divider)', opacity: 0.3 }} />
                  <div className="h-3 w-full rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.2 }} />
                </div>
              </div>
            ))}
          </div>
          <div className="h-12 w-48 mx-auto rounded-xl" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.2 }} />
        </div>
      </section>
    </>
  )
}
