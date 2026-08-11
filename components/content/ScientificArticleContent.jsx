'use client'

import { useEffect, useRef } from 'react'
import { marked } from 'marked'
import DOMPurify from 'isomorphic-dompurify'

// Slugify para ids de âncora (h2/h3) — usado pelo TOC do sidebar
function slugifyHeading(text) {
  return String(text)
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

// Renderer personalizado: h2/h3 ganham id (âncoras do TOC)
const renderer = {
  heading({ tokens, depth }) {
    const text = tokens.map((tk) => tk.text || '').join('')
    const id = slugifyHeading(text)
    const level = depth
    return `<h${level} id="${id}">${text}</h${level}>`
  },
}
marked.use({ renderer })

// DOMPurify: bloquear javascript:/data: URLs e obrigar target=_blank em links
DOMPurify.addHook('afterSanitizeAttributes', (node) => {
  if (node.tagName === 'IMG') {
    node.setAttribute('loading', 'lazy')
    const src = node.getAttribute('src') || ''
    if (
      !src.startsWith('https://tbqsazriorqzexjwhekw.supabase.co') &&
      !src.startsWith('/') &&
      !src.startsWith('./')
    ) {
      node.remove()
    }
  }
  if (node.tagName === 'A') {
    const href = node.getAttribute('href') || ''
    if (/^(javascript|data|vbscript):/i.test(href)) {
      node.remove()
    }
    node.setAttribute('target', '_blank')
    node.setAttribute('rel', 'noopener noreferrer')
  }
})

/**
 * ScientificArticleContent — corpo do artigo científico em markdown,
 * com corpo serif (.sci-article-body) e âncoras nos títulos para o TOC.
 */
export default function ScientificArticleContent({ content }) {
  const containerRef = useRef(null)

  useEffect(() => {
    if (!containerRef.current || !content) return
    const html = marked.parse(content)
    const clean = DOMPurify.sanitize(html, {
      ADD_TAGS: ['img'],
      ADD_ATTR: ['src', 'alt', 'loading', 'id'],
    })
    containerRef.current.innerHTML = clean
  }, [content])

  return <div ref={containerRef} className="sci-article-body max-w-none" />
}
