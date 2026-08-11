'use client'

import { useCallback, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Save, X, Plus, Trash2, Languages, Sparkles } from 'lucide-react'
import MarkdownEditor from '@/components/admin/MarkdownEditor'
import ReferenceEditor from '@/components/admin/ReferenceEditor'
import {
  createScientificArticle,
  updateScientificArticle,
  saveScientificTranslation,
  autoTranslateScientificArticle,
} from '@/lib/actions/scientific'

function generateSlug(title) {
  return title
    .toLowerCase()
    .replace(/[àáâäãå]/g, 'a').replace(/[èéêë]/g, 'e')
    .replace(/[ìíîï]/g, 'i').replace(/[òóôöõ]/g, 'o')
    .replace(/[ùúûü]/g, 'u').replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

function toDateInput(iso) {
  if (!iso) return ''
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return ''
  return d.toISOString().split('T')[0]
}

const EMPTY_AUTHOR = { name: '', institution: '', department: '', role: '', avatar: '', avatarBg: '#0a844f', corresponding: false }

/**
 * ScientificArticleForm — formulário dedicado dos artigos científicos.
 *
 * Campos académicos: abstract, keywords, DOI, autores dinâmicos (≤12),
 * referências, read_time. Inclui secção colapsável de tradução EN
 * (título/slug/abstract/keywords/conteúdo/referências) gravada via
 * saveScientificTranslation — apenas no modo edição.
 *
 * Props:
 *   - mode: 'create' | 'edit'
 *   - initialData: artigo normalizado (ou null em create)
 *   - categories: Array<{id, slug, name, color}> — da BD (geríveis)
 *   - translation: linha EN da scientific_article_translations | null
 *   - lang: 'pt' | 'en' (segmento da URL)
 */
export default function ScientificArticleForm({
  mode = 'create',
  initialData = null,
  categories = [],
  translation = null,
  lang = 'pt',
}) {
  const router = useRouter()
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [enSaving, setEnSaving] = useState(false)
  const [enError, setEnError] = useState('')
  const [enSuccess, setEnSuccess] = useState('')
  const [enAutoTranslating, setEnAutoTranslating] = useState(false)

  const [title, setTitle] = useState(initialData?.title || '')
  const [slug, setSlug] = useState(initialData?.slug || '')
  const [slugEdited, setSlugEdited] = useState(!!initialData?.slug)
  const [categoryId, setCategoryId] = useState(initialData?.categoryId || initialData?.category_id || '')
  const [status, setStatus] = useState(initialData?.status || 'draft')
  const [featured, setFeatured] = useState(Boolean(initialData?.featured))
  const [abstract, setAbstract] = useState(initialData?.abstract || '')
  const [keywords, setKeywords] = useState(
    Array.isArray(initialData?.keywords) ? initialData.keywords.join(', ') : ''
  )
  const [doi, setDoi] = useState(initialData?.doi || '')
  const [journal, setJournal] = useState(initialData?.journal || '')
  const [volume, setVolume] = useState(initialData?.volume || '')
  const [issue, setIssue] = useState(initialData?.issue || '')
  const [pages, setPages] = useState(initialData?.pages || '')
  const [license, setLicense] = useState(initialData?.license || '')
  const [licenseUrl, setLicenseUrl] = useState(initialData?.licenseUrl || initialData?.license_url || '')
  const [authors, setAuthors] = useState(() => {
    const arr = Array.isArray(initialData?.authors) ? initialData.authors : []
    return arr.length ? arr.map((a) => ({ ...EMPTY_AUTHOR, ...a })) : [{ ...EMPTY_AUTHOR }]
  })
  const [content, setContent] = useState(initialData?.content || '')
  const [references, setReferences] = useState(initialData?.references || [])
  const [publishedAt, setPublishedAt] = useState(toDateInput(initialData?.publishedAt || initialData?.published_at))
  const [readTime, setReadTime] = useState(initialData?.readTime || initialData?.read_time || '')

  // ---- Tradução EN ----
  const [enTitle, setEnTitle] = useState(translation?.title || '')
  const [enSlug, setEnSlug] = useState(translation?.slug || '')
  const [enAbstract, setEnAbstract] = useState(translation?.abstract || '')
  const [enKeywords, setEnKeywords] = useState(
    Array.isArray(translation?.keywords) ? translation.keywords.join(', ') : ''
  )
  const [enContent, setEnContent] = useState(translation?.content || '')
  const [enReferences, setEnReferences] = useState(translation?.references_arr || [])

  const handleTitleChange = useCallback((value) => {
    setTitle(value)
    if (!slugEdited) setSlug(generateSlug(value))
  }, [slugEdited])

  const handleSlugChange = useCallback((value) => {
    setSlug(value)
    setSlugEdited(true)
  }, [])

  const updateAuthor = useCallback((index, field, value) => {
    setAuthors((prev) => prev.map((a, i) => (i === index ? { ...a, [field]: value } : a)))
  }, [])

  const addAuthor = useCallback(() => {
    setAuthors((prev) => (prev.length < 12 ? [...prev, { ...EMPTY_AUTHOR }] : prev))
  }, [])

  const removeAuthor = useCallback((index) => {
    setAuthors((prev) => (prev.length > 1 ? prev.filter((_, i) => i !== index) : prev))
  }, [])

  const handleSubmit = useCallback(async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)

    const formData = {
      title, slug, category_id: categoryId, status, featured,
      abstract, keywords, doi,
      journal, volume, issue, pages, license, license_url: licenseUrl,
      authors: authors.filter((a) => a.name || a.institution),
      content, references,
      published_at: publishedAt ? new Date(publishedAt + 'T00:00:00').toISOString() : null,
      read_time: readTime,
    }

    try {
      let result
      if (mode === 'edit' && initialData?.id) {
        result = await updateScientificArticle(initialData.id, formData)
      } else {
        result = await createScientificArticle(formData)
      }

      if (result.success) {
        router.push(`/${lang}/admin/cientificos`)
      } else {
        setError(result.error)
      }
    } catch {
      setError('Erro ao salvar artigo científico.')
    } finally {
      setSaving(false)
    }
  }, [title, slug, categoryId, status, featured, abstract, keywords, doi, journal, volume, issue, pages, license, licenseUrl, authors, content, references, publishedAt, readTime, mode, initialData, router, lang])

  const handleSaveEn = useCallback(async (e) => {
    e.preventDefault()
    setEnError('')
    setEnSuccess('')
    setEnSaving(true)
    try {
      const result = await saveScientificTranslation(initialData.id, {
        title: enTitle,
        slug: enSlug,
        abstract: enAbstract,
        keywords: enKeywords,
        content: enContent,
        references: enReferences,
      })
      if (result.success) {
        setEnSuccess('Tradução EN guardada com sucesso.')
      } else {
        setEnError(result.error)
      }
    } catch {
      setEnError('Erro ao guardar tradução EN.')
    } finally {
      setEnSaving(false)
    }
  }, [initialData, enTitle, enSlug, enAbstract, enKeywords, enContent, enReferences])

  const handleAutoTranslate = useCallback(async () => {
    if (!initialData?.id || enAutoTranslating) return
    setEnError('')
    setEnSuccess('')
    setEnAutoTranslating(true)
    try {
      const result = await autoTranslateScientificArticle(initialData.id)
      if (result.success && result.translation) {
        const t = result.translation
        setEnTitle(t.title || '')
        setEnSlug(t.slug || '')
        setEnAbstract(t.abstract || '')
        setEnKeywords(Array.isArray(t.keywords) ? t.keywords.join(', ') : '')
        setEnContent(t.content || '')
        setEnReferences(Array.isArray(t.references_arr) ? t.references_arr : [])
        setEnSuccess('Tradução EN gerada com IA. Revê e guarda.')
        router.refresh()
      } else {
        setEnError(result.error || 'Erro ao gerar tradução.')
      }
    } catch {
      setEnError('Erro ao gerar tradução EN.')
    } finally {
      setEnAutoTranslating(false)
    }
  }, [initialData, enAutoTranslating, router])

  return (
    <>
      <form onSubmit={handleSubmit} className="admin-card admin-form">
        <div className="admin-form-grid">
          <div className="admin-form-group">
            <label htmlFor="sci-title">Título</label>
            <input id="sci-title" type="text" value={title} onChange={(e) => handleTitleChange(e.target.value)}
              required className="admin-input" placeholder="Título do artigo científico" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-slug">Slug</label>
            <input id="sci-slug" type="text" value={slug} onChange={(e) => handleSlugChange(e.target.value)}
              required className="admin-input" placeholder="nome-do-artigo" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-category">Categoria</label>
            <select id="sci-category" value={categoryId} onChange={(e) => setCategoryId(e.target.value)}
              required className="admin-input">
              <option value="">Selecione...</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-status">Status</label>
            <select id="sci-status" value={status} onChange={(e) => setStatus(e.target.value)}
              required className="admin-input">
              <option value="draft">Rascunho</option>
              <option value="published">Publicado</option>
            </select>
          </div>
        </div>

        <div className="admin-form-group">
          <label className="admin-checkbox-label" style={{ fontWeight: 500 }}>
            <input
              type="checkbox"
              checked={featured}
              onChange={(e) => setFeatured(e.target.checked)}
              style={{ marginRight: 8 }}
            />
            Destacar na página de Artigos Científicos
          </label>
        </div>

        <div className="admin-form-group">
          <label htmlFor="sci-abstract">Resumo (Abstract)</label>
          <textarea id="sci-abstract" value={abstract} onChange={(e) => setAbstract(e.target.value)}
            className="admin-textarea" style={{ minHeight: 120 }}
            placeholder="Resumo académico (150–300 palavras)" />
        </div>

        <div className="admin-form-grid">
          <div className="admin-form-group">
            <label htmlFor="sci-keywords">Keywords (separadas por vírgula)</label>
            <input id="sci-keywords" type="text" value={keywords}
              onChange={(e) => setKeywords(e.target.value)}
              className="admin-input" placeholder="farmacologia, interações, segurança" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-doi">DOI</label>
            <input id="sci-doi" type="text" value={doi} onChange={(e) => setDoi(e.target.value)}
              className="admin-input" placeholder="10.xxxx/xxxx" />
          </div>
        </div>

        <div className="admin-form-section-label">Fonte original e licença (caixa “Sobre este artigo”)</div>
        <div className="admin-form-grid">
          <div className="admin-form-group">
            <label htmlFor="sci-journal">Revista</label>
            <input id="sci-journal" type="text" value={journal}
              onChange={(e) => setJournal(e.target.value)}
              className="admin-input" placeholder="Antibiotics" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-volume">Volume</label>
            <input id="sci-volume" type="text" value={volume}
              onChange={(e) => setVolume(e.target.value)}
              className="admin-input" placeholder="11" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-issue">Número</label>
            <input id="sci-issue" type="text" value={issue}
              onChange={(e) => setIssue(e.target.value)}
              className="admin-input" placeholder="10" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-pages">Páginas</label>
            <input id="sci-pages" type="text" value={pages}
              onChange={(e) => setPages(e.target.value)}
              className="admin-input" placeholder="1410" />
          </div>
        </div>
        <div className="admin-form-grid">
          <div className="admin-form-group">
            <label htmlFor="sci-license">Licença</label>
            <input id="sci-license" type="text" value={license}
              onChange={(e) => setLicense(e.target.value)}
              className="admin-input" placeholder="CC BY 4.0" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-license-url">URL da licença</label>
            <input id="sci-license-url" type="text" value={licenseUrl}
              onChange={(e) => setLicenseUrl(e.target.value)}
              className="admin-input" placeholder="https://creativecommons.org/licenses/by/4.0/" />
          </div>
        </div>

        <div className="admin-form-group">
          <label>Autores</label>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {authors.map((author, index) => (
              <div key={index} className="admin-card"
                style={{ padding: 12, border: '1px solid var(--admin-border, #e5e7eb)', borderRadius: 8 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                  <strong style={{ fontSize: 13 }}>Autor {index + 1}</strong>
                  <button type="button" onClick={() => removeAuthor(index)}
                    disabled={authors.length <= 1}
                    className="admin-btn admin-btn-danger" style={{ padding: '4px 8px' }}>
                    <Trash2 size={14} />
                  </button>
                </div>
                <div className="admin-form-grid">
                  <div className="admin-form-group">
                    <label>Nome</label>
                    <input type="text" value={author.name}
                      onChange={(e) => updateAuthor(index, 'name', e.target.value)}
                      className="admin-input" placeholder="Dr. Nome Completo" />
                  </div>
                  <div className="admin-form-group">
                    <label>Instituição</label>
                    <input type="text" value={author.institution}
                      onChange={(e) => updateAuthor(index, 'institution', e.target.value)}
                      className="admin-input" placeholder="Universidade / Hospital" />
                  </div>
                  <div className="admin-form-group">
                    <label>Departamento</label>
                    <input type="text" value={author.department}
                      onChange={(e) => updateAuthor(index, 'department', e.target.value)}
                      className="admin-input" placeholder="Faculdade de Farmácia" />
                  </div>
                  <div className="admin-form-group">
                    <label>Cargo</label>
                    <input type="text" value={author.role}
                      onChange={(e) => updateAuthor(index, 'role', e.target.value)}
                      className="admin-input" placeholder="Investigador Principal" />
                  </div>
                  <div className="admin-form-group">
                    <label>Iniciais (avatar)</label>
                    <input type="text" value={author.avatar} maxLength={4}
                      onChange={(e) => updateAuthor(index, 'avatar', e.target.value)}
                      className="admin-input" placeholder="JP" />
                  </div>
                  <div className="admin-form-group">
                    <label>Cor do avatar</label>
                    <input type="text" value={author.avatarBg}
                      onChange={(e) => updateAuthor(index, 'avatarBg', e.target.value)}
                      className="admin-input" placeholder="#0a844f" />
                  </div>
                  <div className="admin-form-group">
                    <label>ORCID</label>
                    <input type="text" value={author.orcid || ''}
                      onChange={(e) => updateAuthor(index, 'orcid', e.target.value)}
                      className="admin-input" placeholder="0000-0000-0000-0000" />
                  </div>
                </div>
                <label className="admin-checkbox-label" style={{ marginTop: 8, fontWeight: 500 }}>
                  <input
                    type="checkbox"
                    checked={Boolean(author.corresponding)}
                    onChange={(e) => updateAuthor(index, 'corresponding', e.target.checked)}
                    style={{ marginRight: 8 }}
                  />
                  Autor correspondente
                </label>
              </div>
            ))}
          </div>
          <button type="button" onClick={addAuthor} disabled={authors.length >= 12}
            className="admin-btn admin-btn-secondary" style={{ marginTop: 10, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <Plus size={14} /> Adicionar autor
          </button>
        </div>

        <div className="admin-form-group">
          <label>Conteúdo (Markdown)</label>
          <MarkdownEditor value={content} onChange={setContent} />
        </div>

        <ReferenceEditor references={references} onChange={setReferences} />

        <div className="admin-form-grid">
          <div className="admin-form-group">
            <label htmlFor="sci-published">Data de Publicação</label>
            <input id="sci-published" type="date" value={publishedAt}
              onChange={(e) => setPublishedAt(e.target.value)} className="admin-input" />
          </div>
          <div className="admin-form-group">
            <label htmlFor="sci-readtime">Tempo de Leitura (min)</label>
            <input id="sci-readtime" type="number" value={readTime} min={1} max={600}
              onChange={(e) => setReadTime(e.target.value)} className="admin-input" placeholder="15" />
          </div>
        </div>

        {error && (
          <div className="admin-error-message" style={{ display: 'block' }}>{error}</div>
        )}

        <div className="admin-form-actions">
          <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
            <Save size={16} />
            {saving ? 'A guardar...' : mode === 'edit' ? 'Atualizar Artigo Científico' : 'Salvar Artigo Científico'}
          </button>
          <a href={`/${lang}/admin/cientificos`} className="admin-btn admin-btn-secondary">
            <X size={16} /> Cancelar
          </a>
        </div>
      </form>

      {/* Tradução EN (apenas edição) */}
      {mode === 'edit' && initialData?.id && (
        <section className="admin-section"
          style={{ marginTop: 48, padding: 24, background: 'var(--admin-card-bg, #f9fafb)', borderRadius: 8, border: '1px solid var(--admin-border, #e5e7eb)' }}>
          <details>
            <summary style={{ cursor: 'pointer', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
              <Languages size={16} /> Tradução EN
              {translation ? (
                <span className="admin-badge admin-badge-success" style={{ fontSize: 11 }}>✓ Traduzido</span>
              ) : (
                <span className="admin-badge admin-badge-warning" style={{ fontSize: 11 }}>Por traduzir</span>
              )}
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault()
                  handleAutoTranslate()
                }}
                disabled={enAutoTranslating}
                className="admin-btn admin-btn-secondary"
                style={{ marginLeft: 'auto', padding: '6px 12px', fontSize: 13, display: 'inline-flex', alignItems: 'center', gap: 6 }}
                title="Gera a tradução EN com IA (OpenRouter) a partir do conteúdo PT"
              >
                <Sparkles size={14} />
                {enAutoTranslating ? 'A traduzir...' : '✨ Auto-traduzir'}
              </button>
            </summary>
            <form onSubmit={handleSaveEn} style={{ marginTop: 16 }}>
              <div className="admin-form-grid">
                <div className="admin-form-group">
                  <label htmlFor="en-sci-title">Title (EN)</label>
                  <input id="en-sci-title" type="text" value={enTitle}
                    onChange={(e) => setEnTitle(e.target.value)} required className="admin-input" />
                </div>
                <div className="admin-form-group">
                  <label htmlFor="en-sci-slug">Slug (EN)</label>
                  <input id="en-sci-slug" type="text" value={enSlug}
                    onChange={(e) => setEnSlug(e.target.value)} required className="admin-input" placeholder="english-slug" />
                </div>
              </div>
              <div className="admin-form-group">
                <label htmlFor="en-sci-abstract">Abstract (EN)</label>
                <textarea id="en-sci-abstract" value={enAbstract}
                  onChange={(e) => setEnAbstract(e.target.value)}
                  className="admin-textarea" style={{ minHeight: 100 }} />
              </div>
              <div className="admin-form-group">
                <label htmlFor="en-sci-keywords">Keywords (EN, vírgulas)</label>
                <input id="en-sci-keywords" type="text" value={enKeywords}
                  onChange={(e) => setEnKeywords(e.target.value)} className="admin-input" />
              </div>
              <div className="admin-form-group">
                <label>Content (EN, markdown)</label>
                <MarkdownEditor value={enContent} onChange={setEnContent} />
              </div>
              <ReferenceEditor references={enReferences} onChange={setEnReferences} />
              {enError && <div className="admin-error-message" style={{ display: 'block' }}>{enError}</div>}
              {enSuccess && <div className="admin-success-message" style={{ display: 'block' }}>{enSuccess}</div>}
              <div className="admin-form-actions">
                <button type="submit" className="admin-btn admin-btn-primary" disabled={enSaving}>
                  <Save size={16} />
                  {enSaving ? 'A guardar...' : 'Guardar Tradução EN'}
                </button>
              </div>
            </form>
          </details>
        </section>
      )}
    </>
  )
}
