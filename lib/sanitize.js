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
    allowedSchemes: ['https', 'http', 'ftp', 'data'],
    allowedSchemesByTag: {
      img: ['https', 'http', 'ftp', 'data'],
    },
  })
}