'use client'

import { useCallback } from 'react'
import { Plus, Trash2 } from 'lucide-react'

/**
 * ReferenceEditor — Client Component
 *
 * Editor dinâmico para referências (artigos).
 * Linhas com input + remover.
 *
 * Props:
 *   - references: Array<string>
 *   - onChange: (references) => void
 */

export default function ReferenceEditor({ references = [], onChange }) {
  const handleAdd = useCallback(() => {
    onChange?.([...references, ''])
  }, [references, onChange])

  const handleRemove = useCallback((index) => {
    const next = references.filter((_, i) => i !== index)
    onChange?.(next)
  }, [references, onChange])

  const handleChange = useCallback((index, value) => {
    const next = references.map((r, i) => (i === index ? value : r))
    onChange?.(next)
  }, [references, onChange])

  return (
    <div className="admin-form-group">
      <label>Referências</label>
      <div id="references-container">
        {references.map((ref, i) => (
          <div key={i} className="admin-reference-row" style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
            <input
              type="text"
              value={ref}
              onChange={(e) => handleChange(i, e.target.value)}
              className="admin-input reference-input"
              placeholder="URL ou texto da referência"
              style={{ flex: 1 }}
            />
            <button
              type="button"
              className="admin-btn admin-btn-sm admin-btn-danger remove-ref-btn"
              onClick={() => handleRemove(i)}
            >
              <Trash2 size={14} />
            </button>
          </div>
        ))}
      </div>
      <button
        type="button"
        className="admin-btn admin-btn-sm"
        onClick={handleAdd}
      >
        <Plus size={14} /> Adicionar Referência
      </button>
    </div>
  )
}
