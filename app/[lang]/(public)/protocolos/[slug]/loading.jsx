export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }

  return (
    <div className="min-h-screen">
      {/* Breadcrumb + barra de progresso */}
      <div className="container-center pt-8">
        <div className="h-5 w-64 rounded mb-6" style={{ ...pulse, opacity: 0.6 }} />
        <div
          className="rounded-full mb-8"
          style={{ ...pulse, opacity: 0.5, height: 8, maxWidth: 1100, margin: '0 auto' }}
        />
      </div>

      {/* Layout 2 colunas: conteúdo + sidebar */}
      <div className="protocol-detail-layout">
        <main>
          {/* Hero do protocolo — badges + título + meta */}
          <div className="protocol-hero">
            <div className="flex gap-2 mb-4">
              <div className="h-6 w-20 rounded-full" style={pulse} />
              <div className="h-6 w-24 rounded-full" style={pulse} />
            </div>
            <div className="h-8 w-2/3 rounded-lg mb-4" style={pulse} />
            <div className="h-4 w-96 max-w-full rounded" style={{ ...pulse, opacity: 0.6 }} />
          </div>

          {/* Resumo rápido */}
          <div className="quick-summary mb-6">
            <div className="h-4 w-24 rounded mb-3" style={pulse} />
            <div className="h-4 w-full rounded mb-2" style={pulse} />
            <div className="h-4 w-3/4 rounded" style={pulse} />
          </div>

          {/* Passos */}
          {Array.from({ length: 3 }).map((_, i) => (
            <div
              key={i}
              className="rounded-2xl p-5 mb-4"
              style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-bg)' }}
            >
              <div className="h-5 w-1/3 rounded mb-3" style={pulse} />
              <div className="h-4 w-full rounded mb-2" style={pulse} />
              <div className="h-4 w-2/3 rounded" style={pulse} />
            </div>
          ))}
        </main>

        <aside className="protocol-sidebar">
          <div
            className="rounded-2xl p-5"
            style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-bg)' }}
          >
            <div className="h-5 w-32 rounded mb-4" style={pulse} />
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-4 w-full rounded mb-3" style={pulse} />
            ))}
            <div className="h-4 w-1/2 rounded" style={pulse} />
          </div>
        </aside>
      </div>
    </div>
  )
}
