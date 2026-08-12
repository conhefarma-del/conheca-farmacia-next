'use client'

import { useState } from 'react'
import { Mic } from 'lucide-react'
import { parseAudioEmbed } from '@/lib/utils/audio-embed'

const LABELS = {
  spotify: 'Áudio no Spotify',
  soundcloud: 'Áudio no SoundCloud',
  'youtube-music': 'Áudio no YouTube Music',
}

/**
 * InterviewAudioPlayer — áudio da entrevista (quando não há vídeo).
 * - URL de Spotify/SoundCloud/YouTube Music → embed iframe lazy (o CSP
 *   permite frame-src desses domínios).
 * - Outro URL → <audio> nativo (preload none → não carrega na abertura).
 * O conteúdo só é montado quando o utilizador clica em "Ouvir áudio".
 */
export default function InterviewAudioPlayer({ audioUrl, title = '' }) {
  const [show, setShow] = useState(false)

  if (!audioUrl) return null

  const embed = parseAudioEmbed(audioUrl)
  const label = embed ? LABELS[embed.type] || 'Áudio da entrevista' : 'Áudio da entrevista'

  return (
    <div className="interview-audio-box">
      <div className="interview-audio-head">
        <span className="interview-audio-icon" aria-hidden="true">
          <Mic size={18} />
        </span>
        <div className="interview-audio-info">
          <span className="interview-audio-label">{label}</span>
          <span className="interview-audio-sub">
            {show ? 'A ouvir...' : 'Ouça a conversa enquanto lê'}
          </span>
        </div>
        {!show && (
          <button type="button" className="interview-audio-btn" onClick={() => setShow(true)}>
            {embed ? `Ouvir no ${embed.type === 'spotify' ? 'Spotify' : embed.type === 'soundcloud' ? 'SoundCloud' : 'YouTube Music'}` : 'Ouvir áudio'}
          </button>
        )}
      </div>
      {show && embed && (
        <iframe
          src={embed.embed}
          title={title ? `${label}: ${title}` : label}
          width="100%"
          height={embed.height}
          style={{ border: 0, borderRadius: 12, marginTop: 12 }}
          loading="lazy"
          allow="encrypted-media; autoplay; clipboard-write"
          allowFullScreen
        />
      )}
      {show && !embed && (
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
