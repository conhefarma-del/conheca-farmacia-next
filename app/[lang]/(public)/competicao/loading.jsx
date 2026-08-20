export default function CompeticaoLoading() {
  return (
    <>
      {/* Hero skeleton */}
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-20 md:py-32">
            <div className="w-12 h-12 rounded-full bg-brand-accent/10 mx-auto mb-4 animate-pulse" />
            <div className="h-14 w-96 mx-auto bg-brand-deep/5 rounded-2xl mb-4 animate-pulse" />
            <div className="h-6 w-80 mx-auto bg-brand-deep/5 rounded-lg animate-pulse" />
          </div>
        </div>
      </section>

      {/* Form skeleton */}
      <section className="py-16 bg-background">
        <div className="container-center max-w-xl mx-auto px-4 space-y-6">
          <div className="h-6 w-48 bg-brand-deep/5 rounded-lg animate-pulse" />
          <div className="h-16 w-full bg-brand-deep/5 rounded-2xl animate-pulse" />
          <div className="h-14 w-full bg-brand-accent/20 rounded-2xl animate-pulse" />
        </div>
      </section>
    </>
  )
}
