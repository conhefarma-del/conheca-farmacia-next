export default function Loading() {
  const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      <div className="max-w-4xl mx-auto px-6 md:px-12 py-10">
        {/* Botão voltar */}
        <div className="h-4 w-40 rounded mb-8" style={{ ...pulse, opacity: 0.5 }} />

        {/* Hero do alvo */}
        <div className="pb-8 mb-8" style={{ borderBottom: '1px solid var(--color-brand-divider)' }}>
          <div className="h-6 w-28 rounded-full mb-5" style={{ ...pulse, opacity: 0.6 }} />
          <div className="h-12 w-64 max-w-full rounded-lg mb-4" style={pulse} />
          <div className="h-5 w-96 max-w-full rounded" style={{ ...pulse, opacity: 0.6 }} />
        </div>

        {/* Secções de conteúdo */}
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="mb-8">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-4 w-4 rounded" style={pulse} />
              <div className="h-4 w-36 rounded" style={pulse} />
            </div>
            <div className="space-y-2">
              <div className="h-4 w-full rounded" style={{ ...pulse, opacity: 0.6 }} />
              <div className="h-4 w-11/12 rounded" style={{ ...pulse, opacity: 0.6 }} />
              <div className="h-4 w-4/5 rounded" style={{ ...pulse, opacity: 0.6 }} />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
