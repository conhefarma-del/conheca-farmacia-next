export default function Loading() {
  const pulse = {
    background: 'var(--color-brand-divider)',
    animation: 'pulse 1.5s ease-in-out infinite',
  }

  return (
    <section className="py-20 bg-background">
      <div className="container-center max-w-md mx-auto px-4">
        {/* Icon + Title + Subtitle */}
        <div className="text-center mb-8">
          <div className="w-10 h-10 rounded-full mx-auto mb-4" style={{ ...pulse, opacity: 0.4 }} />
          <div className="h-9 w-24 mx-auto rounded-lg mb-3" style={pulse} />
          <div className="h-5 w-56 mx-auto rounded" style={{ ...pulse, opacity: 0.6 }} />
        </div>

        {/* Google button */}
        <div className="h-12 w-full rounded-xl mb-6" style={{ ...pulse, opacity: 0.5 }} />

        {/* Divider */}
        <div className="flex items-center gap-4 my-6">
          <div className="flex-1 h-px" style={pulse} />
          <div className="h-4 w-6 rounded" style={{ ...pulse, opacity: 0.4 }} />
          <div className="flex-1 h-px" style={pulse} />
        </div>

        {/* Email field */}
        <div className="space-y-4">
          <div>
            <div className="h-4 w-12 rounded mb-2" style={{ ...pulse, opacity: 0.6 }} />
            <div className="h-12 w-full rounded-xl" style={pulse} />
          </div>

          {/* Password field */}
          <div>
            <div className="h-4 w-16 rounded mb-2" style={{ ...pulse, opacity: 0.6 }} />
            <div className="h-12 w-full rounded-xl" style={pulse} />
          </div>

          {/* Submit button */}
          <div className="h-12 w-full rounded-xl" style={{ ...pulse, opacity: 0.7 }} />
        </div>

        {/* Footer link */}
        <div className="mt-6 text-center">
          <div className="h-4 w-40 mx-auto rounded" style={{ ...pulse, opacity: 0.4 }} />
        </div>
      </div>
    </section>
  )
}
