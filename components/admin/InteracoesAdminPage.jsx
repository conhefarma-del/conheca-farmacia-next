'use client'

import { useCallback, useState } from 'react'
import { useRouter } from 'next/navigation'
import {
  archiveDrug, archiveDrugInteraction, deleteDrug, deleteDrugInteraction,
  getAllDrugInteractions, getAllDrugs, getDrugInteractionDetail,
  restoreDrug, restoreDrugInteraction,
} from '@/lib/actions/interacoes'
import DrugForm from './DrugForm'
import DrugInteractionForm from './DrugInteractionForm'
import DrugProfileForm from './DrugProfileForm'
import DrugPharmacologyForm from './DrugPharmacologyForm'
import { getDrugPharmacology, getDrugProfile } from '@/lib/actions/medicamentos'

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">Arquivado</span>
}

const SEVERITY_LABELS = {
  critical: 'Grave',
  moderate: 'Moderada',
  minor: 'Menor',
  none: 'Sem relevância',
}

export default function InteracoesAdminPage({ lang, initialDrugs, initialInteractions, currentUserRole }) {
  const router = useRouter()
  const [drugs, setDrugs] = useState(initialDrugs)
  const [interactions, setInteractions] = useState(initialInteractions)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)

  // Painel: Fármaco
  const [drugPanelOpen, setDrugPanelOpen] = useState(false)
  const [drugPanelRendered, setDrugPanelRendered] = useState(false)
  const [editingDrug, setEditingDrug] = useState(null)

  // Painel: Interação
  const [interPanelOpen, setInterPanelOpen] = useState(false)
  const [interPanelRendered, setInterPanelRendered] = useState(false)
  const [editingInteraction, setEditingInteraction] = useState(null)

  // Painel: Perfil de fármaco
  const [profilePanelOpen, setProfilePanelOpen] = useState(false)
  const [profilePanelRendered, setProfilePanelRendered] = useState(false)
  const [editingProfile, setEditingProfile] = useState(null)
  const [editingProfileDrug, setEditingProfileDrug] = useState(null)

  // Painel: Farmacologia de fármaco
  const [pharmacologyPanelOpen, setPharmacologyPanelOpen] = useState(false)
  const [pharmacologyPanelRendered, setPharmacologyPanelRendered] = useState(false)
  const [editingPharmacology, setEditingPharmacology] = useState(null)
  const [editingPharmacologyDrug, setEditingPharmacologyDrug] = useState(null)

  const openPanel = (renderedSetter, openSetter) => {
    renderedSetter(true)
    requestAnimationFrame(() => openSetter(true))
  }
  const closePanel = (openSetter, renderedSetter) => {
    openSetter(false)
    setTimeout(() => renderedSetter(false), 250)
  }

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) }
    else { setError(text); setMessage(null) }
  }

  const reload = useCallback(async () => {
    const [ds, ints] = await Promise.all([getAllDrugs(), getAllDrugInteractions()])
    setDrugs(ds)
    setInteractions(ints)
    router.refresh()
  }, [router])

  const run = async (fn, okText) => {
    const res = await fn()
    showMessage(res.success, res.success ? okText : res.error)
    if (res.success) reload()
  }

  const openDrugForm = (drug) => {
    setEditingDrug(drug)
    openPanel(setDrugPanelRendered, setDrugPanelOpen)
  }
  const openInteractionForm = async (interaction) => {
    if (interaction) {
      const detail = await getDrugInteractionDetail(interaction.id)
      if (!detail) { showMessage(false, 'Não foi possível carregar a interação.'); return }
      setEditingInteraction(detail)
    } else {
      setEditingInteraction(null)
    }
    openPanel(setInterPanelRendered, setInterPanelOpen)
  }
  const openProfileForm = async (drug) => {
    const profile = await getDrugProfile(drug.id)
    setEditingProfileDrug(drug)
    setEditingProfile(profile)
    openPanel(setProfilePanelRendered, setProfilePanelOpen)
  }
  const openPharmacologyForm = async (drug) => {
    const pharmacology = await getDrugPharmacology(drug.id)
    setEditingPharmacologyDrug(drug)
    setEditingPharmacology(pharmacology)
    openPanel(setPharmacologyPanelRendered, setPharmacologyPanelOpen)
  }

  const isSuper = currentUserRole === 'superadmin'

  return (
    <div className="admin-interacoes">
      <div className="admin-page-header">
        <h1>Interações Medicamentosas</h1>
        <p className="admin-page-subtitle">Fármacos e pares com interação documentada para a calculadora pública.</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-card" style={{ marginBottom: 24 }}>
        <div className="admin-card-header">
          <h2>Fármacos</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openDrugForm(null)}>Novo fármaco</button>
        </div>
        <div className="admin-card-body">
          {drugs.length === 0 ? (
            <p className="admin-table-empty">Sem fármacos.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr><th>Nome</th><th>Classe</th><th>Slug</th><th>Estado</th><th>Interações</th><th>Perfil</th><th>Farmacologia</th><th>Ordem</th><th>Ações</th></tr>
              </thead>
              <tbody>
                {drugs.map((d) => (
                  <tr key={d.id} className={d.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{d.name_pt} / {d.name_en}</td>
                    <td>{d.class_pt || '—'}</td>
                    <td>{d.slug}</td>
                    <td>{statusBadge(d.is_archived ? 'archived' : d.status)}</td>
                    <td>{d.interactionCount}</td>
                    <td>{d.profileStatus ? statusBadge(d.profileStatus) : <span className="admin-badge">—</span>}</td>
                    <td>{d.pharmacologyStatus ? statusBadge(d.pharmacologyStatus) : <span className="admin-badge">—</span>}</td>
                    <td>{d.sort_order}</td>
                    <td>
                      <div className="admin-table-actions">
                        <button className="admin-btn admin-btn-sm" onClick={() => openProfileForm(d)}>Perfil</button>
                        <button className="admin-btn admin-btn-sm" onClick={() => openPharmacologyForm(d)}>Farmacologia</button>
                        <button className="admin-btn admin-btn-sm" onClick={() => openDrugForm(d)}>Editar</button>
                        {!d.is_archived ? (
                          <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveDrug(d.id), 'Fármaco arquivado.')}>Arquivar</button>
                        ) : (
                          isSuper && (
                            <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreDrug(d.id), 'Fármaco restaurado.')}>Restaurar</button>
                          )
                        )}
                        {isSuper && (
                          <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                            if (window.confirm('Eliminar fármaco? (bloqueado se tiver interações)')) run(() => deleteDrug(d.id), 'Fármaco eliminado.')
                          }}>Eliminar</button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card-header">
          <h2>Interações</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openInteractionForm(null)}>Nova interação</button>
        </div>
        <div className="admin-card-body">
          {interactions.length === 0 ? (
            <p className="admin-table-empty">Sem interações registadas.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr><th>Fármaco A</th><th>Fármaco B</th><th>Severidade</th><th>Estado</th><th>Ações</th></tr>
              </thead>
              <tbody>
                {interactions.map((i) => (
                  <tr key={i.id} className={i.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{i.drugAName}</td>
                    <td>{i.drugBName}</td>
                    <td>
                      <span className={`admin-badge ${i.severity === 'critical' ? 'admin-badge-danger' : i.severity === 'moderate' ? 'admin-badge-warning' : i.severity === 'minor' ? 'admin-badge-warning' : 'admin-badge-success'}`}>
                        {SEVERITY_LABELS[i.severity] || i.severity}
                      </span>
                    </td>
                    <td>{statusBadge(i.is_archived ? 'archived' : i.status)}</td>
                    <td>
                      <div className="admin-table-actions">
                        <button className="admin-btn admin-btn-sm" onClick={() => openInteractionForm(i)}>Editar</button>
                        {!i.is_archived ? (
                          <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveDrugInteraction(i.id), 'Interação arquivada.')}>Arquivar</button>
                        ) : (
                          isSuper && (
                            <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreDrugInteraction(i.id), 'Interação restaurada.')}>Restaurar</button>
                          )
                        )}
                        {isSuper && (
                          <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                            if (window.confirm('Eliminar interação?')) run(() => deleteDrugInteraction(i.id), 'Interação eliminada.')
                          }}>Eliminar</button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {drugPanelRendered && (
        <DrugForm
          drug={editingDrug}
          panelOpen={drugPanelOpen}
          onClose={() => closePanel(setDrugPanelOpen, setDrugPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setDrugPanelOpen, setDrugPanelRendered) }}
        />
      )}

      {interPanelRendered && (
        <DrugInteractionForm
          interaction={editingInteraction}
          drugs={drugs}
          panelOpen={interPanelOpen}
          onClose={() => closePanel(setInterPanelOpen, setInterPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setInterPanelOpen, setInterPanelRendered) }}
        />
      )}

      {profilePanelRendered && (
        <DrugProfileForm
          drug={editingProfileDrug}
          profile={editingProfile}
          panelOpen={profilePanelOpen}
          onClose={() => closePanel(setProfilePanelOpen, setProfilePanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setProfilePanelOpen, setProfilePanelRendered) }}
        />
      )}

      {pharmacologyPanelRendered && (
        <DrugPharmacologyForm
          drug={editingPharmacologyDrug}
          pharmacology={editingPharmacology}
          panelOpen={pharmacologyPanelOpen}
          onClose={() => closePanel(setPharmacologyPanelOpen, setPharmacologyPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setPharmacologyPanelOpen, setPharmacologyPanelRendered) }}
        />
      )}
    </div>
  )
}
