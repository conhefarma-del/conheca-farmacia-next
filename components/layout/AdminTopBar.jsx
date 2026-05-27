'use client'

import { Search } from 'lucide-react'

export default function AdminTopBar({ user }) {
  const initial = user?.name?.charAt(0)?.toUpperCase() || user?.email?.charAt(0)?.toUpperCase() || 'A'

  return (
    <div className="admin-top-bar">
      <div className="admin-search-container">
        <Search size={16} className="admin-search-icon" />
        <input
          id="admin-search-input"
          className="admin-search-input"
          type="text"
          placeholder="Pesquisar artigos, eventos, lives..."
          autoComplete="off"
        />
      </div>
      <div className="admin-top-actions">
        <div className="admin-user-menu">
          <div className="admin-user-avatar">{initial}</div>
          <div className="admin-user-info">
            <span className="admin-user-name">{user?.name || 'Administrador'}</span>
            <span className="admin-user-email">{user?.email || ''}</span>
          </div>
        </div>
      </div>
    </div>
  )
}
