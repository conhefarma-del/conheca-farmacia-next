'use client'

import DrugForm from './DrugForm'
import DrugInteractionForm from './DrugInteractionForm'
import DrugProfileForm from './DrugProfileForm'
import DrugPharmacologyForm from './DrugPharmacologyForm'

/**
 * AdminPanels — renderiza os 4 painéis (fármaco, interação, perfil,
 * farmacologia) a partir do objeto devolvido por useAdminPanels.
 */
export default function AdminPanels({ p }) {
  return (
    <>
      {p.drugPanelRendered && (
        <DrugForm
          drug={p.editingDrug}
          panelOpen={p.drugPanelOpen}
          onClose={p.closeDrugPanel}
          onSaved={(ok, text) => { p.showMessage(ok, text); if (ok) p.reload(); p.closeDrugPanel() }}
        />
      )}

      {p.interPanelRendered && (
        <DrugInteractionForm
          interaction={p.editingInteraction}
          drugs={p.drugs}
          panelOpen={p.interPanelOpen}
          onClose={p.closeInterPanel}
          onSaved={(ok, text) => { p.showMessage(ok, text); if (ok) p.reload(); p.closeInterPanel() }}
        />
      )}

      {p.profilePanelRendered && (
        <DrugProfileForm
          drug={p.editingProfileDrug}
          profile={p.editingProfile}
          panelOpen={p.profilePanelOpen}
          onClose={p.closeProfilePanel}
          onSaved={(ok, text) => { p.showMessage(ok, text); if (ok) p.reload(); p.closeProfilePanel() }}
        />
      )}

      {p.pharmacologyPanelRendered && (
        <DrugPharmacologyForm
          drug={p.editingPharmacologyDrug}
          pharmacology={p.editingPharmacology}
          panelOpen={p.pharmacologyPanelOpen}
          onClose={p.closePharmacologyPanel}
          onSaved={(ok, text) => { p.showMessage(ok, text); if (ok) p.reload(); p.closePharmacologyPanel() }}
        />
      )}
    </>
  )
}
