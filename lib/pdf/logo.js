// Embeds brand logo SVG as a PNG data URL so Satori can render it without
// external fetches, CORS, or filesystem reads.
//
// We convert the white-on-transparent logo (logo-principal-branco.svg) to PNG
// at 2x density using the browser Canvas API in a one-off Node script (see
// scripts/generate-logo-dataurl.mjs). The PNG is read at module load and
// cached as a string for the route handler.
//
// Re-generate when the SVG changes:
//   node scripts/generate-logo-dataurl.mjs

import { readFileSync } from 'node:fs'
import { join } from 'node:path'

let cached = null

export function getLogoDataUrl() {
  if (cached) return cached
  // path is relative to the project root; the API route is at app/api/...
  const path = join(process.cwd(), 'public', 'logo', 'logo-principal-branco.png')
  const buffer = readFileSync(path)
  cached = `data:image/png;base64,${buffer.toString('base64')}`
  return cached
}
