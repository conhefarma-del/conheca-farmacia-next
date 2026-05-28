export default function Loading() {
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="bg-brand-bg-alt py-20 md:py-32">
        <div className="container-center text-center">
          <div className="h-12 w-96 mx-auto rounded-lg mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
          <div className="h-5 w-80 mx-auto rounded mb-4" style={{ background: 'var(--color-brand-divider)', opacity: 0.6, animation: 'pulse 1.5s ease-in-out infinite' }} />
          <div className="h-5 w-64 mx-auto rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.6, animation: 'pulse 1.5s ease-in-out infinite' }} />
        </div>
      </section>

      {/* Featured Articles */}
      <section className="container-center py-12">
        <div className="h-8 w-48 rounded mb-8" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="rounded-xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)' }}>
              <div className="h-48" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              <div className="p-4 space-y-3">
                <div className="h-4 w-20 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                <div className="h-5 w-3/4 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                <div className="h-4 w-full rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Featured Events */}
      <section className="container-center py-12">
        <div className="h-8 w-48 rounded mb-8" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {Array.from({ length: 2 }).map((_, i) => (
            <div key={i} className="rounded-xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)' }}>
              <div className="h-48" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              <div className="p-4 space-y-3">
                <div className="h-4 w-24 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                <div className="h-5 w-3/4 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Stats */}
      <section className="container-center py-12">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="text-center">
              <div className="h-10 w-20 mx-auto rounded mb-2" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              <div className="h-4 w-24 mx-auto rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
