'use client'

import { useRef, useEffect, useState, useCallback } from 'react'
import { Chart, BarController, BarElement, CategoryScale, LinearScale, Tooltip } from 'chart.js'

// Registar apenas os componentes necessários (tree-shaking)
Chart.register(BarController, BarElement, CategoryScale, LinearScale, Tooltip)

/**
 * ActivityChart — Client Component
 *
 * Gráfico de barras horizontais: visitas + inscrições.
 * Filtros de período: day/week/month/6months/year.
 * Usa classes CSS do admin.css (`.admin-chart-*`).
 *
 * Props:
 *   - initialPageViews: número de visitas (período default: week)
 *   - initialInscriptions: número de inscrições (período default: week)
 *   - onPeriodChange: callback(period) → Server Action para buscar dados
 */

const PERIODS = [
  { key: 'day', label: 'Dia' },
  { key: 'week', label: 'Semana' },
  { key: 'month', label: 'Mês' },
  { key: '6months', label: '6 Meses' },
  { key: 'year', label: 'Ano' },
]

const COLORS = [
  'rgba(59, 130, 246, 0.8)',   // azul — visitas
  'rgba(249, 115, 22, 0.8)',   // laranja — inscrições
]

export default function ActivityChart({ initialPageViews = 0, initialInscriptions = 0, onPeriodChange }) {
  const canvasRef = useRef(null)
  const chartRef = useRef(null)
  const [activePeriod, setActivePeriod] = useState('week')
  const [loading, setLoading] = useState(false)

  // Criar instância do Chart.js
  useEffect(() => {
    if (!canvasRef.current) return

    const ctx = canvasRef.current.getContext('2d')

    chartRef.current = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Visitas ao Site', 'Inscrições em Eventos'],
        datasets: [{
          label: 'Conteúdos',
          data: [initialPageViews, initialInscriptions],
          backgroundColor: COLORS,
          borderRadius: 4,
          barThickness: 10,
        }],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: 'y',
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: (context) => `${context.parsed.x} registos`,
            },
          },
        },
        scales: {
          x: {
            beginAtZero: true,
            grid: { color: 'rgba(0, 0, 0, 0.05)' },
          },
          y: {
            grid: { display: false },
          },
        },
      },
    })

    return () => {
      if (chartRef.current) {
        chartRef.current.destroy()
        chartRef.current = null
      }
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  // Atualizar dados iniciais
  useEffect(() => {
    if (chartRef.current) {
      chartRef.current.data.datasets[0].data = [initialPageViews, initialInscriptions]
      chartRef.current.update()
    }
  }, [initialPageViews, initialInscriptions])

  // Filtro de período
  const handlePeriodChange = useCallback(async (period) => {
    if (!onPeriodChange || loading) return

    setActivePeriod(period)
    setLoading(true)

    try {
      const result = await onPeriodChange(period)
      if (result && chartRef.current) {
        chartRef.current.data.datasets[0].data = [
          result.pageViews || 0,
          result.inscriptions || 0,
        ]
        chartRef.current.update()
      }
    } catch {
      // Erro silencioso — dados ficam como estão
    } finally {
      setLoading(false)
    }
  }, [onPeriodChange, loading])

  return (
    <div className="admin-dashboard-card">
      <div className="admin-chart-header">
        <h3>Atividade do Site</h3>
        <div className="admin-chart-filters">
          {PERIODS.map(({ key, label }) => (
            <button
              key={key}
              className={`admin-chart-filter-btn${activePeriod === key ? ' active' : ''}`}
              onClick={() => handlePeriodChange(key)}
              disabled={loading}
            >
              {label}
            </button>
          ))}
        </div>
      </div>
      <div className="admin-chart-container">
        <canvas ref={canvasRef} />
      </div>
    </div>
  )
}
