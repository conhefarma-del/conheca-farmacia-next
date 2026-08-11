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

// Citações [n], [1,2] ou [1-3] no texto → links para #ref-n (referências vivas).
// Apenas nós de texto fora de <a>/<h1..h6> (não toca links nem títulos).
const CITE_RE = /\[(\d{1,2}(?:[,-]\s*\d{1,2})*)\]/g

function linkCitations(container) {
  const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT)
  const targets = []
  while (walker.nextNode()) {
    const node = walker.currentNode
    const parent = node.parentElement
    if (!parent || parent.closest('a, h1, h2, h3, h4, h5, h6, script, style')) continue
    CITE_RE.lastIndex = 0
    if (CITE_RE.test(node.nodeValue || '')) targets.push(node)
  }

  for (const node of targets) {
    const text = node.nodeValue || ''
    CITE_RE.lastIndex = 0
    const frag = document.createDocumentFragment()
    let last = 0
    let m
    while ((m = CITE_RE.exec(text)) !== null) {
      if (m.index > last) frag.appendChild(document.createTextNode(text.slice(last, m.index)))
      const first = m[1].replace(/\s/g, '').split(/[,-]/)[0]
      const a = document.createElement('a')
      a.href = `#ref-${first}`
      a.className = 'sci-cite'
      a.textContent = m[0]
      frag.appendChild(a)
      last = m.index + m[0].length
    }
    if (last < text.length) frag.appendChild(document.createTextNode(text.slice(last)))
    node.parentNode.replaceChild(frag, node)
  }
}

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
    // Referências vivas: [n] no corpo → link para a referência correspondente
    linkCitations(containerRef.current)
  }, [content])

  return <div ref={containerRef} className="sci-article-body max-w-none" />
}
