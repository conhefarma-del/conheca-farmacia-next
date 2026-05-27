'use client'

import { useCallback } from 'react'
import ActivityChart from '@/components/admin/ActivityChart'
import CategoryChart from '@/components/admin/CategoryChart'
import { getPageViewsByPeriod, getInscriptionsByPeriod } from '@/lib/actions/dashboard'

/**
 * DashboardCharts — Client Component wrapper
 *
 * Necessário porque ActivityChart precisa de chamar Server Actions
 * para buscar dados de períodos diferentes.
 *
 * Props:
 *   - initialPageViews, initialInscriptions: dados iniciais do server
 *   - categoryDistribution: dados do gráfico de categorias
 */

export default function DashboardCharts({
  initialPageViews = 0,
  initialInscriptions = 0,
  categoryDistribution = [],
}) {
  // Callback para mudança de período — chama Server Actions
  const handlePeriodChange = useCallback(async (period) => {
    const [pageViews, inscriptions] = await Promise.all([
      getPageViewsByPeriod(period),
      getInscriptionsByPeriod(period),
    ])
    return { pageViews, inscriptions }
  }, [])

  return (
    <div className="admin-dashboard-grid">
      <CategoryChart distribution={categoryDistribution} />
      <ActivityChart
        initialPageViews={initialPageViews}
        initialInscriptions={initialInscriptions}
        onPeriodChange={handlePeriodChange}
      />
    </div>
  )
}
