export default function Loading() {
  return (
    <div className="min-h-screen">
      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="h-4 w-32 rounded mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
        <div className="h-8 w-3/4 rounded mb-4" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
        <div className="h-4 w-48 rounded mb-8" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
        <div className="h-64 w-full rounded-lg mb-8" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
        <div className="space-y-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="h-4 rounded" style={{ width: `${85 - i * 5}%`, background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }} />
          ))}
        </div>
      </div>
    </div>
  )
}
