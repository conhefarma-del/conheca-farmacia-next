export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen max-w-[900px] mx-auto px-6 py-6">
      <div className="h-4 w-40 rounded mb-8" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
      {/* Cabeçalho da sessão */}
      <div className="flex justify-between items-center mb-6">
        <div className="h-7 w-64 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
        <div className="h-4 w-44 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
      </div>
      {/* Barra de progresso */}
      <div className="h-1.5 rounded-full w-full mb-8" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
      {/* Flip card */}
      <div className="rounded-3xl p-10 min-h-[380px] flex flex-col" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
        <div className="h-3.5 w-32 rounded-full mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
        <div className="h-5 w-4/5 rounded mb-2.5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
        <div className="h-5 w-3/5 rounded mb-2.5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
        <div className="h-5 w-1/3 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
        <div className="mt-auto mx-auto h-4 w-56 rounded flex items-center justify-center" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.4 }}>
          <div className="h-3 w-3 rounded-full mr-2" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
        </div>
      </div>
      {/* Botões SM-2 */}
      <div className="grid grid-cols-4 gap-2.5 mt-7">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="h-16 rounded-2xl" style={{ ...pulse, border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }} />
        ))}
      </div>
      {/* Stats */}
      <div className="grid grid-cols-3 gap-2.5 mt-6">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="h-16 rounded-xl" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
        ))}
      </div>
    </div>
  )
}
