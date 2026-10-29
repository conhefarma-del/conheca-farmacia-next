'use client'

import { useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { deleteMyAccount } from '@/lib/actions/account'
import { KeyRound, Loader2, LogOut, ShieldAlert, Trash2 } from 'lucide-react'

/**
 * Segurança da conta (conta.conhecafarmacia.com/perfil/seguranca).
 *
 * Três decisões que valem a pena justificar:
 *
 *   1. A palavra-passe muda com `updateUser`, no browser, como em todo o site;
 *      o servidor valida a sessão na mesma (a cookie é do Supabase).
 *   2. «Terminar sessão em todos os dispositivos» usa `signOut({ scope: 'global' })`
 *      — é o caminho suportado para cortar sessões emitidas noutros aparelhos.
 *   3. Apagar a conta é uma Server Action (`lib/actions/account.js`): o cliente
 *      não tem — nem deve ter — a chave de serviço. A confirmação escrita é
 *      exigida dos dois lados; a UI não é a autoridade.
 *
 * A apresentação segue o chassi `.conta-*`: painéis hairline e formulários
 * com campos de raio pequeno. Nada de cartões centrados de 16px.
 */

const ERROS = {
  CONFIRMACAO: 'Escreva APAGAR para confirmar.',
  SEM_SESSAO: 'A sessão expirou. Entre novamente.',
  CONTA_INTERNA: 'Esta conta pertence à equipa interna e não pode ser apagada aqui.',
  FALHOU: 'Não foi possível apagar a conta. Tente novamente.',
}

export default function SegurancaClient({ email, isInternal }) {
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [passwordMessage, setPasswordMessage] = useState('')
  const [passwordError, setPasswordError] = useState('')
  const [savingPassword, setSavingPassword] = useState(false)

  const [signingOutAll, setSigningOutAll] = useState(false)
  const [confirmacao, setConfirmacao] = useState('')
  const [deleteError, setDeleteError] = useState('')
  const [deleting, setDeleting] = useState(false)

  async function handleChangePassword(event) {
    event.preventDefault()
    setPasswordError('')
    setPasswordMessage('')

    if (newPassword.length < 8) {
      setPasswordError('A palavra-passe deve ter pelo menos 8 caracteres.')
      return
    }
    if (newPassword !== confirmPassword) {
      setPasswordError('As palavras-passe não coincidem.')
      return
    }

    setSavingPassword(true)
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({ password: newPassword })
      if (error) {
        setPasswordError(
          error.message?.includes('different from the old password')
            ? 'A nova palavra-passe tem de ser diferente da atual.'
            : 'Não foi possível atualizar a palavra-passe.',
        )
      } else {
        setPasswordMessage('Palavra-passe atualizada.')
        setNewPassword('')
        setConfirmPassword('')
      }
    } catch {
      setPasswordError('Não foi possível atualizar a palavra-passe.')
    } finally {
      setSavingPassword(false)
    }
  }

  async function handleSignOutEverywhere() {
    setSigningOutAll(true)
    try {
      const supabase = createClient()
      await supabase.auth.signOut({ scope: 'global' })
    } catch {
      // Sair é o objectivo; a sessão local cai de qualquer forma.
    }
    window.location.href = '/entrar'
  }

  async function handleDelete() {
    setDeleteError('')
    setDeleting(true)
    try {
      const result = await deleteMyAccount(confirmacao)
      if (result?.ok) {
        window.location.href = '/entrar?motivo=CONTA_APAGADA'
        return
      }
      setDeleteError(ERROS[result?.error] || ERROS.FALHOU)
    } catch {
      setDeleteError(ERROS.FALHOU)
    } finally {
      setDeleting(false)
    }
  }

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">A minha conta</p>
          <h1 className="conta-title">Segurança</h1>
          <p className="conta-sub">
            Sessão iniciada como <strong>{email}</strong>.
          </p>
        </div>
      </header>

      <div className="conta-grid2">
        <div>
          <section className="conta-panel" aria-labelledby="conta-palavra-passe">
            <div className="conta-panel-head">
              <h2 id="conta-palavra-passe" className="conta-panel-title">
                <KeyRound size={14} />
                Alterar palavra-passe
              </h2>
            </div>
            <div className="conta-panel-body">
              <form onSubmit={handleChangePassword} className="conta-form-row">
                <label>
                  <span className="conta-label">Nova palavra-passe</span>
                  <input
                    type="password"
                    value={newPassword}
                    onChange={(event) => setNewPassword(event.target.value)}
                    autoComplete="new-password"
                    minLength={8}
                    placeholder="Mínimo 8 caracteres"
                    className="conta-field"
                  />
                </label>

                <label>
                  <span className="conta-label">Confirmar palavra-passe</span>
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(event) => setConfirmPassword(event.target.value)}
                    autoComplete="new-password"
                    minLength={8}
                    placeholder="Repita a palavra-passe"
                    className="conta-field"
                  />
                </label>

                {passwordError && (
                  <p className="conta-hint" style={{ color: '#a3231f' }} role="alert">
                    {passwordError}
                  </p>
                )}
                {passwordMessage && <p className="conta-hint">{passwordMessage}</p>}

                <button
                  type="submit"
                  disabled={savingPassword || !newPassword || !confirmPassword}
                  className="conta-btn conta-btn--primary"
                  style={{ width: '100%' }}
                >
                  {savingPassword ? <Loader2 size={15} className="animate-spin" /> : null}
                  Atualizar palavra-passe
                </button>
              </form>
            </div>
          </section>

          <section className="conta-panel" aria-labelledby="conta-sessoes">
            <div className="conta-panel-head">
              <h2 id="conta-sessoes" className="conta-panel-title">
                <LogOut size={14} />
                Sessões
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                Sair aqui termina a sessão neste aparelho. Se perdeu um telemóvel ou entrou num
                computador partilhado, termine todas.
              </p>
              <button
                type="button"
                onClick={handleSignOutEverywhere}
                disabled={signingOutAll}
                className="conta-btn conta-btn--ghost"
                style={{ width: '100%', marginTop: '0.75rem' }}
              >
                {signingOutAll ? <Loader2 size={15} className="animate-spin" /> : null}
                Terminar sessão em todos os dispositivos
              </button>
            </div>
          </section>
        </div>

        <aside>
          <section className="conta-panel" aria-labelledby="conta-info">
            <div className="conta-panel-head">
              <h2 id="conta-info" className="conta-panel-title">
                A mesma conta em todo o lado
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                Esta conta serve o site, o Localizador e as reservas nas farmácias. Mudar a
                palavra-passe aqui muda-a nos três sítios.
              </p>
              <p className="conta-hint">
                O nome, a fotografia e o e-mail vivem em{' '}
                <Link href="/perfil" style={{ color: 'var(--color-brand-accent)' }}>
                  A minha conta
                </Link>
                .
              </p>
            </div>
          </section>

          <section className="conta-panel" aria-labelledby="conta-apagar">
            <div className="conta-panel-head">
              <h2 id="conta-apagar" className="conta-panel-title conta-panel-title--danger">
                <Trash2 size={14} />
                Apagar conta
              </h2>
            </div>
            <div className="conta-panel-body">
              {isInternal ? (
                <p className="conta-hint" style={{ marginTop: 0 }}>
                  Esta conta pertence à equipa interna e não pode ser apagada por aqui. Fale com
                  um superadmin.
                </p>
              ) : (
                <>
                  <p className="conta-hint" style={{ marginTop: 0 }}>
                    Apaga a conta e tudo o que está ligado a ela: guardados do Localizador e do
                    site, anotações e histórico de estudo. As reservas que fez ficam na farmácia,
                    sem ligação à sua conta. Não há como desfazer.
                  </p>

                  <label style={{ display: 'block', marginTop: '0.75rem' }}>
                    <span className="conta-label">
                      Escreva <strong>APAGAR</strong> para confirmar
                    </span>
                    <input
                      type="text"
                      value={confirmacao}
                      onChange={(event) => setConfirmacao(event.target.value)}
                      className="conta-field conta-field--danger"
                      placeholder="APAGAR"
                      autoComplete="off"
                    />
                  </label>

                  {deleteError && (
                    <p className="conta-hint" style={{ color: '#a3231f' }} role="alert">
                      {deleteError}
                    </p>
                  )}

                  <button
                    type="button"
                    onClick={handleDelete}
                    disabled={deleting || confirmacao.trim().toUpperCase() !== 'APAGAR'}
                    className="conta-btn conta-btn--danger"
                    style={{ width: '100%', marginTop: '0.75rem' }}
                  >
                    {deleting ? (
                      <Loader2 size={15} className="animate-spin" />
                    ) : (
                      <ShieldAlert size={15} />
                    )}
                    Apagar a minha conta
                  </button>
                </>
              )}
            </div>
          </section>
        </aside>
      </div>
    </main>
  )
}
