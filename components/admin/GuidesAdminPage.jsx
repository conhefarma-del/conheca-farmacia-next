'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Edit3, Trash2, RotateCcw, FolderOpen, CheckCircle, XCircle } from 'lucide-react'
import {
  getAllGuideCourses,
  getGuideCourseDetail,
  createGuideCourse,
  updateGuideCourse,
  archiveGuideCourse,
  restoreGuideCourse,
  deleteGuideCourse,
  deleteGuideDiscipline,
} from '@/lib/actions/guides'
import GuideCursoForm from './GuideCursoForm'
import GuideDisciplinaForm from './GuideDisciplinaForm'

/**
 * Gestão hierárquica dos Guias de Estudo:
 * Cursos → Disciplinas → Livros/Recursos.
 * Cursos usam archive/restore; disciplinas/livros/recursos usam delete (CASCADE).
 */
export default function GuidesAdminPage({ lang, initialCourses, currentUserRole }) {
  const router = useRouter()
  const [courses, setCourses] = useState(initialCourses || [])
  const [selectedCourse, setSelectedCourse] = useState(null)
  const [loadingDetail, setLoadingDetail] = useState(false)
  const [message, setMessage] = useState(null)

  // Course slide panel
  const [coursePanelOpen, setCoursePanelOpen] = useState(false)
  const [coursePanelRendered, setCoursePanelRendered] = useState(false)
  const [editingCourse, setEditingCourse] = useState(null)

  // Discipline slide panel
  const [discPanelOpen, setDiscPanelOpen] = useState(false)
  const [discPanelRendered, setDiscPanelRendered] = useState(false)
  const [editingDiscipline, setEditingDiscipline] = useState(null)

  const reloadCourses = useCallback(async () => {
    const list = await getAllGuideCourses()
    setCourses(list)
  }, [])

  const selectCourse = useCallback(async (course) => {
    setLoadingDetail(true)
    const detail = await getGuideCourseDetail(course.id)
    setSelectedCourse(detail)
    setLoadingDetail(false)
  }, [])

  // --- Course panel open/close ---
  const openCoursePanel = useCallback((course = null) => {
    setEditingCourse(course)
    setCoursePanelRendered(true)
    requestAnimationFrame(() => setCoursePanelOpen(true))
  }, [])

  const closeCoursePanel = useCallback(() => {
    setCoursePanelOpen(false)
    setTimeout(() => {
      setCoursePanelRendered(false)
      setEditingCourse(null)
    }, 250)
  }, [])

  // --- Discipline panel open/close ---
  const openDiscPanel = useCallback((discipline = null) => {
    setEditingDiscipline(discipline)
    setDiscPanelRendered(true)
    requestAnimationFrame(() => setDiscPanelOpen(true))
  }, [])

  const closeDiscPanel = useCallback(() => {
    setDiscPanelOpen(false)
    setTimeout(() => {
      setDiscPanelRendered(false)
      setEditingDiscipline(null)
    }, 250)
  }, [])

  // --- Course actions ---
  const handleCourseSaved = useCallback(async (result) => {
    if (result?.success) {
      setMessage(editingCourse ? 'Curso atualizado com sucesso!' : 'Curso criado com sucesso!')
      closeCoursePanel()
      await reloadCourses()
      router.refresh()
    }
  }, [editingCourse, closeCoursePanel, reloadCourses, router])

  const handleArchiveCourse = useCallback(async (course) => {
    const result = await archiveGuideCourse(course.id)
    setMessage(result.success ? `Curso "${course.name_pt}" arquivado.` : `Erro: ${result.error}`)
    await reloadCourses()
  }, [reloadCourses])

  const handleRestoreCourse = useCallback(async (course) => {
    const result = await restoreGuideCourse(course.id)
    setMessage(result.success ? `Curso "${course.name_pt}" restaurado.` : `Erro: ${result.error}`)
    await reloadCourses()
  }, [reloadCourses])

  const handleDeleteCourse = useCallback(async (course) => {
    if (!window.confirm(`Eliminar o curso "${course.name_pt}" e todas as suas disciplinas, livros e recursos? Esta ação é definitiva.`)) return
    const result = await deleteGuideCourse(course.id)
    setMessage(result.success ? `Curso "${course.name_pt}" eliminado.` : `Erro: ${result.error}`)
    if (selectedCourse?.id === course.id) setSelectedCourse(null)
    await reloadCourses()
  }, [selectedCourse, reloadCourses])

  // --- Discipline actions ---
  const handleDiscSaved = useCallback(async (result) => {
    if (result?.success) {
      setMessage(editingDiscipline ? 'Disciplina atualizada com sucesso!' : 'Disciplina criada com sucesso!')
      closeDiscPanel()
      if (selectedCourse) await selectCourse(selectedCourse)
      await reloadCourses()
    }
  }, [editingDiscipline, closeDiscPanel, selectedCourse, selectCourse, reloadCourses])

  const handleDeleteDiscipline = useCallback(async (discipline) => {
    if (!window.confirm(`Eliminar a disciplina "${discipline.name_pt}" e os seus livros/recursos? Esta ação é definitiva.`)) return
    const result = await deleteGuideDiscipline(discipline.id)
    setMessage(result.success ? `Disciplina "${discipline.name_pt}" eliminada.` : `Erro: ${result.error}`)
    if (selectedCourse) await selectCourse(selectedCourse)
    await reloadCourses()
  }, [selectedCourse, selectCourse, reloadCourses])

  const statusBadge = (status, isArchived) => {
    if (isArchived) return <span className="admin-badge">Arquivado</span>
    return status === 'published'
      ? <span className="admin-badge admin-badge-success">Publicado</span>
      : <span className="admin-badge admin-badge-warning">Rascunho</span>
  }

  return (
    <div className="admin-guides">
      <div className="admin-page-header">
        <h1>Gerir Guias de Estudo</h1>
        <p className="admin-page-subtitle">Cursos de saúde com disciplinas, livros essenciais e recursos gratuitos.</p>
      </div>

      {message && (
        <div className={`admin-message ${message.startsWith('Erro') ? 'admin-error-message' : 'admin-success-message'}`}>
          {message}
          <button onClick={() => setMessage(null)} style={{ marginLeft: 12, background: 'none', border: 'none', cursor: 'pointer' }}>×</button>
        </div>
      )}

      {/* ===== Cursos ===== */}
      <div className="admin-card" style={{ marginBottom: 24 }}>
        <div className="admin-card-header">
          <h2>Cursos</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openCoursePanel()}>
            <Plus size={16} /> Novo Curso
          </button>
        </div>
        <div className="admin-card-body">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Nome</th>
                <th>Slug</th>
                <th>Estado</th>
                <th>Disciplinas</th>
                <th>Ordem</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {courses.length === 0 ? (
                <tr><td colSpan={6} className="admin-table-empty">Nenhum curso encontrado.</td></tr>
              ) : courses.map((course) => (
                <tr key={course.id} className={course.is_archived ? 'admin-table-row-archived' : ''}>
                  <td>{course.icon_emoji} {course.name_pt}</td>
                  <td>{course.slug}</td>
                  <td>{statusBadge(course.status, course.is_archived)}</td>
                  <td>{course.disciplineCount}</td>
                  <td>{course.sort_order}</td>
                  <td>
                    <div className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => openCoursePanel(course)} title="Editar curso">
                        <Edit3 size={14} /> Editar
                      </button>
                      <button
                        className="admin-btn admin-btn-sm"
                        onClick={() => selectCourse(course)}
                        title="Gerir disciplinas"
                      >
                        <FolderOpen size={14} /> Gerir
                      </button>
                      {currentUserRole === 'superadmin' && course.is_archived && (
                        <button className="admin-btn admin-btn-sm" onClick={() => handleRestoreCourse(course)} title="Restaurar">
                          <RotateCcw size={14} /> Restaurar
                        </button>
                      )}
                      {!course.is_archived && (
                        <>
                          <button className="admin-btn admin-btn-sm" onClick={() => handleArchiveCourse(course)} title="Arquivar">
                            <Trash2 size={14} /> Arquivar
                          </button>
                          {currentUserRole === 'superadmin' && (
                            <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => handleDeleteCourse(course)} title="Eliminar definitivamente">
                              <XCircle size={14} /> Eliminar
                            </button>
                          )}
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* ===== Disciplinas do curso selecionado ===== */}
      <div className="admin-card">
        <div className="admin-card-header">
          <h2>Disciplinas {selectedCourse ? `— ${selectedCourse.name_pt}` : ''}</h2>
          {selectedCourse && (
            <button className="admin-btn admin-btn-primary" onClick={() => openDiscPanel()}>
              <Plus size={16} /> Nova Disciplina
            </button>
          )}
        </div>
        <div className="admin-card-body">
          {!selectedCourse ? (
            <p className="admin-table-empty">Selecione um curso (botão "Gerir") para gerir as suas disciplinas.</p>
          ) : loadingDetail ? (
            <p className="admin-table-empty">A carregar disciplinas...</p>
          ) : selectedCourse.disciplines.length === 0 ? (
            <p className="admin-table-empty">Nenhuma disciplina neste curso.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Nome</th>
                  <th>Slug</th>
                  <th>Fase</th>
                  <th>Estado</th>
                  <th>Livros</th>
                  <th>Recursos</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {selectedCourse.disciplines.map((d) => (
                  <tr key={d.id}>
                    <td>{d.name_pt}</td>
                    <td>{d.slug}</td>
                    <td>{d.phase_pt || '-'}</td>
                    <td>{statusBadge(d.status, d.is_archived)}</td>
                    <td>{(d.guide_books || []).length}</td>
                    <td>{(d.guide_resources || []).length}</td>
                    <td>
                      <div className="admin-table-actions">
                        <button className="admin-btn admin-btn-sm" onClick={() => openDiscPanel(d)} title="Editar disciplina">
                          <Edit3 size={14} /> Editar
                        </button>
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => handleDeleteDiscipline(d)} title="Eliminar disciplina">
                          <XCircle size={14} /> Eliminar
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {/* ===== Slide panels ===== */}
      {coursePanelRendered && (
        <GuideCursoForm
          course={editingCourse}
          panelOpen={coursePanelOpen}
          onClose={closeCoursePanel}
          onSaved={handleCourseSaved}
        />
      )}

      {discPanelRendered && selectedCourse && (
        <GuideDisciplinaForm
          courseId={selectedCourse.id}
          discipline={editingDiscipline}
          panelOpen={discPanelOpen}
          onClose={closeDiscPanel}
          onSaved={handleDiscSaved}
        />
      )}
    </div>
  )
}
