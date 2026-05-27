'use client'

import { useState, useCallback } from 'react'
import { escapeHtml } from '@/lib/security'

/**
 * AnalyticsCard — Client Component
 *
 * Card de analytics para list pages (top artigos/eventos/lives).
 * Filtros de métrica com toggle.
 *
 * Props:
 *   - metrics: Array<{ key: string, label: string }>
 *   - onMetricChange: (metric: string) => Promise<Array<{ title, slug, [valueKey] }>>
 *   - initialData: Array
 *   - initialMetric: string
 *   - valueFormatter: (value, metric) => string
 */

export default function AnalyticsCard({
  metrics = [],
  onMetricChange,
  initialData = [],
  initialMetric = 'views',
  valueFormatter,
}) {
  const [activeMetric, setActiveMetric] = useState(initialMetric)
  const [data, setData] = useState(initialData)
  const [loading, setLoading] = useState(false)

  const handleMetricChange = useCallback(async (metric) => {
    if (!onMetricChange || loading) return

    setActiveMetric(metric)
    setLoading(true)

    try {
      const result = await onMetricChange(metric)
      setData(result || [])
    } catch {
      // Erro silencioso
    } finally {
      setLoading(false)
    }
  }, [onMetricChange, loading])

  const defaultFormatter = (value) => String(value || 0)
  const format = valueFormatter || defaultFormatter

  return (
    <div className="admin-stat-card" style={{ background: 'var(--admin-card-bg)', color: 'var(--admin-text)' }}>
      <div className="admin-analytics-card">
        <div className="admin-analytics-filters" id="analytics-filters">
          {metrics.map(({ key, label }) => (
            <button
              key={key}
              className={`admin-analytics-filter${activeMetric === key ? ' active' : ''}`}
              onClick={() => handleMetricChange(key)}
              disabled={loading}
            >
              {label}
            </button>
          ))}
        </div>
        <div className="admin-analytics-list" id="analytics-list">
          {loading ? (
            <p style={{ color: 'var(--admin-text-muted)', fontSize: 13 }}>A carregar...</p>
          ) : data.length === 0 ? (
            <p style={{ color: 'var(--admin-text-muted)', fontSize: 13 }}>Sem dados ainda</p>
          ) : (
            data.map((item, i) => {
              const valueKey = activeMetric === 'shares'
                ? 'share_count'
                : activeMetric === 'reading'
                  ? 'total_reading_time'
                  : activeMetric === 'fill'
                    ? 'capacity'
                    : activeMetric === 'access'
                      ? 'access_count'
                      : activeMetric === 'downloads'
                        ? 'download_count'
                        : 'view_count'
              return (
                <div key={item.slug || i} className="admin-analytics-item">
                  <span className="admin-analytics-rank">{i + 1}</span>
                  <span className="admin-analytics-title">{escapeHtml(item.title)}</span>
                  <span className="admin-analytics-value">{format(item[valueKey], activeMetric)}</span>
                </div>
              )
            })
          )}
        </div>
      </div>
    </div>
  )
}
