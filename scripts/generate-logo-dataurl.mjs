// One-off script: convert public/logo/logo-principal-branco.svg to a PNG
// data URL file (lib/pdf/logo-dataurl.txt) so the API route can read it
// from the filesystem without dealing with SVG parsing or CORS.
//
// Re-run this when the logo SVG changes:
//   node scripts/generate-logo-dataurl.mjs

import { readFileSync, writeFileSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const projectRoot = join(__dirname, '..')

const svgPath = join(projectRoot, 'public', 'logo', 'logo-principal-branco.svg')
const pngPath = join(projectRoot, 'public', 'logo', 'logo-principal-branco.png')

// Convert via @resvg/resvg-js (already installed)
const { Resvg } = await import('@resvg/resvg-js')
const svg = readFileSync(svgPath, 'utf-8')
const resvg = new Resvg(svg, {
  fitTo: { mode: 'width', value: 600 }, // 2x density at 300px display width
  background: 'rgba(0, 0, 0, 0)',
})
const pngBuffer = resvg.render().asPng()
writeFileSync(pngPath, pngBuffer)
console.log(`Wrote ${pngPath} (${pngBuffer.length} bytes)`)
