import { redirect } from 'next/navigation'
import Link from 'next/link'
import { Download, KeyRound, ShieldCheck } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { SITE_ORIGIN } from '@/lib/account-urls'

export const dynamic = 'force-dynamic'

export const metadata = {
  title: 'Privacidade e dados',
  robots: { index: false, follow: false },
}

/**
 * Privacidade e dados.
 *
 * Duas coisas que a pessoa tem direito a fazer sozinha: levar os seus dados e
 * apagá-los. O apagar já existe em /perfil/seguranca (é uma Server Action que
 * exige a palavra escrita); o exportar é a rota irmã `exportar`.
 *
 * Nada aqui promete mais do que o código faz: o JSON sai com o perfil, os
 * guardados, as reservas e as inscrições; a conta interna não aparece porque
 * esta área é dos clientes.
 */
export default async function PrivacidadePage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) redirect('/entrar?next=/perfil/privacidade')

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">A minha conta</p>
          <h1 className="conta-title">Privacidade e dados</h1>
          <p className="conta-sub">
            O que a conta guarda, como o levar consigo e como apagá-lo.
          </p>
        </div>
      </header>

      <div className="conta-grid2">
        <div>
          <section className="conta-panel" aria-labelledby="priv-dados">
            <div className="conta-panel-head">
              <h2 id="priv-dados" className="conta-panel-title">
                <ShieldCheck size={14} />
                O que guardamos
              </h2>
            </div>
            <ul className="conta-rows">
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">Conta</span>
                  <span className="conta-row-meta">
                    Nome, e-mail, fotografia, telefone, município, idioma e aparência.
                  </span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">Guardados</span>
                  <span className="conta-row-meta">
                    Medicamentos e farmácias que marcou no Localizador e no site.
                  </span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">Reservas</span>
                  <span className="conta-row-meta">
                    Nome, telemóvel, município, quantidade e estado de cada reserva feita com
                    sessão iniciada.
                  </span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">Inscrições em eventos</span>
                  <span className="conta-row-meta">
                    Os dados que deu no formulário do evento. Ficam ligados à conta pelo e-mail e,
                    desde a última atualização, também pelo identificador da conta.
                  </span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">Estudo</span>
                  <span className="conta-row-meta">
                    Quizzes, turma e competições do perfil de estudante.
                  </span>
                </div>
              </li>
            </ul>
          </section>

          <section className="conta-panel" aria-labelledby="priv-exportar">
            <div className="conta-panel-head">
              <h2 id="priv-exportar" className="conta-panel-title">
                <Download size={14} />
                Levar os meus dados
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                Descarrega um ficheiro JSON com a conta, os guardados, as reservas e as
                inscrições. É legível por humanos e por máquinas — não é um extrato nem um
                comprovativo.
              </p>
              {/* Route Handler de download, não uma página: `Link` faria uma
                  navegação de cliente e o ficheiro nunca chegava a
                  descarregar. */}
              <a
                className="conta-btn conta-btn--primary"
                href="/perfil/privacidade/exportar"
                download
                style={{ width: '100%', marginTop: '0.75rem' }}
              >
                <Download size={15} />
                Descarregar JSON
              </a>
            </div>
          </section>
        </div>

        <aside>
          <section className="conta-panel" aria-labelledby="priv-apagar">
            <div className="conta-panel-head">
              <h2 id="priv-apagar" className="conta-panel-title">
                <KeyRound size={14} />
                Apagar a conta
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                Apagar é definitivo: guardados, anotações e histórico de estudo desaparecem com a
                conta. As reservas ficam na farmácia, sem ligação à sua conta.
              </p>
              <Link
                href="/perfil/seguranca"
                className="conta-btn conta-btn--ghost"
                style={{ width: '100%', marginTop: '0.75rem' }}
              >
                Abrir Segurança
              </Link>
            </div>
          </section>

          <section className="conta-panel" aria-labelledby="priv-politicas">
            <div className="conta-panel-head">
              <h2 id="priv-politicas" className="conta-panel-title">
                Políticas
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                As regras completas — base legal, conservação e contacto — estão no site.
              </p>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.4rem', marginTop: '0.75rem' }}>
                <a
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  href={`${SITE_ORIGIN}/pt/privacidade`}
                >
                  Privacidade
                </a>
                <a
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  href={`${SITE_ORIGIN}/pt/termos`}
                >
                  Termos
                </a>
              </div>
            </div>
          </section>
        </aside>
      </div>
    </main>
  )
}
