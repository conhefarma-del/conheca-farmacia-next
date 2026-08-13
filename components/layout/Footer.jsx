'use client'

import { useContext } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { LangContext } from '@/lib/contexts'
import { getSectionHref } from '@/lib/i18n-routes'

export default function Footer({ lang }) {
  const { t } = useContext(LangContext)

  return (
    <footer className="footer">
      <div className="container-center">
        <div className="footer-grid">
          {/* Brand Info */}
          <div className="footer-logo">
            <Image src="/logo/logo-principal-branco.png" alt="Conheça Farmácia" width={120} height={40} />
            <p className="text-white/70 text-sm mt-4 max-w-xs">
              {t('footer.descricao')}
            </p>
          </div>

          {/* Quick Links */}
          <div className="footer-links">
            <h4>{t('footer.navegacao')}</h4>
            <ul>
              <li><Link href={`/${lang}`}>{t('nav.inicio')}</Link></li>
              <li><Link href={getSectionHref(lang, 'artigos')}>{t('nav.artigos')}</Link></li>
              <li><Link href={getSectionHref(lang, 'eventos')}>{t('nav.eventos')}</Link></li>
              <li><Link href={getSectionHref(lang, 'lives')}>{t('nav.lives')}</Link></li>
              <li><Link href={getSectionHref(lang, 'sobre')}>{t('nav.sobre')}</Link></li>
              <li><Link href={getSectionHref(lang, 'faq')}>{t('footer.faq')}</Link></li>
              <li><Link href={getSectionHref(lang, 'politica-privacidade')}>{t('footer.privacidade')}</Link></li>
            </ul>
          </div>

          {/* Ferramentas */}
          <div className="footer-links">
            <h4>{t('nav.ferramentas')}</h4>
            <ul>
              <li><Link href={getSectionHref(lang, 'praticar')}>{t('nav.praticar')}</Link></li>
              <li><Link href={getSectionHref(lang, 'medicamentos')}>{t('nav.medicamentos')}</Link></li>
              <li><Link href={getSectionHref(lang, 'cientificos')}>{t('nav.cientificos')}</Link></li>
              <li><Link href={getSectionHref(lang, 'guias')}>{t('footer.guias')}</Link></li>
              <li><Link href={getSectionHref(lang, 'protocolos')}>{t('footer.protocolos')}</Link></li>
              <li><Link href={getSectionHref(lang, 'interacoes')}>{t('footer.interacoes')}</Link></li>
            </ul>
          </div>

          {/* Contact */}
          <div className="footer-links">
            <h4>{t('footer.contacto')}</h4>
            <ul className="text-sm text-white/70">
              <li>{t('footer.localizacao')}</li>
              <li>
                <a href="mailto:conhecerfarmacia@gmail.com" className="text-white/70 hover:text-brand-accent">
                  geral@conhecafarmacia.com
                </a>
              </li>
              <li>
                <a
                  href="https://wa.me/244925696002?text=Olá,%20Conheça%20Farmácia"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-white/70 hover:text-brand-accent"
                >
                  +244 925 696 002
                </a>
              </li>
            </ul>
          </div>

          {/* Social Media */}
          <div className="footer-links">
            <h4>{t('footer.redes_sociais')}</h4>
            <ul className="text-sm">
              <li>
                <a href="https://www.facebook.com/conhecafarmacia" target="_blank" rel="noopener noreferrer">
                  Facebook
                </a>
              </li>
              <li>
                <a href="https://www.instagram.com/conhecafarmacia" target="_blank" rel="noopener noreferrer">
                  Instagram
                </a>
              </li>
              <li>
                <a href="https://www.tiktok.com/conhecafarmaciaofficial" target="_blank" rel="noopener noreferrer">
                  TikTok
                </a>
              </li>
              <li>
                <a href="https://www.linkedin.com/company/conhecafarmacia" target="_blank" rel="noopener noreferrer">
                  LinkedIn
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="footer-divider"></div>

        <div className="footer-bottom">
          <p>{t('footer.direitos')}</p>
        </div>

        {/* Admin Access (discreet) */}
        <div className="footer-admin-access">
          <Link href={`/${lang}/admin`} className="footer-admin-btn" aria-label="Acesso administrativo">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect width="18" height="11" x="3" y="11" rx="2" ry="2" />
              <path d="M7 11V7a5 5 0 0 1 10 0v4" />
            </svg>
          </Link>
        </div>
      </div>
    </footer>
  )
}
