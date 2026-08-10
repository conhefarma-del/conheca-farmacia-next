'use client'

import Link from 'next/link'
import {
  archiveDrugInteraction, deleteDrugInteraction, restoreDrugInteraction,
} from '@/lib/actions/interacoes'
import useAdminPanels from './useAdminPanels'
import InteractionAdminTable from './InteractionAdminTable'
import AdminPanels from './AdminPanels'

export default function ParesAdminPage({ lang, initialDrugs, initialInteractions, currentUserRole }) {
  const p = useAdminPanels(initialDrugs, initialInteractions)

  return (
    <div className="admin-interacoes">
      <p className="admin-back-link">
        <Link href={`/${lang}/admin/interacoes`}>← Interações</Link>
      </p>
      <div className="admin-page-header">
        <h1>Interações fármaco–fármaco</h1>
        <p className="admin-page-subtitle">
          Todas as {p.interactions.length} interações — edição, arquivação e eliminação.
        </p>
      </div>

      {p.message && <div className="admin-message admin-success-message">{p.message}</div>}
      {p.error && <div className="admin-message admin-error-message">{p.error}</div>}

      <InteractionAdminTable
        interactions={p.interactions}
        currentUserRole={currentUserRole}
        onEdit={p.openInteractionForm}
        onArchive={(i) => p.run(() => archiveDrugInteraction(i.id), 'Interação arquivada.')}
        onRestore={(i) => p.run(() => restoreDrugInteraction(i.id), 'Interação restaurada.')}
        onDelete={(i) => {
          if (window.confirm('Eliminar interação?')) p.run(() => deleteDrugInteraction(i.id), 'Interação eliminada.')
        }}
      />

      <AdminPanels p={p} />
    </div>
  )
}
