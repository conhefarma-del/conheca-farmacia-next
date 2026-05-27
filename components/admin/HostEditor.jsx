'use client'

import { useCallback } from 'react'
import { Plus, Trash2 } from 'lucide-react'

/**
 * HostEditor — Client Component
 *
 * Editor dinâmico para hosts/speakers (eventos).
 * Linhas com 3 inputs (nome, cargo, organização) + remover.
 *
 * Props:
 *   - hosts: Array<{ name, role, organization }>
 *   - onChange: (hosts) => void
 */

const EMPTY_HOST = { name: '', role: '', organization: '' }

export default function HostEditor({ hosts = [], onChange }) {
  const handleAdd = useCallback(() => {
    onChange?.([...hosts, { ...EMPTY_HOST }])
  }, [hosts, onChange])

  const handleRemove = useCallback((index) => {
    const next = hosts.filter((_, i) => i !== index)
    onChange?.(next)
  }, [hosts, onChange])

  const handleChange = useCallback((index, field, value) => {
    const next = hosts.map((h, i) =>
      i === index ? { ...h, [field]: value } : h
    )
    onChange?.(next)
  }, [hosts, onChange])

  return (
    <div className="admin-form-group">
      <label>Anfitriões / Speakers</label>
      <div id="hosts-container">
        {hosts.map((host, i) => (
          <div key={i} className="admin-host-row" style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
            <input
              type="text"
              value={host.name}
              onChange={(e) => handleChange(i, 'name', e.target.value)}
              className="admin-input"
              placeholder="Nome"
              style={{ flex: '0 0 30%' }}
            />
            <input
              type="text"
              value={host.role}
              onChange={(e) => handleChange(i, 'role', e.target.value)}
              className="admin-input"
              placeholder="Cargo"
              style={{ flex: '0 0 30%' }}
            />
            <input
              type="text"
              value={host.organization}
              onChange={(e) => handleChange(i, 'organization', e.target.value)}
              className="admin-input"
              placeholder="Organização"
              style={{ flex: '0 0 30%' }}
            />
            <button
              type="button"
              className="admin-btn admin-btn-sm admin-btn-danger"
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
        <Plus size={14} /> Adicionar Anfitrião
      </button>
    </div>
  )
}
