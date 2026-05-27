'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Save, X } from 'lucide-react'
import MarkdownEditor from '@/components/admin/MarkdownEditor'
import ImageUpload from '@/components/admin/ImageUpload'
import ReferenceEditor from '@/components/admin/ReferenceEditor'
import { createArticle, updateArticle } from '@/lib/actions/content'
import { Marked } from 'marked'
import DOMPurify from 'isomorphic-dompurify'

const marked = new Marked()

const CATEGORIES = [
  { value: 'profissionais', label: 'Para Profissionais' },
  { value: 'voce-sabia', label: 'Você Sabia?' },
  { value: 'conheca-medicamento', label: 'Conheça o Medicamento' },
  { value: 'curiosidades', label: 'Curiosidades' },
  { value: 'saude', label: 'Saúde e Informação' },
]

function generateSlug(title) {
  return title
    .toLowerCase()
    .replace(/[àáâäãå]/g, 'a').replace(/[èéêë]/g, 'e')
    .replace(/[ìíîï]/g, 'i').replace(/[òóôöõ]/g, 'o')
    .replace(/[ùúûü]/g, 'u').replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

export default function ArticleForm({ mode = 'create', initialData = null, lang = 'pt' }) {
  const router = useRouter()
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [showPreview, setShowPreview] = useState(false)
  const [previewHtml, setPreviewHtml] = useState('')

  const [title, setTitle] = useState(initialData?.title || '')
  const [slug, setSlug] = useState(initialData?.slug || '')
  const [slugEdited, setSlugEdited] = useState(!!initialData?.slug)
  const [category, setCategory] = useState(initialData?.category || '')
  const [status, setStatus] = useState(initialData?.status || 'draft')
  const [featured, setFeatured] = useState(initialData?.featured || false)
  const [excerpt, setExcerpt] = useState(initialData?.excerpt || '')
  const [metaDescription, setMetaDescription] = useState(initialData?.meta_description || '')
  const [content, setContent] = useState(initialData?.content || '')
  const [authorName, setAuthorName] = useState(initialData?.author_name || '')
  const [authorRole, setAuthorRole] = useState(initialData?.author_role || '')
  const [authorBio, setAuthorBio] = useState(initialData?.author_bio || '')
  const [authorAvatar, setAuthorAvatar] = useState(initialData?.author_avatar || '')
  const [authorAvatarBg, setAuthorAvatarBg] = useState(initialData?.author_avatar_bg || '#00493a')
  const [imageUrl, setImageUrl] = useState(initialData?.image_url || '')
  const [references, setReferences] = useState(initialData?.references_arr || [])
  const [publishedDate, setPublishedDate] = useState(initialData?.published_date || '')
  const [readTime, setReadTime] = useState(initialData?.read_time || '')

  const handleTitleChange = useCallback((value) => {
    setTitle(value)
    if (!slugEdited) {
      setSlug(generateSlug(value))
    }
  }, [slugEdited])

  const handleSlugChange = useCallback((value) => {
    setSlug(value)
    setSlugEdited(true)
  }, [])

  const handlePreview = useCallback(async () => {
    const categoryLabel = CATEGORIES.find(c => c.value === category)?.label || category
    const dateStr = publishedDate ? new Date(publishedDate + 'T00:00:00').toLocaleDateString('pt-PT', { year: 'numeric', month: 'long', day: 'numeric' }) : ''
    const readTimeStr = readTime ? `${readTime} min de leitura` : ''

    let bodyHtml = ''
    if (content) {
      const rawHtml = await marked.parse(content)
      bodyHtml = DOMPurify.sanitize(rawHtml, {
        ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'blockquote', 'code', 'pre', 'a', 'img', 'table', 'thead', 'tbody', 'tr', 'th', 'td'],
        ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'target'],
      })
    }

    const html = `
      <div class="preview-hero">
        ${categoryLabel ? `<span class="preview-category-badge">${categoryLabel}</span>` : ''}
        <h1 class="preview-hero-title">${title || 'Sem título'}</h1>
        ${imageUrl ? `<img src="${imageUrl}" alt="${title}" class="preview-featured-image" onerror="this.style.display='none'">` : ''}
        ${authorName || dateStr || readTimeStr ? `
          <div class="preview-meta-bar">
            <div class="preview-author">
              <div class="preview-author-avatar" ${authorAvatarBg ? `style="background:${authorAvatarBg}"` : ''}>${authorAvatar || (authorName ? authorName.charAt(0).toUpperCase() : '?')}</div>
              <div>
                ${authorName ? `<div class="preview-author-name">${authorName}</div>` : ''}
                ${authorRole ? `<div class="preview-author-role">${authorRole}</div>` : ''}
              </div>
            </div>
            <div class="preview-meta-info">
              ${dateStr ? `<span>${dateStr}</span>` : ''}
              ${readTimeStr ? `<span>${readTimeStr}</span>` : ''}
            </div>
          </div>
        ` : ''}
      </div>
      ${excerpt ? `<div class="preview-excerpt">${excerpt}</div>` : ''}
      <div class="preview-article-body">${bodyHtml}</div>
    `
    setPreviewHtml(html)
    setShowPreview(true)
    document.body.style.overflow = 'hidden'
  }, [title, category, publishedDate, readTime, content, imageUrl, authorName, authorRole, authorAvatar, authorAvatarBg, excerpt])

  const closePreview = useCallback(() => {
    setShowPreview(false)
    setPreviewHtml('')
    document.body.style.overflow = ''
  }, [])

  const handleSubmit = useCallback(async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)

    const categoryLabel = CATEGORIES.find(c => c.value === category)?.label || category

    const formData = {
      title, slug, category, category_label: categoryLabel, status, featured,
      excerpt, meta_description: metaDescription, content,
      author_name: authorName, author_role: authorRole, author_bio: authorBio,
      author_avatar: authorAvatar, author_avatar_bg: authorAvatarBg,
      image_url: imageUrl, references, published_date: publishedDate || null,
      read_time: readTime,
    }

    try {
      let result
      if (mode === 'edit' && initialData?.id) {
        result = await updateArticle(initialData.id, formData)
      } else {
        result = await createArticle(formData)
      }

      if (result.success) {
        router.push(`/${lang}/admin/artigos`)
      } else {
        setError(result.error)
      }
    } catch {
      setError('Erro ao salvar artigo.')
    } finally {
      setSaving(false)
    }
  }, [title, slug, category, status, featured, excerpt, metaDescription, content,
    authorName, authorRole, authorBio, authorAvatar, authorAvatarBg, imageUrl, references, publishedDate, readTime,
    mode, initialData, router, lang])

  return (
    <>
    <form onSubmit={handleSubmit} className="admin-card admin-form">
      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label htmlFor="title">Título</label>
          <input id="title" type="text" value={title} onChange={(e) => handleTitleChange(e.target.value)}
            required className="admin-input" placeholder="Título do artigo" />
        </div>
        <div className="admin-form-group">
          <label htmlFor="slug">Slug</label>
          <input id="slug" type="text" value={slug} onChange={(e) => handleSlugChange(e.target.value)}
            required className="admin-input" placeholder="nome-do-artigo" />
        </div>
        <div className="admin-form-group">
          <label htmlFor="category">Categoria</label>
          <select id="category" value={category} onChange={(e) => setCategory(e.target.value)}
            required className="admin-input">
            <option value="">Selecione...</option>
            {CATEGORIES.map(c => <option key={c.value} value={c.value}>{c.label}</option>)}
          </select>
        </div>
        <div className="admin-form-group">
          <label htmlFor="status">Status</label>
          <select id="status" value={status} onChange={(e) => setStatus(e.target.value)}
            required className="admin-input">
            <option value="draft">Rascunho</option>
            <option value="published">Publicado</option>
          </select>
        </div>
      </div>

      <div className="admin-form-group">
        <label className="admin-checkbox-label">
          <input type="checkbox" checked={featured} onChange={(e) => setFeatured(e.target.checked)} />
          <span>Destacar na página principal</span>
        </label>
      </div>

      <div className="admin-form-group">
        <label htmlFor="excerpt">Resumo/Excerto</label>
        <textarea id="excerpt" value={excerpt} onChange={(e) => setExcerpt(e.target.value)}
          className="admin-textarea" style={{ minHeight: 100 }} placeholder="Breve resumo do artigo" />
      </div>

      <div className="admin-form-group">
        <label htmlFor="meta_description">Meta Descrição (SEO)</label>
        <textarea id="meta_description" value={metaDescription} onChange={(e) => setMetaDescription(e.target.value)}
          className="admin-textarea" style={{ minHeight: 60 }} maxLength={160}
          placeholder="Descrição para motores de busca (máx. 160 caracteres)" />
        <small style={{ color: 'var(--admin-text-muted)', fontSize: 12 }}>Aparece nos resultados do Google. Recomendado: 120-160 caracteres.</small>
      </div>

      <div className="admin-form-group">
        <label>Conteúdo (Markdown)</label>
        <MarkdownEditor value={content} onChange={setContent} onPreview={handlePreview} />
      </div>

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label htmlFor="author_name">Autor (Nome)</label>
          <input id="author_name" type="text" value={authorName} onChange={(e) => setAuthorName(e.target.value)}
            className="admin-input" placeholder="Nome do autor" />
        </div>
        <div className="admin-form-group">
          <label htmlFor="author_role">Autor (Cargo)</label>
          <input id="author_role" type="text" value={authorRole} onChange={(e) => setAuthorRole(e.target.value)}
            className="admin-input" placeholder="Cargo do autor" />
        </div>
      </div>

      <div className="admin-form-group">
        <label htmlFor="author_bio">Autor (Biografia)</label>
        <textarea id="author_bio" value={authorBio} onChange={(e) => setAuthorBio(e.target.value)}
          className="admin-textarea" style={{ minHeight: 60 }} placeholder="Breve biografia do autor" />
      </div>

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label htmlFor="author_avatar">Avatar (Iniciais)</label>
          <input id="author_avatar" type="text" value={authorAvatar} onChange={(e) => setAuthorAvatar(e.target.value)}
            className="admin-input" placeholder="ML" maxLength={4} />
        </div>
        <div className="admin-form-group">
          <label htmlFor="author_avatar_bg">Cor do Avatar</label>
          <input id="author_avatar_bg" type="text" value={authorAvatarBg} onChange={(e) => setAuthorAvatarBg(e.target.value)}
            className="admin-input" placeholder="#00493a" />
        </div>
      </div>

      <ImageUpload value={imageUrl} onChange={setImageUrl} bucket="article-images" folder="articles" label="Imagem" />

      <ReferenceEditor references={references} onChange={setReferences} />

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label htmlFor="published_date">Data de Publicação</label>
          <input id="published_date" type="date" value={publishedDate} onChange={(e) => setPublishedDate(e.target.value)}
            className="admin-input" />
        </div>
        <div className="admin-form-group">
          <label htmlFor="read_time">Tempo de Leitura (min)</label>
          <input id="read_time" type="number" value={readTime} onChange={(e) => setReadTime(e.target.value)}
            className="admin-input" placeholder="5" />
        </div>
      </div>

      {error && (
        <div className="admin-error-message" style={{ display: 'block' }}>{error}</div>
      )}

      <div className="admin-form-actions">
        <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
          <Save size={16} />
          {saving ? 'A guardar...' : mode === 'edit' ? 'Atualizar Artigo' : 'Salvar Artigo'}
        </button>
        <a href={`/${lang}/admin/artigos`} className="admin-btn admin-btn-secondary">
          <X size={16} /> Cancelar
        </a>
      </div>
    </form>

    {/* Preview Overlay */}
    {showPreview && (
      <div
        className="admin-editor-overlay active"
        onClick={(e) => { if (e.target === e.currentTarget) closePreview() }}
        onKeyDown={(e) => { if (e.key === 'Escape') closePreview() }}
      >
        <div className="admin-preview-content">
          <div className="admin-preview-header">
            <span className="admin-preview-title">Pré-visualização</span>
            <button type="button" className="admin-editor-close" onClick={closePreview} aria-label="Fechar preview">
              <X size={20} />
            </button>
          </div>
          <div className="admin-preview-body" dangerouslySetInnerHTML={{ __html: previewHtml }} />
        </div>
      </div>
    )}
    </>
  )
}
