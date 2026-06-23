import Link from 'next/link'

// Editorial 404 — botanical/herbarium style. Reuses site brand colours
// (--primary, --ink, --rule) and fonts (Fraunces, Inter, JetBrains Mono).
// Mobile-responsive via .not-found-* rules in styles/globals.css.
export default function NotFound() {
  return (
    <div className="not-found-page">
      <header className="not-found-top-strip">
        <img
          src="/logo/logo-principal-verde.svg"
          alt="Conheça Farmácia"
          className="not-found-logo"
        />
        <span className="not-found-top-meta">2026</span>
      </header>

      <main className="not-found-stage">
        {/* Left: botanical illustration */}
        <div className="not-found-left">
          <div className="not-found-botanical">
            <svg
              viewBox="0 0 400 400"
              xmlns="http://www.w3.org/2000/svg"
              strokeLinecap="round"
              aria-hidden="true"
            >
              {/* Stem */}
              <path
                d="M200 380 Q 200 280, 200 60"
                stroke="#00493a"
                strokeWidth="2"
                fill="none"
              />

              {/* Leaves (paired) */}
              <g stroke="#00493a" strokeWidth="1.4" fill="none">
                <path d="M200 320 Q 240 310, 270 280 Q 280 270, 290 250 Q 270 260, 240 280 Q 215 300, 200 320 Z" />
                <path d="M200 240 Q 248 230, 282 195 Q 295 184, 305 162 Q 282 175, 248 200 Q 220 222, 200 240 Z" />
                <path d="M200 160 Q 240 148, 268 115 Q 278 100, 285 78 Q 268 92, 242 116 Q 218 138, 200 160 Z" />

                <path d="M200 290 Q 160 280, 130 250 Q 120 240, 110 220 Q 130 230, 160 250 Q 185 270, 200 290 Z" />
                <path d="M200 210 Q 152 200, 118 165 Q 105 154, 95 132 Q 118 145, 152 170 Q 180 192, 200 210 Z" />
                <path d="M200 130 Q 160 118, 132 85 Q 122 70, 115 48 Q 132 62, 158 86 Q 182 108, 200 130 Z" />

                {/* Leaf veins (subtle) */}
                <path d="M200 320 L 270 280" stroke="#00493a" strokeWidth="0.6" opacity="0.5" />
                <path d="M200 240 L 282 195" stroke="#00493a" strokeWidth="0.6" opacity="0.5" />
                <path d="M200 160 L 268 115" stroke="#00493a" strokeWidth="0.6" opacity="0.5" />
                <path d="M200 290 L 130 250" stroke="#00493a" strokeWidth="0.6" opacity="0.5" />
                <path d="M200 210 L 118 165" stroke="#00493a" strokeWidth="0.6" opacity="0.5" />
                <path d="M200 130 L 132 85" stroke="#00493a" strokeWidth="0.6" opacity="0.5" />
              </g>

              {/* Small flowers at top */}
              <g fill="none" stroke="#7c2d2d" strokeWidth="1.2">
                <circle cx="200" cy="50" r="6" />
                <circle cx="190" cy="42" r="4" />
                <circle cx="210" cy="42" r="4" />
                <circle cx="195" cy="34" r="3.5" />
                <circle cx="205" cy="34" r="3.5" />
              </g>

              {/* Root */}
              <g stroke="#00493a" strokeWidth="1.4" fill="none">
                <path d="M200 380 Q 195 388, 188 392" />
                <path d="M200 380 Q 205 388, 212 392" />
                <path d="M200 380 Q 200 392, 200 398" />
              </g>

              {/* Annotation marks (botanical plate style) */}
              <g
                fontFamily="JetBrains Mono, monospace"
                fill="#5a5650"
                fontSize="8"
                letterSpacing="1"
              >
                <line x1="290" y1="250" x2="320" y2="250" stroke="#5a5650" strokeWidth="0.5" />
                <text x="324" y="252">FOLIA OP</text>
                <line x1="95" y1="132" x2="60" y2="132" stroke="#5a5650" strokeWidth="0.5" />
                <text x="20" y="134">FOLIA INF</text>
                <line x1="200" y1="50" x2="220" y2="30" stroke="#7c2d2d" strokeWidth="0.5" />
                <text x="224" y="32" fill="#7c2d2d">FLOS</text>
              </g>
            </svg>

            {/* Herbarium card overlay */}
            <div className="not-found-herbarium">
              <div className="not-found-herbarium-row">
                <span className="not-found-label">Spec.</span>
                <span className="not-found-value">Pagina desiderata</span>
              </div>
              <div className="not-found-herbarium-row">
                <span className="not-found-label">N.º Cat.</span>
                <span className="not-found-value not-found-value--wine">404/NF</span>
              </div>
              <div className="not-found-herbarium-row">
                <span className="not-found-label">Coll.</span>
                <span className="not-found-value">C. F. (2026)</span>
              </div>
              <div className="not-found-herbarium-row">
                <span className="not-found-label">Status</span>
                <span className="not-found-value not-found-value--wine">non inventa</span>
              </div>
            </div>
          </div>
        </div>

        {/* Right: typography block */}
        <div className="not-found-right">
          <div className="not-found-eyebrow">Item N.º 404 · Fora de Catálogo</div>

          <div className="not-found-number">404</div>

          <h1 className="not-found-title">
            Este item não consta
            <br />
            no nosso catálogo.
          </h1>

          <p className="not-found-body">
            A página solicitada foi retirada do catálogo, arquivada por
            motivos editoriais, ou o endereço introduzido contém um erro
            tipográfico.
          </p>

          <Link href="/pt" className="not-found-cta">
            Regressar ao índice
          </Link>

          <div className="not-found-secondary">
            Ou consultar:&nbsp;
            <Link href="/pt/artigos">Artigos</Link>·
            <Link href="/pt/eventos">Eventos</Link>·
            <Link href="/pt/lives">Lives</Link>·
            <Link href="/pt/pesquisa">Pesquisa</Link>
          </div>
        </div>
      </main>

      <footer className="not-found-bottom-strip">
        <span>Pág. 404 / NF</span>
        <span>↓ procurar item válido</span>
      </footer>
    </div>
  )
}
