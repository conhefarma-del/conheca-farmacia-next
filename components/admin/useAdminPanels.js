'use client'

import { useCallback, useState } from 'react'
import { useRouter } from 'next/navigation'
import {
  getAllDrugInteractions,
  getAllDrugs,
  getDrugInteractionDetail,
} from '@/lib/actions/interacoes'
import { getDrugPharmacology, getDrugProfile } from '@/lib/actions/medicamentos'

/**
 * useAdminPanels — estado partilhado dos painéis de gestão de fármacos e
 * interações (usado na página principal e nas páginas dedicadas).
 */
export default function useAdminPanels(initialDrugs, initialInteractions) {
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

  const showMessage = useCallback((ok, text) => {
    if (ok) { setMessage(text); setError(null) }
    else { setError(text); setMessage(null) }
  }, [])

  const reload = useCallback(async () => {
    const [ds, ints] = await Promise.all([getAllDrugs(), getAllDrugInteractions()])
    setDrugs(ds)
    setInteractions(ints)
    router.refresh()
  }, [router])

  const run = useCallback(async (fn, okText) => {
    const res = await fn()
    showMessage(res.success, res.success ? okText : res.error)
    if (res.success) reload()
  }, [reload, showMessage])

  const openDrugForm = useCallback((drug) => {
    setEditingDrug(drug)
    openPanel(setDrugPanelRendered, setDrugPanelOpen)
  }, [])

  const openInteractionForm = useCallback(async (interaction) => {
    if (interaction) {
      const detail = await getDrugInteractionDetail(interaction.id)
      if (!detail) { showMessage(false, 'Não foi possível carregar a interação.'); return }
      setEditingInteraction(detail)
    } else {
      setEditingInteraction(null)
    }
    openPanel(setInterPanelRendered, setInterPanelOpen)
  }, [showMessage])

  const openProfileForm = useCallback(async (drug) => {
    const profile = await getDrugProfile(drug.id)
    setEditingProfileDrug(drug)
    setEditingProfile(profile)
    openPanel(setProfilePanelRendered, setProfilePanelOpen)
  }, [])

  const openPharmacologyForm = useCallback(async (drug) => {
    const pharmacology = await getDrugPharmacology(drug.id)
    setEditingPharmacologyDrug(drug)
    setEditingPharmacology(pharmacology)
    openPanel(setPharmacologyPanelRendered, setPharmacologyPanelOpen)
  }, [])

  return {
    drugs,
    interactions,
    message,
    error,
    showMessage,
    reload,
    run,
    // Fármaco
    drugPanelOpen,
    drugPanelRendered,
    editingDrug,
    openDrugForm,
    closeDrugPanel: () => closePanel(setDrugPanelOpen, setDrugPanelRendered),
    // Interação
    interPanelOpen,
    interPanelRendered,
    editingInteraction,
    openInteractionForm,
    closeInterPanel: () => closePanel(setInterPanelOpen, setInterPanelRendered),
    // Perfil
    profilePanelOpen,
    profilePanelRendered,
    editingProfile,
    editingProfileDrug,
    openProfileForm,
    closeProfilePanel: () => closePanel(setProfilePanelOpen, setProfilePanelRendered),
    // Farmacologia
    pharmacologyPanelOpen,
    pharmacologyPanelRendered,
    editingPharmacology,
    editingPharmacologyDrug,
    openPharmacologyForm,
    closePharmacologyPanel: () => closePanel(setPharmacologyPanelOpen, setPharmacologyPanelRendered),
  }
}
