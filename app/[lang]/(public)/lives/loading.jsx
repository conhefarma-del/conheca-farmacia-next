export default function Loading() {
  return (
    <div className="min-h-screen">
      <section className="bg-brand-bg-alt py-20 md:py-32">
        <div className="container-center text-center">
          <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
          <div className="h-5 w-96 mx-auto rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.6, animation: 'pulse 1.5s ease-in-out infinite' }} />
        </div>
      </section>
      <section className="container-center py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="rounded-xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)' }}>
              <div className="h-48" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              <div className="p-4 space-y-3">
                <div className="h-4 w-24 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                <div className="h-5 w-3/4 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                <div className="h-4 w-full rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
