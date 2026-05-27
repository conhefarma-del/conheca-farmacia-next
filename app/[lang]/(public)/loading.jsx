export default function Loading() {
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="bg-brand-deep text-white py-20">
        <div className="container-center max-w-7xl mx-auto px-4 text-center">
          <div className="h-12 w-96 mx-auto bg-white/20 rounded animate-pulse mb-6" />
          <div className="h-5 w-80 mx-auto bg-white/10 rounded animate-pulse mb-4" />
          <div className="h-5 w-64 mx-auto bg-white/10 rounded animate-pulse" />
        </div>
      </section>

      {/* Featured Articles */}
      <section className="container-center max-w-7xl mx-auto px-4 py-12">
        <div className="h-8 w-48 bg-gray-200 dark:bg-gray-700 rounded animate-pulse mb-8" />
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="article-card animate-pulse">
              <div className="bg-gray-200 dark:bg-gray-700 h-48 rounded-t-lg" />
              <div className="p-4 space-y-3">
                <div className="h-4 w-20 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-5 w-3/4 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded" />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Featured Events */}
      <section className="container-center max-w-7xl mx-auto px-4 py-12">
        <div className="h-8 w-48 bg-gray-200 dark:bg-gray-700 rounded animate-pulse mb-8" />
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {Array.from({ length: 2 }).map((_, i) => (
            <div key={i} className="event-card animate-pulse">
              <div className="bg-gray-200 dark:bg-gray-700 h-48 rounded-t-lg" />
              <div className="p-4 space-y-3">
                <div className="h-4 w-24 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-5 w-3/4 bg-gray-200 dark:bg-gray-700 rounded" />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Stats */}
      <section className="container-center max-w-7xl mx-auto px-4 py-12">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="text-center animate-pulse">
              <div className="h-10 w-20 mx-auto bg-gray-200 dark:bg-gray-700 rounded mb-2" />
              <div className="h-4 w-24 mx-auto bg-gray-200 dark:bg-gray-700 rounded" />
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
