export default function Loading() {
  return (
    <div className="min-h-screen">
      <div className="max-w-4xl mx-auto px-4 py-12 animate-pulse">
        <div className="h-4 w-32 bg-gray-200 dark:bg-gray-700 rounded mb-6" />
        <div className="h-8 w-3/4 bg-gray-200 dark:bg-gray-700 rounded mb-4" />
        <div className="h-4 w-48 bg-gray-200 dark:bg-gray-700 rounded mb-8" />
        <div className="h-64 w-full bg-gray-200 dark:bg-gray-700 rounded-lg mb-8" />
        <div className="space-y-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="h-4 bg-gray-200 dark:bg-gray-700 rounded" style={{ width: `${85 - i * 5}%` }} />
          ))}
        </div>
      </div>
    </div>
  )
}
