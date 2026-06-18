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

import { useContext, useEffect, useState, useTransition } from 'react'
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
  ptHosts = [],
}) {
  const t = useT()
  const router = useRouter()
  const [activeTab, setActiveTab] = useState('en')
  // Sync enHosts with ptHosts when the PT list changes (e.g. admin added
  // or removed a host in the PT form, then re-opened the EN tab). The
  // initial state mirrors ptHosts; this effect preserves any manual EN
  // edits already made while padding / truncating to match ptHosts.length.
  useEffect(() => {
    setEnHosts((prev) => {
      const ptLen = Array.isArray(ptHosts) ? ptHosts.length : 0
      if (prev.length === ptLen) return prev
      if (prev.length < ptLen) {
        // Admin added host(s) in PT — pad with blank slots for the new ones,
        // keeping existing edits for the ones we already had.
        return [
          ...prev,
          ...Array.from({ length: ptLen - prev.length }, () => ({ name: '', role: '', organization: '' })),
        ]
      }
      // Admin removed host(s) from PT — truncate (extra EN slots are stale).
      return prev.slice(0, ptLen)
    })
  }, [ptHosts])
  const [enHosts, setEnHosts] = useState(() => {
    // Hydrate hosts array from translation.hosts (JSONB) when present,
    // otherwise mirror ptHosts so each PT host gets a blank EN slot.
    // The list length is bounded by MAX(translation.hosts, ptHosts) so
    // a PT edit that adds a host is reflected immediately on first
    // render (not only after the useEffect below runs).
    const ptLen = Array.isArray(ptHosts) ? ptHosts.length : 0
    const trArr = Array.isArray(translation?.hosts) ? translation.hosts : []
    const len = Math.max(trArr.length, ptLen)
    const slots = Array.from({ length: len }, (_, i) => {
      const tr = trArr[i]
      return {
        name: tr?.name ?? '',
        role: tr?.role ?? '',
        organization: tr?.organization ?? '',
      }
    })
    return slots
  })
  const [enValues, setEnValues] = useState(() => {
    if (translation) {
      return fields.reduce((acc, f) => {
        // Hosts live in a separate state (enHosts) because they are an
        // array of objects, not a scalar — skip here.
        if (f.key === 'hosts') return acc
        acc[f.key] = translation[f.key] ?? ''
        return acc
      }, {})
    }
    return fields.reduce((acc, f) => {
      if (f.key === 'hosts') return acc
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

  function updateHost(index, key, value) {
    setEnHosts((prev) => {
      const next = [...prev]
      next[index] = { ...next[index], [key]: value }
      return next
    })
  }

  function handleAutoTranslate() {
    setError(null)
    setSuccess(null)
    startTransition(async () => {
      try {
        const result = await autoTranslateEntity(entityType, entityId)
        if (result?.ok) {
          if (result.translation) {
            // Merge instead of replace: preserve fields the LLM didn't return
            // (e.g. topic/category_label that Gemma 4 31B may leave empty).
            // Also skip empty strings to avoid wiping manual edits.
            setEnValues((prev) => {
              const next = { ...prev }
              for (const [k, v] of Object.entries(result.translation)) {
                if (v === '' || v == null) continue
                next[k] = v
              }
              return next
            })
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
      // Build the hosts payload aligned to ptHosts.length (the source of
      // truth for "how many cards render on /en"). For each PT host:
      //   - name & organization stay in PT (not translatable)
      //   - role: use the EN edit if non-empty, else fall back to the PT
      //     role so the public /en page keeps showing the same N cards
      //     as /pt even if the admin hasn't translated every host yet.
      // Drop the entry only if the PT source itself is empty (no name AND
      // no role AND no organization) — that means the host doesn't exist
      // on the PT side and shouldn't be in the EN translation either.
      const ptLen = Array.isArray(ptHosts) ? ptHosts.length : 0
      const hostsPayload = []
      for (let i = 0; i < ptLen; i++) {
        const pt = ptHosts[i] || {}
        const en = enHosts[i] || {}
        const name = pt.name ?? ''
        const role = (en.role ?? '').trim() || (pt.role ?? '')
        const organization = pt.organization ?? ''
        if (!name && !role && !organization) continue
        hostsPayload.push({ name, role, organization })
      }
      const payload = { ...enValues, hosts: hostsPayload }
      const result = await saveTranslationAction(entityType, entityId, payload)
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

  // Dark-mode safe: all colors reference --admin-* variables that flip under html.dark.
  const tabButtonStyle = (isActive) => ({
    padding: '10px 20px',
    border: 'none',
    background: 'none',
    cursor: 'pointer',
    borderBottom: isActive
      ? '2px solid var(--admin-accent)'
      : '2px solid transparent',
    marginBottom: '-2px',
    fontWeight: isActive ? 600 : 400,
    color: isActive ? 'var(--admin-accent)' : 'var(--admin-text-muted)',
  })

  // Status pill colors are derived from --admin-* vars (success/warning/danger palettes).
  const statusBadge = (() => {
    const styles = {
      manual: {
        bg: 'var(--admin-success-bg, #d1fae5)',
        color: 'var(--admin-success, #065f46)',
        label: '✓ ' + t('translation.status_manual', 'Traduzido'),
      },
      auto: {
        bg: 'var(--admin-info-bg, #dbeafe)',
        color: 'var(--admin-accent, #1e40af)',
        label: '🤖 ' + t('translation.status_auto', 'Auto-traduzido'),
      },
      missing: {
        bg: 'var(--admin-danger-bg, #fee2e2)',
        color: 'var(--admin-danger, #991b1b)',
        label: '⚠ ' + t('translation.status_missing', 'Por traduzir'),
      },
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

  // Shared input style for the EN form fields.
  const fieldInputStyle = {
    width: '100%',
    padding: '8px',
    border: '1px solid var(--admin-border, #d1d5db)',
    borderRadius: '4px',
    background: 'var(--admin-input-bg, var(--admin-card-bg, #ffffff))',
    color: 'var(--admin-text)',
  }

  return (
    <div className="bilingual-tabs">
      <div
        role="tablist"
        style={{
          display: 'flex',
          borderBottom: '2px solid var(--admin-border, #e5e7eb)',
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
          <p
            style={{
              color: 'var(--admin-text-muted)',
              fontStyle: 'italic',
              margin: '0 0 8px 0',
            }}
          >
            {t(
              'translation.pt_hint',
              'A versão PT é editada na página principal do artigo.'
            )}
          </p>
          <a
            href={`/${lang}/admin/${entityType}s/${entityId}`}
            style={{ color: 'var(--admin-accent)', textDecoration: 'underline' }}
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
                background: 'var(--admin-danger-bg, #fee2e2)',
                color: 'var(--admin-danger, #991b1b)',
                padding: '12px',
                borderRadius: '6px',
                marginBottom: '16px',
                border: '1px solid var(--admin-danger, #991b1b)',
              }}
            >
              {error}
            </div>
          )}
          {success && (
            <div
              role="status"
              style={{
                background: 'var(--admin-success-bg, #d1fae5)',
                color: 'var(--admin-success, #065f46)',
                padding: '12px',
                borderRadius: '6px',
                marginBottom: '16px',
                border: '1px solid var(--admin-success, #065f46)',
              }}
            >
              {success}
            </div>
          )}

          {!translation && (
            <div
              style={{
                background: 'var(--admin-warning-bg, #fff3cd)',
                border: '1px solid var(--admin-warning, #ffc107)',
                color: 'var(--admin-warning, #856404)',
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
                  background: 'var(--admin-accent)',
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
            // Special: hosts is an array rendered as N cards based on ptHosts.
            if (field.key === 'hosts') {
              return (
                <div key="hosts" style={{ marginBottom: '24px' }}>
                  <label
                    style={{
                      display: 'block',
                      fontWeight: 600,
                      marginBottom: '6px',
                      color: 'var(--admin-text)',
                    }}
                  >
                    {field.label || 'Hosts'}
                  </label>
                  <p
                    style={{
                      fontSize: '12px',
                      color: 'var(--admin-text-muted)',
                      margin: '0 0 8px 0',
                    }}
                  >
                    {t(
                      'translation.hosts_hint',
                      `${enHosts.length} host(s) — o número é fixado pela versão PT. Para alterar, edite a versão PT.`
                    )}
                  </p>
                  {enHosts.map((host, index) => (
                    <div
                      key={index}
                      style={{
                        border: '1px solid var(--admin-border, #e5e7eb)',
                        borderRadius: '6px',
                        padding: '12px',
                        marginBottom: '8px',
                        background: 'var(--admin-card-bg, #f9fafb)',
                      }}
                    >
                      <div
                        style={{
                          fontSize: '11px',
                          fontWeight: 600,
                          color: 'var(--admin-text-muted)',
                          marginBottom: '8px',
                          textTransform: 'uppercase',
                        }}
                      >
                        Host {index + 1}
                        {ptHosts[index]?.name && (
                          <span
                            style={{
                              fontWeight: 400,
                              textTransform: 'none',
                              marginLeft: '6px',
                              color: 'var(--admin-text-muted)',
                            }}
                          >
                            (PT: {ptHosts[index].name})
                          </span>
                        )}
                      </div>
                      <input
                        type="text"
                        placeholder={t('translation.host_name_placeholder', 'Nome em inglês')}
                        value={ptHosts[index]?.name ?? ''}
                        readOnly
                        title={t('translation.host_name_readonly', 'O nome mantém-se em PT — não é traduzível.')}
                        style={{ ...fieldInputStyle, marginBottom: '6px', background: 'var(--admin-input-readonly-bg, #f3f4f6)', color: 'var(--admin-text-muted)' }}
                      />
                      <input
                        type="text"
                        placeholder={t('translation.host_role_placeholder', 'Cargo / papel em inglês')}
                        value={host.role}
                        onChange={(e) => updateHost(index, 'role', e.target.value)}
                        style={{ ...fieldInputStyle, marginBottom: '6px' }}
                      />
                      <input
                        type="text"
                        placeholder={t('translation.host_org_placeholder', 'Organização em inglês')}
                        value={ptHosts[index]?.organization ?? ''}
                        readOnly
                        title={t('translation.host_org_readonly', 'A organização mantém-se em PT — não é traduzível.')}
                        style={{ ...fieldInputStyle, background: 'var(--admin-input-readonly-bg, #f3f4f6)', color: 'var(--admin-text-muted)' }}
                      />
                    </div>
                  ))}
                </div>
              )
            }

            const value = enValues[field.key] || ''
            const isMultiline = field.type === 'textarea' || field.multiline

            // Special: type is a select with 3 fixed options.
            if (field.key === 'type') {
              return (
                <div key={field.key} style={{ marginBottom: '16px' }}>
                  <label
                    htmlFor={`en-${field.key}`}
                    style={{
                      display: 'block',
                      fontWeight: 600,
                      marginBottom: '6px',
                      color: 'var(--admin-text)',
                    }}
                  >
                    {field.label}
                  </label>
                  <select
                    id={`en-${field.key}`}
                    value={value || ''}
                    onChange={(e) => updateField(field.key, e.target.value)}
                    style={fieldInputStyle}
                  >
                    <option value="">—</option>
                    <option value="presencial">Presencial / In Person</option>
                    <option value="online">Online</option>
                    <option value="hibrido">Híbrido / Hybrid</option>
                  </select>
                </div>
              )
            }

            return (
              <div key={field.key} style={{ marginBottom: '16px' }}>
                <label
                  htmlFor={`en-${field.key}`}
                  style={{
                    display: 'block',
                    fontWeight: 600,
                    marginBottom: '6px',
                    color: 'var(--admin-text)',
                  }}
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
                      ...fieldInputStyle,
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
                    style={fieldInputStyle}
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
                background: 'var(--admin-success, #059669)',
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
                  background: 'var(--admin-indigo, #6366f1)',
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
