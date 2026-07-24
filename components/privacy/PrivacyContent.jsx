'use client'

import PendingBadge from '@/components/ui/PendingBadge'

export default function PrivacyContent({ sections, lang, t }) {
  return (
    <div className="privacy-content prose prose-lg prose-muted dark:prose-invert max-w-3xl">
      <p className="text-sm text-muted-foreground mb-8">
        <em>{t('privacy_page.last_updated')}: [DD/MM/AAAA]</em>
      </p>

      {sections.map((section) => (
        <div key={section.anchor_slug}>
          {/* Level 1 section */}
          <section
            id={`section-${section.anchor_slug}`}
            className="privacy-section scroll-mt-24"
          >
            <h2 className="privacy-heading">
              {section[`title_${lang}`] || section.title_pt}
              {section.pending && (
                <PendingBadge label={t('privacy_page.pending_badge')} />
              )}
            </h2>
            <div
              className={section.pending ? 'privacy-content--pending' : ''}
              dangerouslySetInnerHTML={{ __html: renderMarkdown(section[`content_${lang}`] || section.content_pt) }}
            />
            {section.pending && (
              <p className="text-sm text-muted-foreground mt-2 italic">
                {t('privacy_page.pending_section_note')}
              </p>
            )}
          </section>

          {/* Level 2 children */}
          {section.children && section.children.length > 0 && section.children.map((child) => (
            <section
              key={child.anchor_slug}
              id={`section-${child.anchor_slug}`}
              className="privacy-section privacy-section--sub scroll-mt-24"
            >
              <h3 className="privacy-heading privacy-heading--sub">
                {child[`title_${lang}`] || child.title_pt}
                {child.pending && (
                  <PendingBadge label={t('privacy_page.pending_badge')} />
                )}
              </h3>
              <div
                className={child.pending ? 'privacy-content--pending' : ''}
                dangerouslySetInnerHTML={{ __html: renderMarkdown(child[`content_${lang}`] || child.content_pt) }}
              />
              {child.pending && (
                <p className="text-sm text-muted-foreground mt-2 italic">
                  {t('privacy_page.pending_section_note')}
                </p>
              )}
            </section>
          ))}

          <hr className="privacy-divider" />
        </div>
      ))}
    </div>
  )
}

/**
 * Simple markdown → HTML renderer for bold, italic, lists, paragraphs.
 * This is intentionally minimal — the content is pre-authored markdown
 * from the source policiesfc/*.md files.
 */
function renderMarkdown(text) {
  if (!text) return ''
  return text
    .split('\n\n')
    .map((block) => {
      block = block.trim()
      if (!block) return ''
      // Unordered list
      if (block.startsWith('- ')) {
        const items = block.split('\n').filter((l) => l.startsWith('- '))
        const lis = items.map((item) => `<li>${inlineMarkdown(item.slice(2))}</li>`).join('')
        return `<ul>${lis}</ul>`
      }
      // Paragraph
      return `<p>${inlineMarkdown(block)}</p>`
    })
    .join('\n')
}

function inlineMarkdown(text) {
  return text
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/\n/g, '<br />')
}
