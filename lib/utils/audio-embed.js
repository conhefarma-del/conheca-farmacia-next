/**
 * audio-embed.js — converte URLs de áudio de serviços externos no respetivo
 * embed iframe. Usado pelo InterviewAudioPlayer (público) e pelo preview do
 * form admin (a mesma lógica em ambos, sem duplicação).
 *
 * Devolve null para URLs que não são de nenhum serviço suportado — nesses
 * casos o fallback é o <audio> nativo.
 */

/**
 * @param {string|undefined} url
 * @returns {{ type: 'spotify'|'soundcloud'|'youtube-music', embed: string, height: number } | null}
 */
export function parseAudioEmbed(url) {
  if (!url) return null
  const u = String(url).trim()

  // Spotify — track/album/playlist/episode/show
  const spotify = u.match(/open\.spotify\.com\/(track|album|playlist|episode|show)\/([A-Za-z0-9]+)/)
  if (spotify) {
    return {
      type: 'spotify',
      embed: `https://open.spotify.com/embed/${spotify[1]}/${spotify[2]}`,
      height: spotify[1] === 'track' ? 152 : 352,
    }
  }

  // SoundCloud — https://soundcloud.com/user/track (ou /sets/...)
  if (/^https?:\/\/(www\.)?soundcloud\.com\//i.test(u)) {
    return {
      type: 'soundcloud',
      embed:
        'https://w.soundcloud.com/player/?url=' +
        encodeURIComponent(u) +
        '&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true&visual=true',
      height: 450,
    }
  }

  // YouTube Music — music.youtube.com/watch?v=... ou /embed/... (o embed é o
  // player normal do YouTube)
  const ytMusic = u.match(/music\.youtube\.com\/(?:watch\?.*v=|embed\/)([A-Za-z0-9_-]{11})/)
  if (ytMusic) {
    return {
      type: 'youtube-music',
      embed: `https://www.youtube.com/embed/${ytMusic[1]}`,
      height: 352,
    }
  }

  return null
}
