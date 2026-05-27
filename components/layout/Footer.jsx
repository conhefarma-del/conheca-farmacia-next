'use client'

import { useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'

export default function Footer({ lang }) {
  const { t } = useContext(LangContext)

  return (
    <footer className="footer">
      <div className="container-center">
        <div className="footer-grid">
          {/* Brand Info */}
          <div className="footer-logo">
            <img src="/logo/logo-principal-branco.svg" alt="Conheça Farmácia" />
            <p className="text-white/70 text-sm mt-4 max-w-xs">
              {t('footer.descricao')}
            </p>
          </div>

          {/* Quick Links */}
          <div className="footer-links">
            <h4>{t('footer.navegacao')}</h4>
            <ul>
              <li><Link href={`/${lang}`}>{t('nav.inicio')}</Link></li>
              <li><Link href={`/${lang}/artigos`}>{t('nav.artigos')}</Link></li>
              <li><Link href={`/${lang}/eventos`}>{t('nav.eventos')}</Link></li>
              <li><Link href={`/${lang}/lives`}>{t('nav.lives')}</Link></li>
              <li><Link href={`/${lang}/sobre`}>{t('nav.sobre')}</Link></li>
            </ul>
          </div>

          {/* Contact */}
          <div className="footer-links">
            <h4>{t('footer.contacto')}</h4>
            <ul className="text-sm text-white/70">
              <li>{t('footer.localizacao')}</li>
              <li>
                <a href="mailto:conhecerfarmacia@gmail.com" className="text-white/70 hover:text-brand-accent">
                  conhecerfarmacia@gmail.com
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
