export default function HeroSection({ title, subtitle, sectionClass, className = '', children }) {
  return (
    <section className={sectionClass || 'articles-hero'}>
      <div className={`max-w-[1400px] mx-auto px-6 md:px-12 text-center ${className}`}>
        <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">{title}</h1>
        {subtitle && <p className="hero-subtitle text-center">{subtitle}</p>}
        {children}
      </div>
    </section>
  )
}
