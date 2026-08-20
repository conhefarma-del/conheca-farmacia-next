export default function Loading() {
  const pulse = {
    background: 'var(--color-brand-divider)',
    animation: 'pulse 1.5s ease-in-out infinite',
  }

  const pulseLight = {
    background: 'var(--color-brand-divider)',
    animation: 'pulse 1.5s ease-in-out infinite',
    opacity: 0.4,
  }

  return (
    <>
      {/* ===== HERO SKELETON ===== */}
      <section className="profile-hero-v2">
        <div className="container-center">
          <div className="profile-hero-inner">
            {/* Avatar */}
            <div className="w-22 h-22 rounded-full" style={{ ...pulse, opacity: 0.3, width: 88, height: 88 }} />
            <div className="profile-hero-info">
              {/* Name row */}
              <div className="flex items-center gap-2">
                <div className="h-8 w-48 rounded-lg" style={{ ...pulse, opacity: 0.3 }} />
                <div className="w-7 h-7 rounded-md" style={{ ...pulse, opacity: 0.2 }} />
              </div>
              {/* Email */}
              <div className="h-4 w-40 rounded mt-2" style={{ ...pulse, opacity: 0.2 }} />
              {/* Tags */}
              <div className="flex gap-2 mt-3">
                <div className="h-6 w-36 rounded-md" style={{ ...pulse, opacity: 0.2 }} />
                <div className="h-6 w-14 rounded-md" style={{ ...pulse, opacity: 0.2 }} />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== STATS SKELETON ===== */}
      <section className="profile-stats-v2">
        <div className="container-center">
          <div className="profile-stats-grid">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="profile-stat-card">
                <div className="profile-stat-top">
                  <div className="w-10 h-10 rounded-xl" style={{ ...pulse, opacity: 0.15 }} />
                </div>
                <div className="h-9 w-16 mx-auto rounded-lg mb-2" style={{ ...pulse, opacity: 0.2 }} />
                <div className="h-3 w-20 mx-auto rounded" style={{ ...pulseLight }} />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ===== CONTENT SKELETON ===== */}
      <section className="profile-content-v2">
        <div className="container-center">
          <div className="profile-grid-v2">
            {/* Tools card skeleton */}
            <div className="profile-card-v2">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-1.5 h-1.5 rounded-full" style={{ background: 'var(--color-brand-accent)', opacity: 0.4 }} />
                <div className="h-4 w-24 rounded" style={{ ...pulse, opacity: 0.6 }} />
              </div>
              <div className="flex gap-3 overflow-hidden">
                {Array.from({ length: 4 }).map((_, i) => (
                  <div key={i} className="flex-shrink-0 w-28 rounded-xl p-3 text-center" style={{ border: '1px solid var(--color-brand-divider)' }}>
                    <div className="w-9 h-9 rounded-lg mx-auto mb-2" style={{ ...pulse, opacity: 0.15 }} />
                    <div className="h-3 w-16 mx-auto rounded" style={{ ...pulse, opacity: 0.3 }} />
                  </div>
                ))}
              </div>
            </div>

            {/* Institution card skeleton */}
            <div className="profile-card-v2">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-1.5 h-1.5 rounded-full" style={{ background: 'var(--color-brand-accent)', opacity: 0.4 }} />
                <div className="h-4 w-24 rounded" style={{ ...pulse, opacity: 0.6 }} />
              </div>
              <div className="space-y-0">
                {Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} className="flex items-center gap-3 py-3" style={{ borderBottom: i < 2 ? '1px solid var(--color-brand-divider)' : 'none' }}>
                    <div className="w-7 h-7 rounded-lg flex-shrink-0" style={{ ...pulse, opacity: 0.12 }} />
                    <div className="flex-1">
                      <div className="h-3 w-12 rounded mb-1.5" style={{ ...pulse, opacity: 0.3 }} />
                      <div className="h-4 w-28 rounded" style={{ ...pulse, opacity: 0.5 }} />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Competition history skeleton */}
          <div className="profile-card-v2 mt-5">
            <div className="flex items-center gap-2 mb-4">
              <div className="w-1.5 h-1.5 rounded-full" style={{ background: 'var(--color-brand-accent)', opacity: 0.4 }} />
              <div className="h-4 w-40 rounded" style={{ ...pulse, opacity: 0.6 }} />
            </div>
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 py-3" style={{ borderBottom: i < 2 ? '1px solid var(--color-brand-divider)' : 'none' }}>
                <div className="w-8 h-8 rounded-lg flex-shrink-0" style={{ ...pulse, opacity: 0.12 }} />
                <div className="flex-1 min-w-0">
                  <div className="h-4 w-36 rounded mb-1" style={{ ...pulse, opacity: 0.5 }} />
                  <div className="h-3 w-28 rounded" style={{ ...pulse, opacity: 0.3 }} />
                </div>
                <div className="text-right flex-shrink-0">
                  <div className="h-5 w-12 rounded mb-1 ml-auto" style={{ ...pulse, opacity: 0.5 }} />
                  <div className="h-2.5 w-10 rounded ml-auto" style={{ ...pulse, opacity: 0.3 }} />
                </div>
              </div>
            ))}
          </div>

          {/* Logout button skeleton */}
          <div className="h-11 w-full rounded-xl mt-6" style={{ ...pulse, opacity: 0.15, border: '1px solid var(--color-brand-divider)' }} />
        </div>
      </section>
    </>
  )
}
