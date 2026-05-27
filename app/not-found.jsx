import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-brand-bg px-6">
      <div className="text-center max-w-md">
        {/* Logo */}
        <div className="mb-8">
          <img
            src="/logo/logo-principal-verde.svg"
            alt="Conheça Farmácia"
            className="h-10 mx-auto"
          />
        </div>

        {/* 404 */}
        <h1 className="font-display text-6xl font-bold text-brand-deep mb-4">
          404
        </h1>
        <h2 className="text-xl font-semibold text-brand-deep mb-3">
          Página não encontrada
        </h2>
        <p className="text-gray-500 mb-8 leading-relaxed">
          A página que procura não existe ou foi movida.
        </p>

        {/* CTA */}
        <Link
          href="/pt"
          className="inline-flex items-center gap-2 px-6 py-3 bg-brand-accent text-white rounded-xl font-semibold hover:bg-brand-accent/90 transition-colors"
        >
          <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M19 12H5M12 19l-7-7 7-7" />
          </svg>
          Voltar ao Início
        </Link>
      </div>
    </div>
  )
}
