'use client'

import { useCallback, useState } from 'react'
import { useRouter } from 'next/navigation'
import {
  archiveProtocol, archiveProtocolCategory, createProtocolCategory, deleteProtocol,
  deleteProtocolCategory, getAllProtocolCategories, getAllClinicalProtocols, getProtocolDetail,
  restoreProtocol, restoreProtocolCategory, updateProtocolCategory,
} from '@/lib/actions/protocolos'
import ProtocolCategoryForm from './ProtocolCategoryForm'
import ProtocolForm from './ProtocolForm'
import ProtocolContentForm from './ProtocolContentForm'

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">Arquivado</span>
}

export default function ProtocolsAdminPage({ lang, initialCategories, initialProtocols, currentUserRole }) {
  const router = useRouter()
  const [categories, setCategories] = useState(initialCategories)
  const [protocols, setProtocols] = useState(initialProtocols)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)

  // Painel: Categoria
  const [catPanelOpen, setCatPanelOpen] = useState(false)
  const [catPanelRendered, setCatPanelRendered] = useState(false)
  const [editingCategory, setEditingCategory] = useState(null)

  // Painel: Protocolo (base)
  const [protoPanelOpen, setProtoPanelOpen] = useState(false)
  const [protoPanelRendered, setProtoPanelRendered] = useState(false)
  const [editingProtocol, setEditingProtocol] = useState(null)

  // Painel: Conteúdo (passos + referências + quiz)
  const [contentPanelOpen, setContentPanelOpen] = useState(false)
  const [contentPanelRendered, setContentPanelRendered] = useState(false)
  const [contentProtocolId, setContentProtocolId] = useState(null)
  const [contentProtocolTitle, setContentProtocolTitle] = useState('')
  const [contentDetail, setContentDetail] = useState(null)

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
    const [cats, protos] = await Promise.all([getAllProtocolCategories(), getAllClinicalProtocols()])
    setCategories(cats)
    setProtocols(protos)
    router.refresh()
  }, [router])

  const run = async (fn, okText) => {
    const res = await fn()
    showMessage(res.success, res.success ? okText : res.error)
    if (res.success) reload()
  }

  const openCategoryForm = (cat) => {
    setEditingCategory(cat)
    openPanel(setCatPanelRendered, setCatPanelOpen)
  }
  const openProtocolForm = (proto) => {
    setEditingProtocol(proto)
    openPanel(setProtoPanelRendered, setProtoPanelOpen)
  }
  const openContent = async (proto) => {
    const detail = await getProtocolDetail(proto.id)
    if (!detail) { showMessage(false, 'Não foi possível carregar o conteúdo.'); return }
    setContentProtocolId(detail.id)
    setContentProtocolTitle(detail.title_pt)
    setContentDetail(detail)
    openPanel(setContentPanelRendered, setContentPanelOpen)
  }

  const isSuper = currentUserRole === 'superadmin'

  return (
    <div className="admin-protocols">
      <div className="admin-page-header">
        <h1>Protocolos Clínicos</h1>
        <p className="admin-page-subtitle">Categorias, protocolos e conteúdo (passos, referências e quiz).</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-card" style={{ marginBottom: 24 }}>
        <div className="admin-card-header">
          <h2>Categorias</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openCategoryForm(null)}>Nova categoria</button>
        </div>
        <div className="admin-card-body">
          {categories.length === 0 ? (
            <p className="admin-table-empty">Sem categorias.</p>
          ) : (
            <div className="admin-table-wrapper">
          <table className="admin-table">
              <thead>
                <tr><th>Nome</th><th>Slug</th><th>Cor</th><th>Estado</th><th>Protocolos</th><th>Ações</th></tr>
              </thead>
              <tbody>
                {categories.map((c) => (
                  <tr key={c.id} className={c.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{c.name_pt} / {c.name_en}</td>
                    <td>{c.slug}</td>
                    <td><span style={{ display: 'inline-block', width: 18, height: 18, borderRadius: 4, background: c.color }} /></td>
                    <td>{statusBadge(c.is_archived ? 'archived' : c.status)}</td>
                    <td>{c.protocolCount}</td>
                    <td>
                      <div className="admin-table-actions">
                        <button className="admin-btn admin-btn-sm" onClick={() => openCategoryForm(c)}>Editar</button>
                        {!c.is_archived ? (
                          <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveProtocolCategory(c.id), 'Categoria arquivada.')}>Arquivar</button>
                        ) : (
                          isSuper && (
                            <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreProtocolCategory(c.id), 'Categoria restaurada.')}>Restaurar</button>
                          )
                        )}
                        {isSuper && (
                          <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                            if (window.confirm('Eliminar categoria? (bloqueado se tiver protocolos)')) run(() => deleteProtocolCategory(c.id), 'Categoria eliminada.')
                          }}>Eliminar</button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          )}
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card-header">
          <h2>Protocolos</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openProtocolForm(null)}>Novo protocolo</button>
        </div>
        <div className="admin-card-body">
          {protocols.length === 0 ? (
            <p className="admin-table-empty">Sem protocolos.</p>
          ) : (
            <div className="admin-table-wrapper">
          <table className="admin-table">
              <thead>
                <tr><th>Título</th><th>Categoria</th><th>Estado</th><th>Passos</th><th>Ordem</th><th>Ações</th></tr>
              </thead>
              <tbody>
                {protocols.map((p) => (
                  <tr key={p.id} className={p.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{p.title_pt} / {p.title_en}</td>
                    <td>{p.categoryName}</td>
                    <td>{statusBadge(p.is_archived ? 'archived' : p.status)}</td>
                    <td>{p.stepCount}</td>
                    <td>{p.sort_order}</td>
                    <td>
                      <div className="admin-table-actions">
                        <button className="admin-btn admin-btn-sm" onClick={() => openProtocolForm(p)}>Editar</button>
                        <button className="admin-btn admin-btn-sm" onClick={() => openContent(p)}>Gerir conteúdo</button>
                        {!p.is_archived ? (
                          <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveProtocol(p.id), 'Protocolo arquivado.')}>Arquivar</button>
                        ) : (
                          isSuper && (
                            <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreProtocol(p.id), 'Protocolo restaurado.')}>Restaurar</button>
                          )
                        )}
                        {isSuper && (
                          <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                            if (window.confirm('Eliminar protocolo? (elimina passos, referências e quiz)')) run(() => deleteProtocol(p.id), 'Protocolo eliminado.')
                          }}>Eliminar</button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          )}
        </div>
      </div>

      {catPanelRendered && (
        <ProtocolCategoryForm
          category={editingCategory}
          panelOpen={catPanelOpen}
          onClose={() => closePanel(setCatPanelOpen, setCatPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setCatPanelOpen, setCatPanelRendered) }}
        />
      )}

      {protoPanelRendered && (
        <ProtocolForm
          protocol={editingProtocol}
          categories={categories}
          panelOpen={protoPanelOpen}
          onClose={() => closePanel(setProtoPanelOpen, setProtoPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setProtoPanelOpen, setProtoPanelRendered) }}
        />
      )}

      {contentPanelRendered && (
        <ProtocolContentForm
          protocolId={contentProtocolId}
          protocolTitle={contentProtocolTitle}
          initialContent={contentDetail}
          panelOpen={contentPanelOpen}
          onClose={() => closePanel(setContentPanelOpen, setContentPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setContentPanelOpen, setContentPanelRendered) }}
        />
      )}
    </div>
  )
}
