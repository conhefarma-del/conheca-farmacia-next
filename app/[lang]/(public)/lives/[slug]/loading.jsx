export default function Loading() {
  return (
    <div className="min-h-screen animate-pulse">
      <div className="h-64 w-full bg-gray-200 dark:bg-gray-700" />
      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="h-4 w-32 bg-gray-200 dark:bg-gray-700 rounded mb-6" />
        <div className="h-8 w-3/4 bg-gray-200 dark:bg-gray-700 rounded mb-4" />
        <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded mb-2" />
        <div className="h-4 w-5/6 bg-gray-200 dark:bg-gray-700 rounded mb-8" />
        <div className="h-12 w-full bg-gray-200 dark:bg-gray-700 rounded-lg" />
      </div>
    </div>
  )
}
