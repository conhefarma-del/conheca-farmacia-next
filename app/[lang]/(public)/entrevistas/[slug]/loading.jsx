export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      {/* Breadcrumb */}
      <nav style={{ padding: '16px 0' }}>
        <div className="container-center">
          <div className="flex gap-2">
            <div className="h-4 w-16 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.4 }} />
            <div className="h-4 w-4 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.3 }} />
            <div className="h-4 w-24 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.4 }} />
            <div className="h-4 w-4 rounded" style={{ background: 'var(--color-brand-divider)', opacity: 0.3 }} />
            <div className="h-4 w-40 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.4 }} />
          </div>
        </div>
      </nav>

      <div className="interview-layout">
        {/* COLUNA PRINCIPAL 2/3 */}
        <div className="interview-main">
          {/* Hero do artigo */}
          <div className="mb-6">
            <div className="h-6 w-28 rounded-full mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-10 w-5/6 max-w-full rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-4 w-2/3 max-w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="flex gap-3 mt-4">
              {[0, 1, 2].map((i) => (
                <div key={i} className="h-4 w-20 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
              ))}
            </div>
          </div>

          {/* Pessoas (entrevistados + entrevistador) */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
            {[0, 1].map((i) => (
              <div key={i} className="flex items-center gap-3 rounded-xl p-4" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
                <div className="h-11 w-11 rounded-full flex-shrink-0" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="space-y-2 flex-1">
                  <div className="h-3 w-16 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  <div className="h-4 w-3/4 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="h-3 w-1/2 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                </div>
              </div>
            ))}
          </div>

          {/* Vídeo / áudio */}
          <div className="w-full rounded-2xl mb-6" style={{ aspectRatio: '16 / 9', ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />

          {/* Sumário + conteúdo */}
          <div className="rounded-xl p-5 mb-6" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
            <div className="h-3 w-20 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
            <div className="h-4 w-full rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
            <div className="h-4 w-5/6 rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
            <div className="h-4 w-2/3 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
          </div>

          <div className="space-y-3">
            <div className="h-4 w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-4 w-11/12 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-4 w-4/5 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-4 w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-4 w-3/4 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
        </div>

        {/* SIDEBAR 1/3 */}
        <aside className="interview-sidebar">
          {[0, 1, 2, 3].map((i) => (
            <div key={i} className="rounded-2xl p-5 mb-4" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
              <div className="h-3 w-24 rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-full flex-shrink-0" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="space-y-2 flex-1">
                  <div className="h-4 w-3/4 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="h-3 w-1/2 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                </div>
              </div>
            </div>
          ))}
        </aside>
      </div>
    </div>
  )
}
