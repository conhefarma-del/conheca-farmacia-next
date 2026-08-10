'use client'

import Link from 'next/link'
import {
  archiveDrug, deleteDrug, restoreDrug,
} from '@/lib/actions/interacoes'
import useAdminPanels from './useAdminPanels'
import DrugAdminTable from './DrugAdminTable'
import AdminPanels from './AdminPanels'

export default function FarmacosAdminPage({ lang, initialDrugs, initialInteractions, currentUserRole }) {
  const p = useAdminPanels(initialDrugs, initialInteractions)

  return (
    <div className="admin-interacoes">
      <p className="admin-back-link">
        <Link href={`/${lang}/admin/interacoes`}>← Interações</Link>
      </p>
      <div className="admin-page-header">
        <h1>Fármacos</h1>
        <p className="admin-page-subtitle">
          Todos os {p.drugs.length} fármacos — perfil, farmacologia, edição, arquivação e eliminação.
        </p>
      </div>

      {p.message && <div className="admin-message admin-success-message">{p.message}</div>}
      {p.error && <div className="admin-message admin-error-message">{p.error}</div>}

      <DrugAdminTable
        drugs={p.drugs}
        currentUserRole={currentUserRole}
        onProfile={p.openProfileForm}
        onPharmacology={p.openPharmacologyForm}
        onEdit={p.openDrugForm}
        onArchive={(d) => p.run(() => archiveDrug(d.id), 'Fármaco arquivado.')}
        onRestore={(d) => p.run(() => restoreDrug(d.id), 'Fármaco restaurado.')}
        onDelete={(d) => {
          if (window.confirm('Eliminar fármaco? (bloqueado se tiver interações)')) p.run(() => deleteDrug(d.id), 'Fármaco eliminado.')
        }}
      />

      <AdminPanels p={p} />
    </div>
  )
}
