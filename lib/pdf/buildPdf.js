// PDF generation pipeline (server-side, Edge compatible):
//
//   <ComprovativoSatori /> JSX
//     → satori (JSX → SVG, no fonts = uses Satori's default sans-serif)
//     → resvg-js (SVG → PNG buffer, 2x density for crisp output)
//     → pdf-lib (PNG → single-page A4 landscape PDF, drawn to fill page)
//
// We intentionally do NOT load Fraunces/Inter — Satori will use its built-in
// sans-serif (clean, universal, ~Helvetica-quality). The trade-off:
//   + No font binary management, no edge-runtime fs workarounds
//   + ~30KB less cold start
//   + Output is consistent across all users
//   - The brand font's character is lost (Frauences/Inter is part of identity)
//
// Fonts can be re-introduced later if branding consistency outweighs simplicity.

import satori from 'satori'
import { Resvg } from '@resvg/resvg-js'
import { PDFDocument } from 'pdf-lib'

// Image dimensions (logical pixels in Satori).
const IMG_W = 1100
const IMG_H = 450

// A4 landscape in points (PDF coordinate system, 1pt = 1/72 inch).
const PAGE_W_PT = 842 // 297mm
const PAGE_H_PT = 595 // 210mm

const SCALE = 2 // 2x render for crisp text in the PDF

export async function buildComprovativoPdf(jsx) {
  // 1. JSX → SVG (no fonts array → Satori uses its default font)
  const svg = await satori(jsx, {
    width: IMG_W,
    height: IMG_H,
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
  const aspect = IMG_W / IMG_H // 2.44
  const pageAspect = PAGE_W_PT / PAGE_H_PT // 1.41
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
