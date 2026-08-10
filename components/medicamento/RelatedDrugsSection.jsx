'use client'

import { useContext } from 'react'
import Link from 'next/link'
import { BookOpen } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

// Secção de fármacos relacionados/similares da ficha do fármaco (/medicamento/[slug])
// — lazy-loaded via next/dynamic porque fica abaixo da dobra.
export default function RelatedDrugsSection({ lang, relatedDrugs }) {
  const { t } = useContext(LangContext)
  if (!relatedDrugs || relatedDrugs.length === 0) return null
  const detailPath = (slug) =>
    `/${lang}/${lang === 'pt' ? 'medicamento' : 'medicine'}/${slug}`
  return (
    <section className="medicamento-section">
      <h2 className="medicamento-section-title">
        <BookOpen size={18} aria-hidden="true" />
        {t('medicamento_detalhe.secao_relacionados')}
      </h2>
      <p className="medicamento-section-subtitle">
        {t('medicamento_detalhe.relacionados_subtitle')}
      </p>
      <div className="related-drugs">
        {relatedDrugs.map((d) => (
          <Link
            key={d.id}
            href={detailPath(d.slug)}
            className="related-drug-chip"
          >
            <span className="related-drug-name">{d.name}</span>
            {d.className && (
              <span className="related-drug-class">{d.className}</span>
            )}
          </Link>
        ))}
      </div>
    </section>
  )
}
