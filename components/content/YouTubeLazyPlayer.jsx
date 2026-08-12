'use client'

import { useState } from 'react'
import { Play } from 'lucide-react'

/**
 * YouTubeLazyPlayer — thumbnail com botão play; ao clicar, carrega o iframe
 * com autoplay. Evita carregar o player embutido na listagem/página.
 * Padrão do plano de entrevistas (Task 3: módulo de vídeo, sem inline scripts).
 */
export default function YouTubeLazyPlayer({ videoId, thumbnailUrl, title = '' }) {
  const [playing, setPlaying] = useState(false)

  const thumb = thumbnailUrl || `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`

  if (playing) {
    return (
      <div className="video-wrapper">
        <iframe
          src={`https://www.youtube.com/embed/${videoId}?autoplay=1`}
          title={title || 'Vídeo da entrevista'}
          width="100%"
          height="100%"
          style={{ border: 0, position: 'absolute', inset: 0 }}
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
          referrerPolicy="strict-origin-when-cross-origin"
        />
      </div>
    )
  }

  return (
    <div className="video-wrapper" style={{ cursor: 'pointer' }} onClick={() => setPlaying(true)}>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img src={thumb} alt={title || 'Miniatura do vídeo'} className="video-thumb" loading="lazy" />
      <span className="video-play-btn" aria-label={title ? `Reproduzir: ${title}` : 'Reproduzir vídeo'}>
        <span className="video-play-circle">
          <Play size={26} fill="currentColor" aria-hidden="true" />
        </span>
      </span>
    </div>
  )
}
