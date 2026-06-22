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
};

export default nextConfig;
