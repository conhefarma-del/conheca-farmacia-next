'use client'

/**
 * BilingualTabs — Admin UI for editing the EN translation of an entity.
 *
 * Two-tab interface (PT | EN). The PT tab is read-only and links back to
 * the entity's main edit form. The EN tab renders editable inputs for
 * each translatable field plus an "Auto-translate" button that calls
 * the OpenRouter-backed server action.
 *
 * Used by:
 *   - app/[lang]/admin/(protected)/artigos/[id]/page.js
 *   - app/[lang]/admin/(protected)/eventos/[id]/page.js
 *   - app/[lang]/admin/(protected)/lives/[id]/page.js
 *
 * Props:
 *   - entityType: 'article' | 'event' | 'live'
 *   - entityId:   UUID
 *   - translation: { title, slug, excerpt, content, ... } | null
 *   - fields:     Array<{ key, label, type?, rows? }> — fields to render in EN tab
 *   - lang:       'pt' | 'en' (URL segment)
 *
 * Server actions used (imported directly — no `onSave` prop):
 *   - autoTranslateEntity
 *   - saveTranslationAction
 */

import { useContext, useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { LangContext } from '@/lib/contexts'
import { autoTranslateEntity, saveTranslationAction } from '@/lib/actions/translation'

function useT() {
  const ctx = useContext(LangContext)
  return (key, fallback) => {
    if (ctx?.t) {
      const v = ctx.t(key)
      if (v && v !== key) return v
    }
    return fallback ?? key
  }
}

export default function BilingualTabs({
  entityType,
  entityId,
  translation,
  fields,
  lang = 'pt',
}) {
  const t = useT()
  const router = useRouter()
  const [activeTab, setActiveTab] = useState('en')
  const [enValues, setEnValues] = useState(() => {
    if (translation) {
      return fields.reduce((acc, f) => {
        acc[f.key] = translation[f.key] ?? ''
        return acc
      }, {})
    }
    return fields.reduce((acc, f) => {
      acc[f.key] = ''
      return acc
    }, {})
  })
  const [isTranslating, startTransition] = useTransition()
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(null)

  const status = !translation
    ? 'missing'
    : translation.auto_translated
    ? 'auto'
    : 'manual'

  function updateField(key, value) {
    setEnValues((prev) => ({ ...prev, [key]: value }))
  }

  function handleAutoTranslate() {
    setError(null)
    setSuccess(null)
    startTransition(async () => {
      try {
        const result = await autoTranslateEntity(entityType, entityId)
        if (result?.ok) {
          if (result.translation) {
            setEnValues(result.translation)
          }
          setSuccess(t('translation.auto_success', 'Tradução gerada com sucesso. Reveja e guarde.'))
          router.refresh()
        } else if (result?.rateLimited) {
          setError(
            t(
              'translation.rate_limited',
              'Limite diário de traduções atingido. Tente novamente mais tarde.'
            )
          )
        } else {
          setError(
            result?.error ||
              t('translation.auto_error', 'Erro ao gerar tradução. Tente novamente.')
          )
        }
      } catch (err) {
        setError(err?.message || String(err))
      }
    })
  }

  async function handleSave(e) {
    e.preventDefault()
    setError(null)
    setSuccess(null)
    setIsSaving(true)
    try {
      const result = await saveTranslationAction(entityType, entityId, enValues)
      if (result?.ok) {
        setSuccess(t('translation.save_success', 'Tradução guardada com sucesso.'))
        router.refresh()
      } else {
        setError(result?.error || t('translation.save_error', 'Erro ao guardar tradução.'))
      }
    } catch (err) {
      setError(err?.message || String(err))
    } finally {
      setIsSaving(false)
    }
  }

  const tabButtonStyle = (isActive) => ({
    padding: '10px 20px',
    border: 'none',
    background: 'none',
    cursor: 'pointer',
    borderBottom: isActive ? '2px solid #2563eb' : '2px solid transparent',
    marginBottom: '-2px',
    fontWeight: isActive ? 600 : 400,
    color: isActive ? '#1e40af' : '#374151',
  })

  const statusBadge = (() => {
    const styles = {
      manual: { bg: '#d1fae5', color: '#065f46', label: '✓ ' + t('translation.status_manual', 'Traduzido') },
      auto: { bg: '#dbeafe', color: '#1e40af', label: '🤖 ' + t('translation.status_auto', 'Auto-traduzido') },
      missing: { bg: '#fee2e2', color: '#991b1b', label: '⚠ ' + t('translation.status_missing', 'Por traduzir') },
    }
    const s = styles[status]
    return (
      <span
        style={{
          fontSize: '11px',
          padding: '2px 8px',
          borderRadius: '9999px',
          background: s.bg,
          color: s.color,
          marginLeft: '8px',
        }}
      >
        {s.label}
      </span>
    )
  })()

  return (
    <div className="bilingual-tabs">
      <div
        role="tablist"
        style={{
          display: 'flex',
          borderBottom: '2px solid #e5e7eb',
          marginBottom: '16px',
        }}
      >
        <button
          type="button"
          role="tab"
          aria-selected={activeTab === 'pt'}
          onClick={() => setActiveTab('pt')}
          style={tabButtonStyle(activeTab === 'pt')}
        >
          {t('translation.tab_pt', 'Português')}
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={activeTab === 'en'}
          onClick={() => setActiveTab('en')}
          style={tabButtonStyle(activeTab === 'en')}
        >
          {t('translation.tab_en', 'English')}
          {statusBadge}
        </button>
      </div>

      {activeTab === 'pt' && (
        <div className="bilingual-tabs__pt" style={{ padding: '16px 0' }}>
          <p style={{ color: '#6b7280', fontStyle: 'italic', margin: '0 0 8px 0' }}>
            {t(
              'translation.pt_hint',
              'A versão PT é editada na página principal do artigo.'
            )}
          </p>
          <a
            href={`/${lang}/admin/${entityType}s/${entityId}`}
            style={{ color: '#2563eb', textDecoration: 'underline' }}
          >
            {t('translation.edit_pt_link', 'Editar versão PT')}
          </a>
        </div>
      )}

      {activeTab === 'en' && (
        <form onSubmit={handleSave} className="bilingual-tabs__en">
          {error && (
            <div
              role="alert"
              style={{
                background: '#fee2e2',
                color: '#991b1b',
                padding: '12px',
                borderRadius: '6px',
                marginBottom: '16px',
              }}
            >
              {error}
            </div>
          )}
          {success && (
            <div
              role="status"
              style={{
                background: '#d1fae5',
                color: '#065f46',
                padding: '12px',
                borderRadius: '6px',
                marginBottom: '16px',
              }}
            >
              {success}
            </div>
          )}

          {!translation && (
            <div
              style={{
                background: '#fff3cd',
                border: '1px solid #ffc107',
                color: '#856404',
                padding: '16px',
                borderRadius: '6px',
                marginBottom: '16px',
              }}
            >
              <p style={{ margin: '0 0 12px 0' }}>
                {t(
                  'translation.no_translation_hint',
                  'Esta entidade ainda não tem tradução EN. Carregue no botão abaixo para gerar uma versão automática via IA, e depois reveja e guarde.'
                )}
              </p>
              <button
                type="button"
                onClick={handleAutoTranslate}
                disabled={isTranslating}
                style={{
                  background: '#2563eb',
                  color: 'white',
                  border: 'none',
                  padding: '10px 20px',
                  borderRadius: '6px',
                  cursor: isTranslating ? 'wait' : 'pointer',
                  fontWeight: 600,
                }}
              >
                {isTranslating
                  ? t('translation.translating', 'A traduzir...')
                  : '✨ ' + t('translation.auto_translate_button', 'Auto-traduzir do PT')}
              </button>
            </div>
          )}

          {fields.map((field) => {
            const value = enValues[field.key] || ''
            const isMultiline = field.type === 'textarea' || field.multiline
            return (
              <div key={field.key} style={{ marginBottom: '16px' }}>
                <label
                  htmlFor={`en-${field.key}`}
                  style={{ display: 'block', fontWeight: 600, marginBottom: '6px' }}
                >
                  {field.label}
                </label>
                {isMultiline ? (
                  <textarea
                    id={`en-${field.key}`}
                    value={value}
                    onChange={(e) => updateField(field.key, e.target.value)}
                    rows={field.rows || 6}
                    style={{
                      width: '100%',
                      padding: '8px',
                      border: '1px solid #d1d5db',
                      borderRadius: '4px',
                      fontFamily: field.key === 'content' ? 'monospace' : 'inherit',
                      resize: 'vertical',
                    }}
                  />
                ) : (
                  <input
                    id={`en-${field.key}`}
                    type="text"
                    value={value}
                    onChange={(e) => updateField(field.key, e.target.value)}
                    style={{
                      width: '100%',
                      padding: '8px',
                      border: '1px solid #d1d5db',
                      borderRadius: '4px',
                    }}
                  />
                )}
              </div>
            )
          })}

          <div style={{ display: 'flex', gap: '8px', marginTop: '24px' }}>
            <button
              type="submit"
              disabled={isSaving}
              style={{
                background: '#059669',
                color: 'white',
                border: 'none',
                padding: '10px 20px',
                borderRadius: '6px',
                cursor: isSaving ? 'wait' : 'pointer',
                fontWeight: 600,
              }}
            >
              {isSaving
                ? t('translation.saving', 'A guardar...')
                : t('translation.save_button', 'Guardar EN')}
            </button>
            {translation && (
              <button
                type="button"
                onClick={handleAutoTranslate}
                disabled={isTranslating}
                style={{
                  background: '#6366f1',
                  color: 'white',
                  border: 'none',
                  padding: '10px 20px',
                  borderRadius: '6px',
                  cursor: isTranslating ? 'wait' : 'pointer',
                }}
              >
                {isTranslating
                  ? t('translation.translating', 'A traduzir...')
                  : '🔄 ' + t('translation.retranslate_button', 'Re-traduzir')}
              </button>
            )}
          </div>
        </form>
      )}
    </div>
  )
}
