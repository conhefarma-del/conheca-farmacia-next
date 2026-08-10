import { FileText, Calendar, Video, Users, FolderOpen, Layers, MessageSquareText } from 'lucide-react'
import Link from 'next/link'

/**
 * StatsGrid — Server Component
 *
 * Grelha de stat cards para o dashboard admin.
 * Usa classes CSS do admin.css existente.
 *
 * Props: { articles, events, lives, users, categories, total, newFeedback }
 */

const stats = [
  { key: 'articles', label: 'Artigos', icon: FileText, color: 'stat-green' },
  { key: 'events', label: 'Eventos', icon: Calendar, color: 'stat-purple' },
  { key: 'lives', label: 'Lives', icon: Video, color: 'stat-blue' },
  { key: 'users', label: 'Admin Users', icon: Users, color: 'stat-orange' },
  { key: 'categories', label: 'Categorias', icon: FolderOpen, color: 'stat-black' },
  { key: 'total', label: 'Total Conteúdos', icon: Layers, color: 'stat-cyan' },
]

function formatNumber(num) {
  return new Intl.NumberFormat('pt-PT').format(num)
}

export default function StatsGrid({ articles = 0, events = 0, lives = 0, users = 0, categories = 0, total = 0, newFeedback = 0 }) {
  const values = { articles, events, lives, users, categories, total }

  return (
    <div className="admin-stats-grid">
      {stats.map(({ key, label, icon: Icon, color }) => (
        <div key={key} className={`admin-stat-card ${color}`}>
          <div className="admin-stat-card-icon">
            <Icon size={24} />
          </div>
          <div>
            <div className="admin-stat-card-value" id={`stat-${key}`}>
              {formatNumber(values[key])}
            </div>
            <div className="admin-stat-card-label">{label}</div>
          </div>
        </div>
      ))}
      {/* Card de feedback — link para /admin/feedback */}
      <Link href="/admin/feedback" className="admin-stat-card stat-pink">
        <div className="admin-stat-card-icon">
          <MessageSquareText size={24} />
        </div>
        <div>
          <div className="admin-stat-card-value">
            {formatNumber(newFeedback)}
          </div>
          <div className="admin-stat-card-label">Feedback</div>
        </div>
      </Link>
    </div>
  )
}
