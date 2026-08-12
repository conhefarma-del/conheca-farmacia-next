'use client'

import { useState } from 'react'
import { Mic } from 'lucide-react'

/**
 * InterviewAudioPlayer — player de áudio da entrevista (quando não há vídeo).
 * O `<audio>` só é renderizado quando o utilizador clica em "Ouvir áudio"
 * (preload none por defeito → não carrega o ficheiro na abertura da página).
 * O CSP permite media-src 'self' blob: https://*.supabase.co.
 */
export default function InterviewAudioPlayer({ audioUrl, title = '' }) {
  const [show, setShow] = useState(false)

  if (!audioUrl) return null

  return (
    <div className="interview-audio-box">
      <div className="interview-audio-head">
        <span className="interview-audio-icon" aria-hidden="true">
          <Mic size={18} />
        </span>
        <div className="interview-audio-info">
          <span className="interview-audio-label">Áudio da entrevista</span>
          <span className="interview-audio-sub">
            {show ? 'A ouvir...' : 'Ouça a conversa enquanto lê'}
          </span>
        </div>
        {!show && (
          <button type="button" className="interview-audio-btn" onClick={() => setShow(true)}>
            Ouvir áudio
          </button>
        )}
      </div>
      {show && (
        <audio
          controls
          preload="none"
          src={audioUrl}
          style={{ width: '100%', marginTop: 12 }}
          aria-label={title ? `Áudio: ${title}` : 'Áudio da entrevista'}
        />
      )}
    </div>
  )
}
