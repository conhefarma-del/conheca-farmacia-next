'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useEffect, useState, useCallback } from 'react'
import { useTheme } from '@/components/providers/ThemeProvider'
import {
  Home,
  FileText,
  Calendar,
  Video,
  Languages,
  Mail,
  Settings,
  Sun,
  Moon,
  LogOut,
  Menu,
  X,
  Users,
  HelpCircle,
  Shield,
  BookOpen,
  ClipboardList,
  Pill,
  MessageSquareText,
  Layers,
  ChevronDown,
} from 'lucide-react'

export default function AdminSidebar({ lang, user, onLogout }) {
  const pathname = usePathname()
  const [isOpen, setIsOpen] = useState(false)
  // Submenu de Interações (Dimensões): abre por hover (desktop) ou clique na
  // seta, fecha ao sair do grupo ou ao navegar.
  const [interacoesOpen, setInteracoesOpen] = useState(false)
  const { isDark, toggleTheme } = useTheme()

  const links = [
    { href: `/${lang}/admin/dashboard`, label: 'Dashboard', icon: Home },
    { href: `/${lang}/admin/artigos`, label: 'Artigos', icon: FileText },
    { href: `/${lang}/admin/eventos`, label: 'Eventos', icon: Calendar },
    { href: `/${lang}/admin/lives`, label: 'Lives', icon: Video },
    { href: `/${lang}/admin/guias`, label: 'Guias de Estudo', icon: BookOpen },
    { href: `/${lang}/admin/protocolos`, label: 'Protocolos Clínicos', icon: ClipboardList },
    { href: `/${lang}/admin/traducoes`, label: 'Traduções EN', icon: Languages },
    { href: `/${lang}/admin/newsletter`, label: 'Newsletter', icon: Mail },
    { href: `/${lang}/admin/feedback`, label: 'Feedback', icon: MessageSquareText },
    { href: `/${lang}/admin/inscritos`, label: 'Inscritos', icon: Users },
    { href: `/${lang}/admin/conteudo-legal/faq`, label: 'FAQ', icon: HelpCircle },
    { href: `/${lang}/admin/conteudo-legal/politica-privacidade`, label: 'Política de Privacidade', icon: Shield },
    { href: `/${lang}/admin/definicoes`, label: 'Definições', icon: Settings },
  ]

  const isActive = (href) => pathname === href || pathname.startsWith(href + '/')

  // Fechar sidebar ao navegar (mobile)
  useEffect(() => {
    setIsOpen(false)
  }, [pathname])

  // Fechar sidebar ao clicar no overlay
  const handleOverlayClick = useCallback(() => {
    setIsOpen(false)
  }, [])

  return (
    <>
      {/* Mobile Hamburger */}
      <button
        className="admin-hamburger"
        id="hamburger-btn"
        aria-label={isOpen ? 'Fechar menu' : 'Abrir menu'}
        onClick={() => setIsOpen(!isOpen)}
        onMouseDown={(e) => { e.preventDefault(); setIsOpen(!isOpen); }}
        style={{
          position: 'fixed',
          top: 16,
          left: 16,
          zIndex: 200,
          background: 'var(--admin-card-bg)',
          border: '1px solid var(--admin-border)',
          borderRadius: 8,
          padding: 8,
          cursor: 'pointer',
          display: 'none',
        }}
      >
        {isOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Mobile Overlay */}
      <div
        className={`admin-sidebar-overlay${isOpen ? ' active' : ''}`}
        id="sidebar-overlay"
        onClick={handleOverlayClick}
      />

      {/* Sidebar */}
      <aside className={`admin-sidebar${isOpen ? ' open' : ''}`}>
        <div className="admin-sidebar-header">
          <div className="admin-sidebar-logo">
            <img
              src="/logo/logo-principal-branco.svg"
              alt="conheceFarma"
            />
            <div>
              <h1>conheceFarma</h1>
              <p className="admin-sidebar-subtitle">Painel Administrativo</p>
            </div>
          </div>
        </div>

        <nav className="admin-nav-vertical">
          {links.slice(0, 6).map((link) => {
            const Icon = link.icon
            return (
              <Link
                key={link.href}
                href={link.href}
                className={isActive(link.href) ? 'active' : ''}
              >
                <Icon size={20} />
                {link.label}
              </Link>
            )
          })}

          {/* Interações com submenu (Dimensões). A seta à direita abre/fecha;
              clicar no resto da opção navega para /admin/interacoes. */}
          {(() => {
            const interacoesHref = `/${lang}/admin/interacoes`
            const dimensoesHref = `/${lang}/admin/interacoes/dimensoes`
            const interacoesActive = isActive(interacoesHref)
            const dimensoesActive = isActive(dimensoesHref)
            return (
              <div
                className={`admin-nav-group${interacoesOpen ? ' is-open' : ''}${interacoesActive || dimensoesActive ? ' has-active' : ''}`}
                onMouseEnter={() => setInteracoesOpen(true)}
                onMouseLeave={() => setInteracoesOpen(false)}
              >
                <div className="admin-nav-row">
                  <Link
                    href={interacoesHref}
                    className={interacoesActive ? 'active' : ''}
                  >
                    <Pill size={20} />
                    Interações
                  </Link>
                  <button
                    type="button"
                    className="admin-nav-arrow"
                    onClick={(e) => { e.stopPropagation(); setInteracoesOpen((o) => !o) }}
                    aria-expanded={interacoesOpen}
                    aria-label="Abrir ou fechar submenu de Interações"
                    title={interacoesOpen ? 'Fechar submenu' : 'Abrir submenu'}
                  >
                    <ChevronDown size={16} className={interacoesOpen ? 'is-open' : ''} />
                  </button>
                </div>
                {interacoesOpen && (
                  <div className="admin-nav-submenu">
                    <Link
                      href={dimensoesHref}
                      className={dimensoesActive ? 'active' : ''}
                    >
                      <Layers size={16} />
                      Dimensões
                    </Link>
                  </div>
                )}
              </div>
            )
          })()}

          {links.slice(6).map((link) => {
            const Icon = link.icon
            return (
              <Link
                key={link.href}
                href={link.href}
                className={isActive(link.href) ? 'active' : ''}
              >
                <Icon size={20} />
                {link.label}
              </Link>
            )
          })}
        </nav>

        <div className="admin-sidebar-footer">
          <button
            className="admin-sidebar-btn"
            onClick={toggleTheme}
            onMouseDown={(e) => e.preventDefault()}
            aria-label="Toggle dark mode"
            title={isDark ? 'Modo claro' : 'Modo escuro'}
          >
            <Sun size={20} className="sun-icon" style={{ display: isDark ? 'none' : 'block' }} />
            <Moon size={20} className="moon-icon" style={{ display: isDark ? 'block' : 'none' }} />
          </button>

          <button
            className="admin-sidebar-btn"
            onClick={onLogout}
            onMouseDown={(e) => { e.preventDefault(); onLogout(); }}
            aria-label="Sair"
            title="Terminar sessão"
          >
            <LogOut size={20} />
          </button>
        </div>
      </aside>

      {/* Mobile hamburger visibility override */}
      <style>{`
        @media (max-width: 768px) {
          .admin-hamburger {
            display: flex !important;
          }
        }
      `}</style>
    </>
  )
}
