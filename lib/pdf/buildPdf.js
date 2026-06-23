// PDF generation pipeline (server-side, Edge compatible):
//
//   <ComprovativoSatori /> JSX
//     → satori (JSX → SVG, with Noto Sans/Serif/Mono loaded via loadFont)
//     → resvg-js (SVG → PNG buffer, 2x density for crisp output)
//     → pdf-lib (PNG → single-page A4 landscape PDF, drawn to fill page)
//
// Fonts: we use Noto Sans / Noto Serif / Noto Sans Mono via @fontsource
// packages — bundled in node_modules, no runtime fetch, no font binary to
// ship through public/. ComprovativoSatori.jsx uses generic family names
// ('sans-serif', 'serif', 'monospace') which we map to the Noto fonts
// below. Trade-off vs Inter/Fraunces: lose brand typography, gain zero
// runtime deps and consistent rendering.

import satori from 'satori'
import { Resvg } from '@resvg/resvg-js'
import { PDFDocument } from 'pdf-lib'

import notoSansRegular from '@fontsource/noto-sans/files/noto-sans-latin-400-normal.woff'
import notoSansBold from '@fontsource/noto-sans/files/noto-sans-latin-700-normal.woff'
import notoSansSemiBold from '@fontsource/noto-sans/files/noto-sans-latin-600-normal.woff'
import notoSansMedium from '@fontsource/noto-sans/files/noto-sans-latin-500-normal.woff'
import notoSerifRegular from '@fontsource/noto-serif/files/noto-serif-latin-400-normal.woff'
import notoSerifBold from '@fontsource/noto-serif/files/noto-serif-latin-700-normal.woff'
import notoSerifSemiBold from '@fontsource/noto-serif/files/noto-serif-latin-600-normal.woff'
import notoMonoRegular from '@fontsource/noto-sans-mono/files/noto-sans-mono-latin-400-normal.woff'
import notoMonoBold from '@fontsource/noto-sans-mono/files/noto-sans-mono-latin-700-normal.woff'

// Image dimensions (logical pixels in Satori). 1300x920 = 1.413:1 —
// matches A4 landscape (842:595pt = 1.414:1) so the image fills the
// whole page without letterboxing.
const IMG_W = 1300
const IMG_H = 920

// A4 landscape in points (PDF coordinate system, 1pt = 1/72 inch).
const PAGE_W_PT = 842 // 297mm
const PAGE_H_PT = 595 // 210mm

const SCALE = 2 // 2x render for crisp text in the PDF

let fontsRegistered = false

// Convert the woff ArrayBuffers returned by @fontsource into the
// shape satori.loadFont expects ({ name, data, weight, style }).
async function registerFonts() {
  if (fontsRegistered) return
  await satori.loadFont({ name: 'sans-serif', data: notoSansRegular, weight: 400, style: 'normal' })
  await satori.loadFont({ name: 'sans-serif', data: notoSansMedium, weight: 500, style: 'normal' })
  await satori.loadFont({ name: 'sans-serif', data: notoSansSemiBold, weight: 600, style: 'normal' })
  await satori.loadFont({ name: 'sans-serif', data: notoSansBold, weight: 700, style: 'normal' })
  await satori.loadFont({ name: 'serif', data: notoSerifRegular, weight: 400, style: 'normal' })
  await satori.loadFont({ name: 'serif', data: notoSerifSemiBold, weight: 600, style: 'normal' })
  await satori.loadFont({ name: 'serif', data: notoSerifBold, weight: 700, style: 'normal' })
  await satori.loadFont({ name: 'monospace', data: notoMonoRegular, weight: 400, style: 'normal' })
  await satori.loadFont({ name: 'monospace', data: notoMonoBold, weight: 700, style: 'normal' })
  fontsRegistered = true
}

export async function buildComprovativoPdf(jsx) {
  await registerFonts()

  // 1. JSX → SVG
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
