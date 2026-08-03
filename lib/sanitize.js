import sanitize from 'sanitize-html'

export function sanitizeHtml(dirty) {
  return sanitize(dirty, {
    allowedTags: [
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'p', 'a', 'img', 'ul', 'ol', 'li',
      'blockquote', 'pre', 'code', 'strong', 'em', 'b', 'i', 'u', 'br', 'hr',
      'table', 'thead', 'tbody', 'tr', 'th', 'td', 'span', 'div', 'mark',
    ],
    allowedAttributes: {
      '*': ['class', 'id', 'title', 'width', 'height'],
      a: ['href', 'target', 'rel'],
      img: ['src', 'alt', 'width', 'height'],
    },
    // SEC-UMN-03 (auditoria "O Sentinela" #5): só https/http são permitidos.
    // O esquema `data:` (ativo em TODAS as tags) foi removido — conteúdo
    // `data:text/html;base64,...` podia sobreviver à sanitização quando o
    // alvo é HTML gerado por IA (translation.js → OpenRouter) ou por admins.
    allowedSchemes: ['https', 'http'],
    allowedSchemesByTag: {
      img: ['https', 'http'],
    },
  })
}