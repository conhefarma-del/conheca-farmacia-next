'use client'

import { useState, useRef, useCallback, useEffect } from 'react'
import { Maximize2, Eye, X } from 'lucide-react'
import { Marked } from 'marked'
import DOMPurify from 'isomorphic-dompurify'

const marked = new Marked()

/**
 * MarkdownEditor — Client Component
 *
 * Fullscreen overlay editor com preview (fiel ao MPA).
 * SEC-XSS-01/05: marked + DOMPurify para preview.
 *
 * Props:
 *   - value: string (markdown content)
 *   - onChange: (value: string) => void
 *   - placeholder: string
 */

export default function MarkdownEditor({ value = '', onChange, placeholder = 'Escreva o conteúdo em Markdown...', onPreview }) {
  const [isEditorOpen, setIsEditorOpen] = useState(false)
  const [isPreviewOpen, setIsPreviewOpen] = useState(false)
  const [previewHtml, setPreviewHtml] = useState('')
  const overlayRef = useRef(null)
  const textareaRef = useRef(null)

  // Abrir editor fullscreen
  const openEditor = useCallback(() => {
    setIsEditorOpen(true)
    document.body.style.overflow = 'hidden'
  }, [])

  // Fechar editor fullscreen
  const closeEditor = useCallback(() => {
    setIsEditorOpen(false)
    document.body.style.overflow = ''
  }, [])

  // Preview com marked + DOMPurify (SEC-XSS-01/05)
  // Se onPreview for fornecido, delega para o componente pai (preview completo)
  const openPreview = useCallback(async () => {
    if (onPreview) {
      onPreview()
      return
    }

    if (!value) {
      setPreviewHtml('<p style="color: #999;">Sem conteúdo para pré-visualizar.</p>')
      setIsPreviewOpen(true)
      return
    }

    try {
      const rawHtml = await marked.parse(value)
      const cleanHtml = DOMPurify.sanitize(rawHtml, {
        ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'b', 'i', 'u', 'a', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
          'ul', 'ol', 'li', 'blockquote', 'code', 'pre', 'img', 'table', 'thead', 'tbody', 'tr', 'th', 'td',
          'hr', 'span', 'div'],
        ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'class', 'target', 'rel', 'width', 'height'],
        ALLOWED_URI_REGEXP: /^(?:(?:https?|ftp):\/\/|data:image\/|\/)/i,
      })
      setPreviewHtml(cleanHtml)
      setIsPreviewOpen(true)
    } catch {
      setPreviewHtml('<p style="color: #dc2626;">Erro ao renderizar Markdown.</p>')
      setIsPreviewOpen(true)
    }
  }, [value, onPreview])

  // Fechar overlays com Escape
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        if (isEditorOpen) closeEditor()
        if (isPreviewOpen) setIsPreviewOpen(false)
      }
    }
    document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [isEditorOpen, isPreviewOpen, closeEditor])

  return (
    <>
      <div style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
        <button type="button" className="admin-textarea-expand" onClick={openEditor} title="Expandir editor">
          <Maximize2 size={16} />
          Expandir
        </button>
        <button type="button" className="admin-textarea-expand" onClick={openPreview} title="Pré-visualizar">
          <Eye size={16} />
          Pré-visualizar
        </button>
      </div>

      <textarea
        value={value}
        onChange={(e) => onChange?.(e.target.value)}
        className="admin-textarea"
        placeholder={placeholder}
        style={{ minHeight: 200 }}
      />

      {/* Editor Overlay — fullscreen */}
      {isEditorOpen && (
        <div
          className="admin-editor-overlay active"
          ref={overlayRef}
          onClick={(e) => { if (e.target === overlayRef.current) closeEditor() }}
        >
          <div className="admin-editor-overlay-content">
            <div className="admin-editor-overlay-header">
              <div className="admin-editor-overlay-title">
                <Maximize2 size={20} />
                Conteúdo (Markdown)
              </div>
              <button type="button" className="admin-editor-close" onClick={closeEditor}>
                <X size={20} />
                Fechar
              </button>
            </div>
            <textarea
              ref={textareaRef}
              value={value}
              onChange={(e) => onChange?.(e.target.value)}
              className="admin-editor-overlay-textarea"
              placeholder={placeholder}
              autoFocus
            />
            <div className="admin-editor-overlay-footer">
              <span className="admin-editor-overlay-hint">
                Pressione <kbd style={{ padding: '2px 6px', background: '#e5e7eb', borderRadius: 4, fontSize: 12 }}>Esc</kbd> para fechar
              </span>
            </div>
          </div>
        </div>
      )}

      {/* Preview Overlay — fullscreen */}
      {isPreviewOpen && (
        <div
          className="admin-preview-overlay"
          style={{
            position: 'fixed', inset: 0, zIndex: 1000, display: 'flex',
            background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(4px)',
            alignItems: 'center', justifyContent: 'center', padding: 24,
          }}
          onClick={(e) => { if (e.target.currentTarget === e.target) setIsPreviewOpen(false) }}
        >
          <div
            className="admin-preview-content"
            style={{
              background: 'var(--admin-card-bg, white)', borderRadius: 16, padding: 32,
              maxWidth: 800, width: '100%', maxHeight: '80vh', overflow: 'auto',
              boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
              <h3 style={{ margin: 0, fontSize: 18, fontWeight: 600 }}>Pré-visualização</h3>
              <button type="button" className="admin-editor-close" onClick={() => setIsPreviewOpen(false)}>
                <X size={20} />
              </button>
            </div>
            <div
              className="admin-preview-body preview-article-body"
              style={{ lineHeight: 1.8, fontSize: 15 }}
              dangerouslySetInnerHTML={{ __html: previewHtml }}
            />
          </div>
        </div>
      )}
    </>
  )
}
