export default function Loading() {
  const pulse = { opacity: 0.6, animation: "pulse 2s infinite" };
  return (
    <div className="min-h-screen">
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="h-12 w-64 mx-auto rounded-lg mb-4" style={pulse} />
            <div className="h-5 w-80 mx-auto rounded" style={pulse} />
          </div>
        </div>
      </section>
      <div className="container-center">
        <div className="rounded-2xl p-6 mb-6" style={pulse} />
        <div className="drug-list-grid">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="drug-list-card" style={pulse}>
              <div className="drug-list-card-main">
                <div className="h-5 w-40 rounded mb-2" style={pulse} />
                <div className="h-4 w-28 rounded" style={pulse} />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
