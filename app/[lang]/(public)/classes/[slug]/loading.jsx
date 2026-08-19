export default function Loading() {
  const pulse = {
    background: "var(--color-brand-divider)",
    animation: "pulse 1.5s ease-in-out infinite",
  };

  return (
    <div className="min-h-screen">
      {/* Hero — back link + título + ATC + contagem */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            {/* Back link */}
            <div
              className="h-4 w-40 mx-auto rounded mb-6"
              style={{ ...pulse, opacity: 0.5 }}
            />
            {/* Title */}
            <div className="h-12 w-72 mx-auto rounded-lg mb-4" style={pulse} />
            {/* ATC prefix */}
            <div
              className="h-4 w-24 mx-auto rounded mb-2"
              style={{ ...pulse, opacity: 0.4 }}
            />
            {/* Drug count */}
            <div
              className="h-5 w-40 mx-auto rounded"
              style={{ ...pulse, opacity: 0.6 }}
            />
          </div>
        </div>
      </section>

      <div className="container-center">
        {/* Secção "O que são" */}
        <section className="mb-8">
          <div className="flex items-center gap-2 mb-4">
            <div className="h-5 w-5 rounded" style={pulse} />
            <div className="h-5 w-32 rounded" style={pulse} />
          </div>
          <div className="space-y-2">
            <div
              className="h-4 w-full rounded"
              style={{ ...pulse, opacity: 0.6 }}
            />
            <div
              className="h-4 w-11/12 rounded"
              style={{ ...pulse, opacity: 0.6 }}
            />
            <div
              className="h-4 w-4/5 rounded"
              style={{ ...pulse, opacity: 0.6 }}
            />
            <div
              className="h-4 w-3/4 rounded"
              style={{ ...pulse, opacity: 0.6 }}
            />
          </div>
        </section>

        {/* Secção "Fármacos desta classe" */}
        <section>
          <div className="h-5 w-56 rounded mb-4" style={pulse} />
          <div className="drug-list-grid">
            {Array.from({ length: 6 }).map((_, i) => (
              <div
                key={i}
                className="rounded-2xl p-5"
                style={{
                  border: "1px solid var(--color-brand-divider)",
                  background: "var(--color-brand-bg)",
                }}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="h-6 w-2/3 rounded" style={pulse} />
                  <div
                    className="h-4 w-16 rounded"
                    style={{ ...pulse, opacity: 0.5 }}
                  />
                </div>
                <div className="flex items-center justify-end">
                  <div
                    className="h-4 w-28 rounded"
                    style={{ ...pulse, opacity: 0.5 }}
                  />
                </div>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}
