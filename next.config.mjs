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
  // rotas. A CSP usa 'unsafe-inline'/'unsafe-eval' porque a app depende de
  // estilos inline e gsap; mesmo assim bloqueia fontes remotas de script,
  // object, clickjacking (frame-ancestors) e base-uri. Se o console dev
  // mostrar violações de CSP, afinar as diretivas — os headers de frame/type/
  // referrer/permissions já são seguros como estão.
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
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              "img-src 'self' data: blob: https://*.supabase.co",
              "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
              "style-src 'self' 'unsafe-inline'",
              "font-src 'self' data:",
              "connect-src 'self' https://*.supabase.co wss://*.supabase.co",
              "frame-ancestors 'none'",
              "base-uri 'self'",
              "form-action 'self'",
              "object-src 'none'",
            ].join('; '),
          },
        ],
      },
    ]
  },
};

export default nextConfig;
