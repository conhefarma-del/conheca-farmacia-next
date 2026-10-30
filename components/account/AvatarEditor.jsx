'use client'

import { useEffect, useRef, useState } from 'react'

const LADO = 256

/**
 * Recorte quadrado da fotografia, antes de subir.
 *
 * O que sai daqui é sempre um JPEG de 256×256: o formato e a dimensão do
 * ficheiro original deixam de importar. Sem isto, uma foto de telemóvel com
 * 12 megapixels ia inteira para o Storage (e a barra de progresso não
 * acabava) e o avatar aparecia cortado a meio.
 *
 * Arrastar move a imagem; o cursor controla o zoom. O recorte é feito no
 * `<canvas>` — o servidor recebe um blob já reduzido e não tem de validar
 * dimensões.
 */
export default function AvatarEditor({
  file,
  title,
  hint,
  zoomLabel,
  applyLabel,
  cancelLabel,
  busy = false,
  onCancel,
  onApply,
}) {
  const canvasRef = useRef(null)
  const imgRef = useRef(null)
  const arrasto = useRef(null)
  const [zoom, setZoom] = useState(1)
  const [deslocamento, setDeslocamento] = useState({ x: 0, y: 0 })
  const [pronta, setPronta] = useState(false)

  useEffect(() => {
    const url = URL.createObjectURL(file)
    const img = new Image()
    img.onload = () => {
      imgRef.current = img
      setPronta(true)
    }
    img.src = url
    return () => URL.revokeObjectURL(url)
  }, [file])

  /** Quanto é que a imagem ocupa no canvas, em píxeis, para o zoom dado. */
  function dimensoes(z) {
    const img = imgRef.current
    if (!img) return { largura: LADO, altura: LADO }
    const base = Math.max(LADO / img.width, LADO / img.height)
    return { largura: img.width * base * z, altura: img.height * base * z }
  }

  /**
   * Nunca deixa aparecer fundo: o deslocamento máximo é a sobra da imagem
   * para cada lado. Sem isto, arrastar demasiado mostrava um canto vazio.
   */
  function limitar(x, y, z) {
    const { largura, altura } = dimensoes(z)
    const sobraX = Math.max(0, (largura - LADO) / 2)
    const sobraY = Math.max(0, (altura - LADO) / 2)
    return {
      x: Math.min(sobraX, Math.max(-sobraX, x)),
      y: Math.min(sobraY, Math.max(-sobraY, y)),
    }
  }

  useEffect(() => {
    const canvas = canvasRef.current
    const img = imgRef.current
    if (!canvas || !img || !pronta) return
    const ctx = canvas.getContext('2d')
    const { largura, altura } = dimensoes(zoom)
    ctx.clearRect(0, 0, LADO, LADO)
    ctx.drawImage(
      img,
      LADO / 2 - largura / 2 + deslocamento.x,
      LADO / 2 - altura / 2 + deslocamento.y,
      largura,
      altura,
    )
    // `dimensoes` lê só refs e `zoom`; as dependências certas são estas.
  }, [zoom, deslocamento, pronta])

  function comecarArrasto(event) {
    event.currentTarget.setPointerCapture?.(event.pointerId)
    arrasto.current = {
      x: event.clientX,
      y: event.clientY,
      inicio: deslocamento,
    }
  }

  function arrastar(event) {
    if (!arrasto.current) return
    const dx = event.clientX - arrasto.current.x
    const dy = event.clientY - arrasto.current.y
    setDeslocamento(
      limitar(arrasto.current.inicio.x + dx, arrasto.current.inicio.y + dy, zoom),
    )
  }

  function terminarArrasto() {
    arrasto.current = null
  }

  function aplicar() {
    const canvas = canvasRef.current
    if (!canvas) return
    canvas.toBlob((blob) => {
      if (blob) onApply(blob)
    }, 'image/jpeg', 0.9)
  }

  return (
    <div className="conta-editor-scrim" role="presentation">
      <div className="conta-editor" role="dialog" aria-modal="true" aria-label={title}>
        <h2 className="conta-editor-title">{title}</h2>
        <p className="conta-editor-hint">{hint}</p>

        <canvas
          ref={canvasRef}
          width={LADO}
          height={LADO}
          className="conta-editor-canvas"
          onPointerDown={comecarArrasto}
          onPointerMove={arrastar}
          onPointerUp={terminarArrasto}
          onPointerCancel={terminarArrasto}
        />

        <label className="conta-editor-zoom">
          <span>{zoomLabel}</span>
          <input
            type="range"
            min="1"
            max="3"
            step="0.01"
            value={zoom}
            onChange={(event) => {
              const z = Number(event.target.value)
              setZoom(z)
              setDeslocamento((atual) => limitar(atual.x, atual.y, z))
            }}
          />
        </label>

        <div className="conta-editor-acts">
          <button type="button" className="conta-btn conta-btn--ghost" onClick={onCancel} disabled={busy}>
            {cancelLabel}
          </button>
          <button type="button" className="conta-btn conta-btn--primary" onClick={aplicar} disabled={busy || !pronta}>
            {applyLabel}
          </button>
        </div>
      </div>
    </div>
  )
}
