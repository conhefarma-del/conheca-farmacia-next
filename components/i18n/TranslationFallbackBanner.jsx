import Link from 'next/link'

/**
 * Banner shown on `/en/*` pages when the current article/event/live is being
 * rendered with the PT (fallback) content because no EN translation exists.
 *
 * Visually understated: a thin yellow band at the top of the content area,
 * with a clear message in the user's chrome language.
 *
 * Props:
 *  - `entityType`: 'article' | 'event' | 'live'
 *  - `ptSlug`: slug of the PT version (used in admin "Translate now" link)
 *  - `entityId`: UUID of the entity (used in admin link)
 *  - `isAdmin`: show admin shortcut link to translate
 *  - `lang`: the requested page lang (so we can decide whether to render at all)
 */
export default function TranslationFallbackBanner({
  entityType,
  ptSlug,
  entityId,
  isAdmin = false,
  lang,
}) {
  if (lang !== 'en') return null

  const isArtigo = entityType === 'article'
  const isEvento = entityType === 'event'
  const isLive = entityType === 'live'

  const adminPath = isArtigo
    ? `/admin/artigos/${entityId}`
    : isEvento
    ? `/admin/eventos/${entityId}`
    : `/admin/lives/${entityId}`

  return (
    <div
      role="status"
      aria-live="polite"
      className="translation-fallback-banner"
    >
      <div className="translation-fallback-banner__icon" aria-hidden="true">
        ⚠
      </div>
      <div className="translation-fallback-banner__text">
        <strong>This page is not yet translated to English.</strong>{' '}
        You are reading the original Portuguese version.
        {isAdmin && (
          <>
            {' '}
            <Link
              href={adminPath}
              className="translation-fallback-banner__link"
            >
              Translate this {isArtigo ? 'article' : isEvento ? 'event' : 'live'} →
            </Link>
          </>
        )}
      </div>
    </div>
  )
}
