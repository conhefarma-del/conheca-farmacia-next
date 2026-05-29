export default function Loading() {
  return (
    <main>
      {/* Breadcrumb skeleton */}
      <nav aria-label="Breadcrumb" style={{ padding: '16px 0' }}>
        <div className="container-center">
          <div className="flex gap-2">
            <div className="h-4 w-16 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.4, animation: 'pulse 1.5s ease-in-out infinite' }} />
            <div className="h-4 w-4 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.3 }} />
            <div className="h-4 w-20 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.4, animation: 'pulse 1.5s ease-in-out infinite' }} />
            <div className="h-4 w-4 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.3 }} />
            <div className="h-4 w-24 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.4, animation: 'pulse 1.5s ease-in-out infinite' }} />
          </div>
        </div>
      </nav>

      {/* Hero + Form skeleton */}
      <section className="inscription-section bg-brand-bg-alt">
        <div className="container-center">
          <div className="inscription-container">
            <div className="inscription-form-wrapper">
              {/* Header */}
              <div className="inscription-header mb-12">
                <div className="h-10 w-80 mx-auto rounded-lg mb-4" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                <div className="h-5 w-96 mx-auto rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.6, animation: 'pulse 1.5s ease-in-out infinite' }} />
              </div>

              {/* CapacityBar skeleton */}
              <div className="mb-8">
                <div className="h-3 w-full rounded-full mb-3" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                <div className="h-4 w-48 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.5, animation: 'pulse 1.5s ease-in-out infinite' }} />
              </div>

              {/* Form skeleton */}
              <div className="inscription-form space-y-8">
                {/* Identidade */}
                <div>
                  <div className="h-5 w-24 rounded mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                  <div className="space-y-6">
                    {Array.from({ length: 3 }).map((_, i) => (
                      <div key={i} className="form-group">
                        <div className="h-4 w-20 rounded mb-2" style={{ background: 'var(--color-brand-divider)', opacity: 0.5, animation: 'pulse 1.5s ease-in-out infinite' }} />
                        <div className="h-11 w-full rounded-lg" style={{ background: 'var(--color-brand-divider)', opacity: 0.3, animation: 'pulse 1.5s ease-in-out infinite' }} />
                      </div>
                    ))}
                  </div>
                </div>

                {/* Contacto */}
                <div>
                  <div className="h-5 w-28 rounded mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                  <div className="space-y-6">
                    {Array.from({ length: 2 }).map((_, i) => (
                      <div key={i} className="form-group">
                        <div className="h-4 w-20 rounded mb-2" style={{ background: 'var(--color-brand-divider)', opacity: 0.5, animation: 'pulse 1.5s ease-in-out infinite' }} />
                        <div className="h-11 w-full rounded-lg" style={{ background: 'var(--color-brand-divider)', opacity: 0.3, animation: 'pulse 1.5s ease-in-out infinite' }} />
                      </div>
                    ))}
                  </div>
                </div>

                {/* Qualificação */}
                <div>
                  <div className="h-5 w-32 rounded mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                  <div className="space-y-6">
                    {Array.from({ length: 2 }).map((_, i) => (
                      <div key={i} className="form-group">
                        <div className="h-4 w-24 rounded mb-2" style={{ background: 'var(--color-brand-divider)', opacity: 0.5, animation: 'pulse 1.5s ease-in-out infinite' }} />
                        <div className="h-11 w-full rounded-lg" style={{ background: 'var(--color-brand-divider)', opacity: 0.3, animation: 'pulse 1.5s ease-in-out infinite' }} />
                      </div>
                    ))}
                  </div>
                </div>

                {/* Origem */}
                <div>
                  <div className="h-5 w-36 rounded mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
                  <div className="form-group">
                    <div className="h-4 w-28 rounded mb-2" style={{ background: 'var(--color-brand-divider)', opacity: 0.5, animation: 'pulse 1.5s ease-in-out infinite' }} />
                    <div className="h-11 w-full rounded-lg" style={{ background: 'var(--color-brand-divider)', opacity: 0.3, animation: 'pulse 1.5s ease-in-out infinite' }} />
                  </div>
                </div>

                {/* Submit button */}
                <div className="h-12 w-full rounded-lg" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  )
}
