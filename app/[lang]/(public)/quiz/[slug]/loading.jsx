export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen quiz-session">
      <div className="h-4 w-32 rounded mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
      <div className="flex justify-between items-center mb-3">
        <div className="h-7 w-40 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
        <div className="h-4 w-28 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
      </div>
      <div className="h-1.5 rounded-full mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
      <div className="rounded-2xl p-6" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
        <div className="h-5 w-24 rounded-full mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
        <div className="h-5 w-3/4 rounded mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
        {[0, 1, 2, 3].map((i) => (
          <div key={i} className="h-12 rounded-xl mb-2.5" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.4 }} />
        ))}
      </div>
    </div>
  )
}
