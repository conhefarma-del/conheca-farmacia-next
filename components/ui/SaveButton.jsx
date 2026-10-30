'use client'

import { useState, useEffect, useContext } from 'react'
import { useRouter } from 'next/navigation'
import { Bookmark, BookmarkCheck, Pencil, Loader2, Info } from 'lucide-react'
import { toggleSaveItem, estadoItemGuardado, hasNoteForItem } from '@/lib/actions/saved'
import { LangContext } from '@/lib/contexts'

/**
 * SaveButton — bookmark toggle + notes button for any saveable content.
 *
 * Props:
 *   itemType       — 'drug' | 'interaction' | 'drug_class' | 'molecular_target' | 'article'
 *   itemId         — UUID of the item
 *   itemSlug       — slug for quick link
 *   itemName       — display name (denormalized)
 *   itemSubtitle   — optional subtitle
 *   itemImageUrl   — optional thumbnail
 *   lang           — current language
 *   size           — 'sm' (16px) | 'md' (20px) | 'lg' (24px)
 *   className      — extra classes
 *   onNotesClick   — () => void (abre o NotesDrawer)
 *   showNotesBtn   — boolean (mostrar botão de notas)
 */
export default function SaveButton({
  itemType,
  itemId,
  itemSlug,
  itemName,
  itemSubtitle,
  itemImageUrl,
  lang = 'pt',
  size = 'md',
  className = '',
  onNotesClick,
  showNotesBtn = false,
  // Estado já conhecido pela página (listas): evita um pedido por botão.
  estadoInicial = null,
  // A página vai fornecer o estado: até lá mostra-se o carregamento e não se
  // pede nada ao servidor.
  aguardarEstado = false,
}) {
  const { t } = useContext(LangContext)
  const [saved, setSaved] = useState(Boolean(estadoInicial?.saved))
  const [hasNote, setHasNote] = useState(Boolean(estadoInicial?.hasNote))
  const [loading, setLoading] = useState(!estadoInicial && !aguardarEstado)
  const [toggling, setToggling] = useState(false)
  // Sem conta não há botão nenhum: as ações devolvem `auth_required` e
  // clicar só levava a um erro ou a um redirect para a entrada.
  const [semConta, setSemConta] = useState(
    estadoInicial ? estadoInicial.autenticado === false : false,
  )
  const router = useRouter()

  const sizeMap = { sm: 16, md: 20, lg: 24 }
  const iconSize = sizeMap[size] || 20

  // A página que já sabe o estado (lista de cartões) entrega-o por prop.
  // Ajuste durante o render (padrão «You Might Not Need An Effect»): um efeito
  // aqui seria um setState síncrono que provoca um render em cascata.
  const [estadoAplicado, setEstadoAplicado] = useState(null)
  if (estadoInicial !== estadoAplicado) {
    setEstadoAplicado(estadoInicial)
    if (estadoInicial) {
      setSaved(Boolean(estadoInicial.saved))
      setHasNote(Boolean(estadoInicial.hasNote))
      setSemConta(estadoInicial.autenticado === false)
      setLoading(false)
    }
  }

  // Estado inicial: uma só ida ao servidor (sessão + guardado + nota).
  // Eram três em fila, e era isso que fazia o botão demorar a aparecer.
  useEffect(() => {
    if (estadoInicial || aguardarEstado) return undefined
    let cancelled = false
    async function check() {
      try {
        const estado = await estadoItemGuardado(itemType, itemId, showNotesBtn)
        if (cancelled) return
        if (!estado.autenticado) {
          setSemConta(true)
          return
        }
        setSaved(estado.saved)
        setHasNote(estado.hasNote)
      } catch {
        // falha de rede: fica como não guardado
      } finally {
        if (!cancelled) setLoading(false)
      }
    }
    check()
    return () => { cancelled = true }
  }, [itemType, itemId, showNotesBtn, estadoInicial, aguardarEstado])

  const handleSaveClick = async (e) => {
    e.preventDefault()
    e.stopPropagation()

    if (toggling) return

    setToggling(true)
    try {
      const result = await toggleSaveItem({
        itemType,
        itemId,
        itemSlug,
        itemName,
        itemSubtitle,
        itemImageUrl,
      })

      if (result.error === 'auth_required') {
        router.push(`/${lang}/entrar`)
        return
      }

      if (!result.success && result.error && result.error !== 'auth_required') {
        // Antes o erro era engolido e o botão parecia não reagir ao clique.
        console.error('guardar item falhou:', result.error)
      }

      if (result.success) {
        setSaved(result.saved)
        // Se guardou, verificar se tem nota
        if (result.saved) {
          const noteExists = await hasNoteForItem(itemType, itemId)
          setHasNote(noteExists)
        }
      }
    } catch {
      // silently fail
    } finally {
      setToggling(false)
    }
  }

  const handleNotesClick = (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (onNotesClick) onNotesClick()
  }

  // Visitante sem conta: nada disto aparece na página.
  if (semConta) return null

  if (loading) {
    return (
      <span
        className={`inline-flex items-center justify-center ${className}`}
        style={{ width: iconSize + 8, height: iconSize + 8 }}
      >
        <Loader2 size={iconSize - 4} className="animate-spin opacity-30" />
      </span>
    )
  }

  return (
    <div className={`save-button-group ${className}`}>
      {/* Botão Guardar */}
      <button
        type="button"
        onClick={handleSaveClick}
        disabled={toggling}
        className={`save-button ${saved ? 'save-button--saved' : ''}`}
        title={saved ? (t('saved.unsave') || 'Remover dos guardados') : (t('saved.save') || 'Guardar')}
        aria-label={saved ? (t('saved.unsave') || 'Remover dos guardados') : (t('saved.save') || 'Guardar')}
        aria-pressed={saved}
      >
        {toggling ? (
          <Loader2 size={iconSize} className="animate-spin" />
        ) : saved ? (
          <BookmarkCheck size={iconSize} />
        ) : (
          <Bookmark size={iconSize} />
        )}
        <span className="save-button-label">
          {saved ? t('saved.unsave') || 'Remover' : t('saved.save') || 'Guardar'}
        </span>
      </button>

      {/* Botão Notas */}
      {showNotesBtn && (
        <button
          type="button"
          onClick={handleNotesClick}
          className={`save-notes-button ${hasNote ? 'save-notes-button--has-note' : ''}`}
          title={t('notes_drawer.title', { name: itemName })}
          aria-label={t('notes_drawer.title', { name: itemName })}
        >
          <Pencil size={iconSize - 2} />
        </button>
      )}
    </div>
  )
}
