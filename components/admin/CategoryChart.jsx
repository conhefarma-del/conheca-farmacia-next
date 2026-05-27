'use client'

import { useRef, useEffect } from 'react'
import { Chart, BarController, BarElement, CategoryScale, LinearScale, Tooltip } from 'chart.js'

Chart.register(BarController, BarElement, CategoryScale, LinearScale, Tooltip)

/**
 * CategoryChart — Client Component
 *
 * Gráfico de barras horizontais: distribuição por categoria.
 * Usa classes CSS do admin.css (`.admin-dashboard-card`, `.admin-chart-container`).
 *
 * Props: { distribution: Array<{ category: string, count: number }> }
 */

const COLORS = [
  '#ff6c23',
  '#0a844f',
  '#7c3aed',
  '#002a32',
  '#006171',
  '#ec4899',
]

function formatLabel(label) {
  return label.replace(/-/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase())
}

export default function CategoryChart({ distribution = [] }) {
  const canvasRef = useRef(null)
  const chartRef = useRef(null)

  useEffect(() => {
    if (!canvasRef.current) return

    const ctx = canvasRef.current.getContext('2d')

    chartRef.current = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: distribution.map((d) => formatLabel(d.category)),
        datasets: [
          {
            label: 'Conteúdos',
            data: distribution.map((d) => d.count),
            backgroundColor: distribution.map((_, i) => COLORS[i % COLORS.length]),
            borderRadius: 4,
            barThickness: 10,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: 'y',
        plugins: {
          legend: { display: false },
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
  }, [distribution])

  return (
    <div className="admin-dashboard-card">
      <h3>Distribuição por Categoria</h3>
      <div className="admin-chart-container">
        <canvas ref={canvasRef} />
      </div>
    </div>
  )
}
