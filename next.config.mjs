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
  // Turbopack built-in module type for binary assets. Without this, the
  // build fails with "Unknown module type" on .woff imports because
  // Turbopack does not recognise fonts as placeable modules. `type: 'bytes'`
  // (supported since Next.js 16.2.0) inlines the file as a Uint8Array, which
  // Satori's loadFont accepts directly via Buffer.from().
  turbopack: {
    rules: {
      '*.woff': { type: 'bytes' },
      '*.woff2': { type: 'bytes' },
    },
  },
};

export default nextConfig;
