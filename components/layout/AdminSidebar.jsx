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
  Scale,
  Microscope,
  Mic,
} from 'lucide-react'

export default function AdminSidebar({ lang, user, onLogout }) {
  const pathname = usePathname()
  const [isOpen, setIsOpen] = useState(false)
  // Submenu de Interações (Dimensões): abre por hover (desktop) ou clique na
  // seta, fecha ao sair do grupo ou ao navegar.
  // NOTA: em touch devices (hover: coarse) o mouseenter/mouseleave causa uma
  // race condition com o click da seta — só usar hover se o dispositivo tiver
  // ponteiro fino (rato).
  const [interacoesOpen, setInteracoesOpen] = useState(false)
  const [artigosOpen, setArtigosOpen] = useState(false)
  const [eventosOpen, setEventosOpen] = useState(false)
  const [conteudoLegalOpen, setConteudoLegalOpen] = useState(false)
  const [canHover, setCanHover] = useState(false)
  const { isDark, toggleTheme } = useTheme()

  useEffect(() => {
    setCanHover(window.matchMedia('(hover: hover) and (pointer: fine)').matches)
  }, [])

  const links = [
    { href: `/${lang}/admin/dashboard`, label: 'Dashboard', icon: Home },
    { href: `/${lang}/admin/dashboard`, label: 'Dashboard', icon: Home },
    { href: `/${lang}/admin/lives`, label: 'Lives', icon: Video },
    { href: `/${lang}/admin/guias`, label: 'Guias de Estudo', icon: BookOpen },
    { href: `/${lang}/admin/protocolos`, label: 'Protocolos Clínicos', icon: ClipboardList },
    { href: `/${lang}/admin/newsletter`, label: 'Newsletter', icon: Mail },
    { href: `/${lang}/admin/feedback`, label: 'Feedback', icon: MessageSquareText },
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
          {/* Dashboard */}
          {(() => {
            const href = `/${lang}/admin/dashboard`
            return (
              <Link href={href} className={isActive(href) ? 'active' : ''}>
                <Home size={20} /> Dashboard
              </Link>
            )
          })()}

          {/* Artigos → submenu: Traduções EN, Científicos */}
          {(() => {
            const artigosHref = `/${lang}/admin/artigos`
            const traducoesHref = `/${lang}/admin/traducoes`
            const cientificosHref = `/${lang}/admin/cientificos`
            const artigosActive = isActive(artigosHref)
            const traducoesActive = isActive(traducoesHref)
            const cientificosActive = isActive(cientificosHref)
            return (
              <div
                className={`admin-nav-group${artigosOpen ? ' is-open' : ''}${artigosActive || traducoesActive || cientificosActive ? ' has-active' : ''}`}
                onMouseEnter={canHover ? () => setArtigosOpen(true) : undefined}
                onMouseLeave={canHover ? () => setArtigosOpen(false) : undefined}
              >
                <div className="admin-nav-row">
                  <Link href={artigosHref} className={artigosActive ? 'active' : ''}>
                    <FileText size={20} /> Artigos
                  </Link>
                  <button
                    type="button"
                    className="admin-nav-arrow"
                    onClick={(e) => { e.stopPropagation(); setArtigosOpen((o) => !o) }}
                    aria-expanded={artigosOpen}
                    aria-label="Abrir ou fechar submenu de Artigos"
                    title={artigosOpen ? 'Fechar submenu' : 'Abrir submenu'}
                  >
                    <ChevronDown size={16} className={artigosOpen ? 'is-open' : ''} />
                  </button>
                </div>
                {artigosOpen && (
                  <div className="admin-nav-submenu">
                    <Link href={traducoesHref} className={traducoesActive ? 'active' : ''}>
                      <Languages size={16} /> Traduções EN
                    </Link>
                    <Link href={cientificosHref} className={cientificosActive ? 'active' : ''}>
                      <Microscope size={16} /> Científicos
                    </Link>
                  </div>
                )}
              </div>
            )
          })()}

          {/* Eventos → submenu: Inscritos */}
          {(() => {
            const eventosHref = `/${lang}/admin/eventos`
            const inscritosHref = `/${lang}/admin/inscritos`
            const eventosActive = isActive(eventosHref)
            const inscritosActive = isActive(inscritosHref)
            return (
              <div
                className={`admin-nav-group${eventosOpen ? ' is-open' : ''}${eventosActive || inscritosActive ? ' has-active' : ''}`}
                onMouseEnter={canHover ? () => setEventosOpen(true) : undefined}
                onMouseLeave={canHover ? () => setEventosOpen(false) : undefined}
              >
                <div className="admin-nav-row">
                  <Link href={eventosHref} className={eventosActive ? 'active' : ''}>
                    <Calendar size={20} /> Eventos
                  </Link>
                  <button
                    type="button"
                    className="admin-nav-arrow"
                    onClick={(e) => { e.stopPropagation(); setEventosOpen((o) => !o) }}
                    aria-expanded={eventosOpen}
                    aria-label="Abrir ou fechar submenu de Eventos"
                    title={eventosOpen ? 'Fechar submenu' : 'Abrir submenu'}
                  >
                    <ChevronDown size={16} className={eventosOpen ? 'is-open' : ''} />
                  </button>
                </div>
                {eventosOpen && (
                  <div className="admin-nav-submenu">
                    <Link href={inscritosHref} className={inscritosActive ? 'active' : ''}>
                      <Users size={16} /> Inscritos
                    </Link>
                  </div>
                )}
              </div>
            )
          })()}

          {/* Entrevistas */}
          {(() => {
            const href = `/${lang}/admin/entrevistas`
            return (
              <Link href={href} className={isActive(href) ? 'active' : ''}>
                <Mic size={20} /> Entrevistas
              </Link>
            )
          })()}

          {/* Lives, Guias, Protocolos */}
          {links.slice(1, 4).map((link) => {
            const Icon = link.icon
            return (
              <Link key={link.href} href={link.href} className={isActive(link.href) ? 'active' : ''}>
                <Icon size={20} /> {link.label}
              </Link>
            )
          })}

          {/* Interações → submenu: Dimensões */}
          {(() => {
            const interacoesHref = `/${lang}/admin/interacoes`
            const dimensoesHref = `/${lang}/admin/interacoes/dimensoes`
            const interacoesActive = isActive(interacoesHref)
            const dimensoesActive = isActive(dimensoesHref)
            return (
              <div
                className={`admin-nav-group${interacoesOpen ? ' is-open' : ''}${interacoesActive || dimensoesActive ? ' has-active' : ''}`}
                onMouseEnter={canHover ? () => setInteracoesOpen(true) : undefined}
                onMouseLeave={canHover ? () => setInteracoesOpen(false) : undefined}
              >
                <div className="admin-nav-row">
                  <Link href={interacoesHref} className={interacoesActive ? 'active' : ''}>
                    <Pill size={20} /> Interações
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
                    <Link href={dimensoesHref} className={dimensoesActive ? 'active' : ''}>
                      <Layers size={16} /> Dimensões
                    </Link>
                  </div>
                )}
              </div>
            )
          })()}

          {/* Newsletter, Feedback */}
          {links.slice(4, 6).map((link) => {
            const Icon = link.icon
            return (
              <Link key={link.href} href={link.href} className={isActive(link.href) ? 'active' : ''}>
                <Icon size={20} /> {link.label}
              </Link>
            )
          })}

          {/* Conteúdo Legal → submenu: FAQ, Política de Privacidade */}
          {(() => {
            const faqHref = `/${lang}/admin/conteudo-legal/faq`
            const politicaHref = `/${lang}/admin/conteudo-legal/politica-privacidade`
            const faqActive = isActive(faqHref)
            const politicaActive = isActive(politicaHref)
            return (
              <div
                className={`admin-nav-group${conteudoLegalOpen ? ' is-open' : ''}${faqActive || politicaActive ? ' has-active' : ''}`}
                onMouseEnter={canHover ? () => setConteudoLegalOpen(true) : undefined}
                onMouseLeave={canHover ? () => setConteudoLegalOpen(false) : undefined}
              >
                <div className="admin-nav-row">
                  <Link href={faqHref} className={faqActive || politicaActive ? 'active' : ''}>
                    <Scale size={20} /> Conteúdo Legal
                  </Link>
                  <button
                    type="button"
                    className="admin-nav-arrow"
                    onClick={(e) => { e.stopPropagation(); setConteudoLegalOpen((o) => !o) }}
                    aria-expanded={conteudoLegalOpen}
                    aria-label="Abrir ou fechar submenu de Conteúdo Legal"
                    title={conteudoLegalOpen ? 'Fechar submenu' : 'Abrir submenu'}
                  >
                    <ChevronDown size={16} className={conteudoLegalOpen ? 'is-open' : ''} />
                  </button>
                </div>
                {conteudoLegalOpen && (
                  <div className="admin-nav-submenu">
                    <Link href={faqHref} className={faqActive ? 'active' : ''}>
                      <HelpCircle size={16} /> FAQ
                    </Link>
                    <Link href={politicaHref} className={politicaActive ? 'active' : ''}>
                      <Shield size={16} /> Política de Privacidade
                    </Link>
                  </div>
                )}
              </div>
            )
          })()}

          {/* Definições */}
          {(() => {
            const href = `/${lang}/admin/definicoes`
            return (
              <Link href={href} className={isActive(href) ? 'active' : ''}>
                <Settings size={20} /> Definições
              </Link>
            )
          })()}
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
