export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Hero — título + subtítulo centrados */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={pulse} />
            <div className="h-5 w-96 mx-auto rounded" style={{ ...pulse, opacity: 0.6 }} />
          </div>
        </div>
      </section>

      {/* Grid de cursos — espelha guide-course-card (ícone circular + título + desc) */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            {Array.from({ length: 4 }).map((_, i) => (
              <div
                key={i}
                className="rounded-2xl p-6"
                style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-bg)' }}
              >
                <div className="w-16 h-16 rounded-full mb-4" style={pulse} />
                <div className="h-6 w-3/4 rounded mb-3" style={pulse} />
                <div className="h-4 w-full rounded mb-2" style={pulse} />
                <div className="h-4 w-2/3 rounded mb-6" style={pulse} />
                <div className="h-4 w-24 rounded" style={pulse} />
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
