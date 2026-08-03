export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Hero — título + subtítulo centrados */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={pulse} />
            <div className="h-5 w-96 mx-auto rounded" style={{ ...pulse, opacity: 0.6 }} />
          </div>
        </div>
      </section>

      {/* Calculadora — painel de input + painel de resultados */}
      <div className="calc-layout">
        <aside className="calc-input-panel">
          <div className="h-4 w-44 rounded mb-6" style={pulse} />
          <div className="h-12 w-full rounded-xl mb-3" style={pulse} />
          <div className="h-11 w-full rounded-xl mb-3" style={pulse} />
          <div className="h-9 w-36 rounded-xl mb-6" style={pulse} />
          <div className="h-4 w-full rounded mb-2" style={{ ...pulse, opacity: 0.6 }} />
          <div className="h-4 w-4/5 rounded mb-8" style={{ ...pulse, opacity: 0.6 }} />
          <div className="h-3 w-full rounded" style={{ ...pulse, opacity: 0.4 }} />
        </aside>

        <main className="calc-results-panel">
          {Array.from({ length: 3 }).map((_, i) => (
            <div
              key={i}
              className="rounded-2xl p-6 mb-4"
              style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-bg)' }}
            >
              <div className="flex gap-3 mb-5">
                <div className="h-7 w-20 rounded-full" style={pulse} />
                <div className="h-7 w-24 rounded-full" style={pulse} />
              </div>
              <div className="h-5 w-3/4 rounded mb-3" style={pulse} />
              <div className="h-4 w-full rounded mb-2" style={pulse} />
              <div className="h-4 w-2/3 rounded" style={pulse} />
            </div>
          ))}
        </main>
      </div>
    </div>
  )
}
