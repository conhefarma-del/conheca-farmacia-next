import DOMPurify from 'isomorphic-dompurify'

export function sanitizeHtml(dirty) {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: [
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'a', 'img', 'ul', 'ol', 'li',
      'blockquote', 'pre', 'code', 'strong', 'em', 'b', 'i', 'u', 'br', 'hr',
      'table', 'thead', 'tbody', 'tr', 'th', 'td', 'span', 'div', 'mark',
    ],
    ALLOWED_ATTR: ['href', 'src', 'alt', 'class', 'id', 'target', 'rel', 'title', 'width', 'height'],
    ALLOWED_URI_REGEXP: /^(?:(?:https?|ftp):\/\/|data:image\/|\/)/i,
  })
}
