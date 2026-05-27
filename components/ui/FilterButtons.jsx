'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'

export default function FilterButtons({ categories, activeFilter, onFilterChange, dataAttr = 'filter' }) {
  const { t } = useContext(LangContext)
  const allLabel = t('content.todos')

  return (
    <div className="category-filter">
      <button
        className={`filter-btn ${activeFilter === 'all' ? 'active' : ''}`}
        data-filter="all"
        data-category="all"
        onClick={() => onFilterChange('all')}
      >
        {allLabel}
      </button>
      {Object.entries(categories).map(([key, label]) => (
        <button
          key={key}
          className={`filter-btn ${activeFilter === key ? 'active' : ''}`}
          data-filter={key}
          data-category={key}
          onClick={() => onFilterChange(key)}
        >
          {label}
        </button>
      ))}
    </div>
  )
}
