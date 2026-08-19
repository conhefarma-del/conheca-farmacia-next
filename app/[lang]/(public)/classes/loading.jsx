export default function Loading() {
  const pulse = {
    background: "var(--color-brand-divider)",
    animation: "pulse 1.5s ease-in-out infinite",
  };

  return (
    <div className="min-h-screen">
      {/* Hero — título + subtítulo centrados */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-80 mx-auto rounded-lg mb-6" style={pulse} />
            <div
              className="h-5 w-96 max-w-full mx-auto rounded"
              style={{ ...pulse, opacity: 0.6 }}
            />
          </div>
        </div>
      </section>

      {/* Toolbar — pesquisa + filtros */}
      <div className="container-center">
        <div className="medicamentos-toolbar">
          <div className="h-10 w-full rounded-lg" style={{ ...pulse, opacity: 0.7 }} />
          <div className="flex flex-wrap items-center gap-3 mt-3">
            {[0, 1, 2].map((i) => (
              <div
                key={i}
                className="h-9 w-28 rounded-full"
                style={{ ...pulse, opacity: i === 0 ? 0.7 : 0.5 }}
              />
            ))}
          </div>
        </div>

        {/* Contagem */}
        <div className="h-4 w-48 rounded mb-6" style={{ ...pulse, opacity: 0.5 }} />

        {/* Grid de cards de classes */}
        <div className="drug-list-grid">
          {Array.from({ length: 8 }).map((_, i) => (
            <div
              key={i}
              className="rounded-2xl p-5"
              style={{
                border: "1px solid var(--color-brand-divider)",
                background: "var(--color-brand-bg)",
              }}
            >
              <div className="flex items-center justify-between mb-3">
                <div className="h-6 w-2/3 rounded" style={pulse} />
                <div className="h-4 w-16 rounded" style={{ ...pulse, opacity: 0.5 }} />
              </div>
              <div
                className="h-4 w-full rounded mb-2"
                style={{ ...pulse, opacity: 0.6 }}
              />
              <div
                className="h-4 w-4/5 rounded mb-3"
                style={{ ...pulse, opacity: 0.6 }}
              />
              <div className="flex items-center justify-between">
                <div
                  className="h-4 w-24 rounded"
                  style={{ ...pulse, opacity: 0.5 }}
                />
                <div
                  className="h-4 w-28 rounded"
                  style={{ ...pulse, opacity: 0.5 }}
                />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
