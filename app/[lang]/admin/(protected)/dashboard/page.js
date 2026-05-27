import StatsGrid from '@/components/admin/StatsGrid'
import ActivityTimeline from '@/components/admin/ActivityTimeline'
import DashboardCharts from '@/components/admin/DashboardCharts'
import {
  getDashboardStats,
  getActivityTimeline,
  getPageViewsByPeriod,
  getInscriptionsByPeriod,
  getCategoryDistribution,
} from '@/lib/actions/dashboard'

/**
 * Dashboard Page — Server Component (puro)
 *
 * Busca TODOS os dados no servidor e passa como props
 * para os componentes visuais.
 *
 * - StatsGrid: Server Component (6 stat cards)
 * - ActivityTimeline: Server Component (audit_logs)
 * - DashboardCharts: Client Component wrapper (Chart.js)
 */

export default async function DashboardPage() {
  // Buscar todos os dados em paralelo no servidor
  const [stats, auditLogs, pageViews, inscriptions, categoryDistribution] =
    await Promise.all([
      getDashboardStats(),
      getActivityTimeline(10),
      getPageViewsByPeriod('week'),
      getInscriptionsByPeriod('week'),
      getCategoryDistribution(),
    ])

  const safeStats = stats || {
    articles: 0,
    events: 0,
    lives: 0,
    users: 0,
    categories: 0,
    total: 0,
  }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Dashboard</h1>
        <p className="admin-page-subtitle">
          Visão geral do painel administrativo
        </p>
      </div>

      {/* Secção 1: Stats + Activity Timeline (2 colunas) */}
      <div className="admin-dashboard-layout">
        <StatsGrid {...safeStats} />
        <ActivityTimeline auditLogs={auditLogs} />
      </div>

      {/* Secção 2: Charts (gráfico categorias + atividade) */}
      <DashboardCharts
        initialPageViews={pageViews}
        initialInscriptions={inscriptions}
        categoryDistribution={categoryDistribution}
      />
    </>
  )
}
