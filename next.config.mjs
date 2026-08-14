/** @type {import('next').NextConfig} */
const nextConfig = {
  poweredByHeader: false, // LOW-02: remove X-Powered-By to reduce fingerprinting
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.supabase.co',
        pathname: '/storage/v1/object/public/**',
      },
    ],
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production'
      ? { exclude: ['error', 'warn'] }
      : false,
  },
  // Packages with native bindings (N-API / WASM) cannot be bundled by
  // Turbopack — they must be externalized so Node loads them at runtime.
  // `resvg-js` includes a native renderer used by the comprovativo PDF
  // generation pipeline (app/api/comprovativo/[id]/pdf/route.js).
  serverExternalPackages: ['@resvg/resvg-js'],

  // SEC-UMN-04 (auditoria "O Sentinela" #7): security headers em todas as
  // rotas. A Content-Security-Policy NÃO é definida aqui — fonte única é o
  // proxy.js (middleware), que gera um nonce por pedido (script-src
  // 'nonce-...', sem 'unsafe-inline'/'unsafe-eval'). Headers de middleware
  // são sobrescritos pelos de next.config para o mesmo header, por isso um
  // CSP aqui anularia o nonce do proxy. Os restantes headers (frame/type/
  // referrer/permissions/HSTS/COOP) são redundantes com o vercel.json mas
  // inofensivos.
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=(), payment=(), usb=()' },
          { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
          { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
        ],
      },
    ]
  },

  // Lives/webinars fundidas em /eventos (migração 159) — links antigos
  // /lives e /lives/{slug} redirecionam para o evento correspondente.
  async redirects() {
    return [
      { source: '/pt/lives', destination: '/pt/eventos', permanent: true },
      { source: '/en/lives', destination: '/en/events', permanent: true },
      { source: '/pt/lives/:path*', destination: '/pt/eventos/:path*', permanent: true },
      { source: '/en/lives/:path*', destination: '/en/events/:path*', permanent: true },
    ]
  },
};

export default nextConfig;
