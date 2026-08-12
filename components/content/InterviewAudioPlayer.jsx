'use client'

import { useState } from 'react'
import { Mic } from 'lucide-react'

/**
 * Converte um link do Spotify (track/album/playlist/episode/show) no URL de
 * embed correspondente. Devolve null se não for um link do Spotify.
 */
function parseSpotifyUrl(url) {
  if (!url) return null
  const m = String(url).match(/open\.spotify\.com\/(track|album|playlist|episode|show)\/([A-Za-z0-9]+)/)
  if (!m) return null
  return {
    kind: m[1],
    id: m[2],
    embed: `https://open.spotify.com/embed/${m[1]}/${m[2]}`,
  }
}

/**
 * InterviewAudioPlayer — áudio da entrevista (quando não há vídeo).
 * - URL do Spotify → embed iframe lazy (o Spotify não expõe ficheiros de
 *   áudio diretos; o CSP permite frame-src open.spotify.com).
 * - Outro URL → <audio> nativo (preload none → não carrega na abertura).
 * O conteúdo só é montado quando o utilizador clica em "Ouvir áudio".
 */
export default function InterviewAudioPlayer({ audioUrl, title = '' }) {
  const [show, setShow] = useState(false)

  if (!audioUrl) return null

  const spotify = parseSpotifyUrl(audioUrl)
  const label = spotify ? 'Áudio no Spotify' : 'Áudio da entrevista'

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
            {spotify ? 'Ouvir no Spotify' : 'Ouvir áudio'}
          </button>
        )}
      </div>
      {show && spotify && (
        <iframe
          src={spotify.embed}
          title={title ? `Spotify: ${title}` : 'Áudio da entrevista no Spotify'}
          width="100%"
          height={spotify.kind === 'track' ? 152 : 352}
          style={{ border: 0, borderRadius: 12, marginTop: 12 }}
          loading="lazy"
          allow="encrypted-media; autoplay; clipboard-write"
          allowFullScreen
        />
      )}
      {show && !spotify && (
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
