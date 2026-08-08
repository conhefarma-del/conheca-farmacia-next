export default function Loading() {
  const pulse = {
    background: "var(--color-brand-divider)",
    animation: "pulse 1.5s ease-in-out infinite",
  };

  return (
    <div className="min-h-screen">
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-72 mx-auto rounded-lg mb-6" style={pulse} />
            <div
              className="h-5 w-96 mx-auto rounded"
              style={{ ...pulse, opacity: 0.6 }}
            />
          </div>
        </div>
      </section>
      <div className="container-center">
        <div className="h-10 rounded-lg mb-6" style={pulse} />
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
              <div className="h-6 w-2/3 rounded mb-3" style={pulse} />
              <div
                className="h-4 w-1/2 rounded"
                style={{ ...pulse, opacity: 0.6 }}
              />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
