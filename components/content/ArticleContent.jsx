'use client'

import { useEffect, useRef } from 'react'
import { marked } from 'marked'
import DOMPurify from 'isomorphic-dompurify'

// Configure DOMPurify to restrict img src
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

export default function ArticleContent({ content }) {
  const containerRef = useRef(null)

  useEffect(() => {
    if (!containerRef.current || !content) return

    const html = marked.parse(content)
    const clean = DOMPurify.sanitize(html, {
      ADD_TAGS: ['img'],
      ADD_ATTR: ['src', 'alt', 'loading'],
    })
    containerRef.current.innerHTML = clean
  }, [content])

  return (
    <div
      ref={containerRef}
      className="max-w-none"
    />
  )
}
