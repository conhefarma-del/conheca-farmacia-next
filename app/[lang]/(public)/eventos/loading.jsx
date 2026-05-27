export default function Loading() {
  return (
    <div className="min-h-screen">
      <section className="bg-brand-deep text-white py-16">
        <div className="container-center max-w-7xl mx-auto px-4 text-center">
          <div className="h-10 w-64 mx-auto bg-white/20 rounded animate-pulse mb-4" />
          <div className="h-5 w-96 mx-auto bg-white/10 rounded animate-pulse" />
        </div>
      </section>
      <section className="container-center max-w-7xl mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="event-card animate-pulse">
              <div className="bg-gray-200 dark:bg-gray-700 h-48 rounded-t-lg" />
              <div className="p-4 space-y-3">
                <div className="h-4 w-24 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-5 w-3/4 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded" />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
