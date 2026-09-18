// PDF generation pipeline (server-side, Node runtime):
//
//   <ComprovativoSatori /> JSX
//     → satori 0.26 (JSX → SVG, fonts passed via the `fonts` option —
//       the old satori.loadFont() API no longer exists in 0.26 and was
//       the root cause of the retired empty/broken PDF output)
//     → resvg-js (SVG → PNG buffer, 2x density for crisp output)
//     → pdf-lib (PNG → single-page A4 landscape PDF, drawn to fill page)
//
// Fonts: brand fonts Inter (sans) + Fraunces (serif) via @fontsource —
// bundled in node_modules, no runtime fetch. ComprovativoSatori.jsx uses
// family names 'Inter' and 'Fraunces' directly.
//
// NOTE: satori does not render emoji glyphs — do not reintroduce emoji
// characters in ComprovativoSatori.jsx (they silently drop from the SVG).

import satori from 'satori'
import { Resvg } from '@resvg/resvg-js'
import { PDFDocument } from 'pdf-lib'

import interRegular from '@fontsource/inter/files/inter-latin-400-normal.woff'
import interMedium from '@fontsource/inter/files/inter-latin-500-normal.woff'
import interSemiBold from '@fontsource/inter/files/inter-latin-600-normal.woff'
import interBold from '@fontsource/inter/files/inter-latin-700-normal.woff'
import frauncesRegular from '@fontsource/fraunces/files/fraunces-latin-400-normal.woff'
import frauncesSemiBold from '@fontsource/fraunces/files/fraunces-latin-600-normal.woff'
import frauncesBold from '@fontsource/fraunces/files/fraunces-latin-700-normal.woff'

// Image dimensions (logical pixels in Satori). 1300x920 = 1.413:1 —
// matches A4 landscape (842:595pt = 1.414:1) so the image fills the
// whole page without letterboxing.
const IMG_W = 1300
const IMG_H = 920

// A4 landscape in points (PDF coordinate system, 1pt = 1/72 inch).
const PAGE_W_PT = 842 // 297mm
const PAGE_H_PT = 595 // 210mm

const SCALE = 2 // 2x render for crisp text in the PDF

const FONTS = [
  { name: 'Inter', data: interRegular, weight: 400, style: 'normal' },
  { name: 'Inter', data: interMedium, weight: 500, style: 'normal' },
  { name: 'Inter', data: interSemiBold, weight: 600, style: 'normal' },
  { name: 'Inter', data: interBold, weight: 700, style: 'normal' },
  { name: 'Fraunces', data: frauncesRegular, weight: 400, style: 'normal' },
  { name: 'Fraunces', data: frauncesSemiBold, weight: 600, style: 'normal' },
  { name: 'Fraunces', data: frauncesBold, weight: 700, style: 'normal' },
]

export async function buildComprovativoPdf(jsx) {
  // 1. JSX → SVG
  const svg = await satori(jsx, {
    width: IMG_W,
    height: IMG_H,
    fonts: FONTS,
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
