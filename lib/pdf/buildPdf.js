// PDF generation pipeline (server-side, Node runtime):
//
//   <ComprovativoSatori /> JSX
//     → satori 0.26 (JSX → SVG, fonts passed via the `fonts` option —
//       the old satori.loadFont() API no longer exists in 0.26 and was
//       one of the root causes of the retired empty/broken PDF output)
//     → resvg-js (SVG → PNG buffer, 2x density for crisp output)
//     → pdf-lib (PNG → single-page A4 landscape PDF, drawn to fill page)
//
// Fonts: brand fonts Inter (sans) + Fraunces (serif), read from
// public/fonts/ via fs. Why not `import font from '@fontsource/...'`:
// in the Next.js build, static asset imports resolve to an asset URL
// (string), not file bytes — satori needs the actual ArrayBuffer. Reading
// from public/ works identically in dev and on Vercel (files are shipped
// with the deployment) and matches how the logo data URL is loaded.
//
// NOTE: satori does not render emoji glyphs — do not reintroduce emoji
// characters in ComprovativoSatori.jsx (they silently drop from the SVG).

import satori from 'satori'
import { Resvg } from '@resvg/resvg-js'
import { PDFDocument } from 'pdf-lib'
import { readFile } from 'fs/promises'
import path from 'path'

// Image dimensions (logical pixels in Satori). 1300x920 = 1.413:1 —
// matches A4 landscape (842:595pt = 1.414:1) so the image fills the
// whole page without letterboxing.
const IMG_W = 1300
const IMG_H = 920

// A4 landscape in points (PDF coordinate system, 1pt = 1/72 inch).
const PAGE_W_PT = 842 // 297mm
const PAGE_H_PT = 595 // 210mm

const SCALE = 2 // 2x render for crisp text in the PDF

const FONT_FILES = [
  { name: 'Inter', file: 'inter-latin-400-normal.woff', weight: 400 },
  { name: 'Inter', file: 'inter-latin-500-normal.woff', weight: 500 },
  { name: 'Inter', file: 'inter-latin-600-normal.woff', weight: 600 },
  { name: 'Inter', file: 'inter-latin-700-normal.woff', weight: 700 },
  { name: 'Fraunces', file: 'fraunces-latin-400-normal.woff', weight: 400 },
  { name: 'Fraunces', file: 'fraunces-latin-600-normal.woff', weight: 600 },
  { name: 'Fraunces', file: 'fraunces-latin-700-normal.woff', weight: 700 },
]

async function loadFonts() {
  const dir = path.join(process.cwd(), 'public', 'fonts')
  return Promise.all(
    FONT_FILES.map(async (f) => ({
      name: f.name,
      data: await readFile(path.join(dir, f.file)),
      weight: f.weight,
      style: 'normal',
    }))
  )
}

export async function buildComprovativoPdf(jsx) {
  const fonts = await loadFonts()

  // 1. JSX → SVG
  const svg = await satori(jsx, {
    width: IMG_W,
    height: IMG_H,
    fonts,
  })

  // 2. SVG → PNG (2x density for retina-quality PDF)
  const resvg = new Resvg(svg, {
    fitTo: { mode: 'width', value: IMG_W * SCALE },
  })
  const pngBuffer = resvg.render().asPng()

  // 3. PNG → PDF (single page, image drawn to fill)
  const pdf = await PDFDocument.create()
  const page = pdf.addPage([PAGE_W_PT, PAGE_H_PT])
  const png = await pdf.embedPng(pngBuffer)

  // Draw the image to cover the entire page (preserves aspect ratio)
  const aspect = IMG_W / IMG_H
  const pageAspect = PAGE_W_PT / PAGE_H_PT // 1.414
  let drawW, drawH, drawX, drawY
  if (aspect > pageAspect) {
    // image is wider — fit by width, pad top/bottom
    drawW = PAGE_W_PT
    drawH = PAGE_W_PT / aspect
    drawX = 0
    drawY = (PAGE_H_PT - drawH) / 2
  } else {
    // image is taller — fit by height, pad left/right
    drawH = PAGE_H_PT
    drawW = PAGE_H_PT * aspect
    drawY = 0
    drawX = (PAGE_W_PT - drawW) / 2
  }
  page.drawImage(png, { x: drawX, y: drawY, width: drawW, height: drawH })

  return await pdf.save()
}
