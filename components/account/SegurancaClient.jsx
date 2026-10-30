'use client'

import { useContext, useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { deleteMyAccount, pedirAlteracaoEmail } from '@/lib/actions/account'
import { AtSign, KeyRound, Loader2, LogOut, ShieldAlert, Trash2 } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

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

const ERROS_EMAIL = {
  SEM_SESSAO: 'account.security.emailErrors.session',
  EMAIL_INVALIDO: 'account.security.emailErrors.invalid',
  MESMO_EMAIL: 'account.security.emailErrors.same',
  JA_EXISTE: 'account.security.emailErrors.exists',
  FALHOU: 'account.security.emailErrors.failed',
}

const ERROS = {
  CONFIRMACAO: 'account.security.deleteErrors.confirm',
  SEM_SESSAO: 'account.security.deleteErrors.session',
  CONTA_INTERNA: 'account.security.deleteErrors.internal',
  FALHOU: 'account.security.deleteErrors.failed',
}

export default function SegurancaClient({ email, isInternal }) {
  const { t } = useContext(LangContext)
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [passwordMessage, setPasswordMessage] = useState('')
  const [passwordError, setPasswordError] = useState('')
  const [savingPassword, setSavingPassword] = useState(false)

  const [newEmail, setNewEmail] = useState('')
  const [emailMessage, setEmailMessage] = useState('')
  const [emailError, setEmailError] = useState('')
  const [savingEmail, setSavingEmail] = useState(false)

  const [signingOutAll, setSigningOutAll] = useState(false)
  const [confirmacao, setConfirmacao] = useState('')
  const [deleteError, setDeleteError] = useState('')
  const [deleting, setDeleting] = useState(false)

  async function handleChangePassword(event) {
    event.preventDefault()
    setPasswordError('')
    setPasswordMessage('')

    if (newPassword.length < 8) {
      setPasswordError(t('account.security.passwordErrors.short'))
      return
    }
    if (newPassword !== confirmPassword) {
      setPasswordError(t('account.security.passwordErrors.mismatch'))
      return
    }

    setSavingPassword(true)
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({ password: newPassword })
      if (error) {
        setPasswordError(
          error.message?.includes('different from the old password')
            ? t('account.security.passwordErrors.different')
            : t('account.security.passwordErrors.failed'),
        )
      } else {
        setPasswordMessage(t('account.security.passwordUpdated'))
        setNewPassword('')
        setConfirmPassword('')
      }
    } catch {
      setPasswordError(t('account.security.passwordErrors.failed'))
    } finally {
      setSavingPassword(false)
    }
  }

  async function handleChangeEmail(event) {
    event.preventDefault()
    setEmailError('')
    setEmailMessage('')

    const next = newEmail.trim().toLowerCase()
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(next)) {
      setEmailError(t('account.security.emailErrors.invalid'))
      return
    }
    if (next === email.trim().toLowerCase()) {
      setEmailError(t('account.security.emailErrors.same'))
      return
    }

    setSavingEmail(true)
    try {
      // Server Action: reclama as inscrições antigas e guarda o e-mail atual
      // antes de o Supabase pedir a confirmação no endereço novo.
      const result = await pedirAlteracaoEmail(next)
      if (!result?.ok) {
        setEmailError(t(ERROS_EMAIL[result?.error] || 'account.security.emailErrors.failed'))
      } else {
        // O Supabase só muda o endereço depois da confirmação — nunca dizemos
        // que está mudado antes disso. Com confirmação dupla, chegam dois
        // e-mails (ao antigo e ao novo).
        setEmailMessage(t('account.security.emailSent'))
        setNewEmail('')
      }
    } catch {
      setEmailError(t('account.security.emailErrors.failed'))
    } finally {
      setSavingEmail(false)
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
      setDeleteError(t(ERROS[result?.error] || 'account.security.deleteErrors.failed'))
    } catch {
      setDeleteError(t('account.security.deleteErrors.failed'))
    } finally {
      setDeleting(false)
    }
  }

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">{t('account.kicker')}</p>
          <h1 className="conta-title">{t('account.security.title')}</h1>
          <p className="conta-sub">
            {t('account.security.signedInAs')} <strong>{email}</strong>.
          </p>
        </div>
      </header>

      <div className="conta-grid2">
        <div>
          <section className="conta-panel" aria-labelledby="conta-email">
            <div className="conta-panel-head">
              <h2 id="conta-email" className="conta-panel-title">
                <AtSign size={14} />
                {t('account.security.emailTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                {t('account.security.emailHint')}
              </p>
              <form onSubmit={handleChangeEmail} className="conta-form-row">
                <label>
                  <span className="conta-label">{t('account.security.newEmail')}</span>
                  <input
                    type="email"
                    value={newEmail}
                    onChange={(event) => setNewEmail(event.target.value)}
                    autoComplete="email"
                    placeholder={email}
                    className="conta-field"
                  />
                </label>

                {emailError && (
                  <p className="conta-hint" style={{ color: '#a3231f' }} role="alert">
                    {emailError}
                  </p>
                )}
                {emailMessage && <p className="conta-hint">{emailMessage}</p>}

                <button
                  type="submit"
                  disabled={savingEmail || !newEmail.trim()}
                  className="conta-btn conta-btn--primary"
                  style={{ width: '100%' }}
                >
                  {savingEmail ? <Loader2 size={15} className="animate-spin" /> : null}
                  {t('account.security.send')}
                </button>
              </form>
            </div>
          </section>

          <section className="conta-panel" aria-labelledby="conta-palavra-passe">
            <div className="conta-panel-head">
              <h2 id="conta-palavra-passe" className="conta-panel-title">
                <KeyRound size={14} />
                {t('account.security.passwordTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <form onSubmit={handleChangePassword} className="conta-form-row">
                <label>
                  <span className="conta-label">{t('account.security.newPassword')}</span>
                  <input
                    type="password"
                    value={newPassword}
                    onChange={(event) => setNewPassword(event.target.value)}
                    autoComplete="new-password"
                    minLength={8}
                    placeholder={t('account.security.newPasswordPlaceholder')}
                    className="conta-field"
                  />
                </label>

                <label>
                  <span className="conta-label">{t('account.security.confirmPassword')}</span>
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(event) => setConfirmPassword(event.target.value)}
                    autoComplete="new-password"
                    minLength={8}
                    placeholder={t('account.security.confirmPasswordPlaceholder')}
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
                  {t('account.security.updatePassword')}
                </button>
              </form>
            </div>
          </section>

          <section className="conta-panel" aria-labelledby="conta-sessoes">
            <div className="conta-panel-head">
              <h2 id="conta-sessoes" className="conta-panel-title">
                <LogOut size={14} />
                {t('account.security.sessionsTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                {t('account.security.sessionsHint')}
              </p>
              <button
                type="button"
                onClick={handleSignOutEverywhere}
                disabled={signingOutAll}
                className="conta-btn conta-btn--ghost"
                style={{ width: '100%', marginTop: '0.75rem' }}
              >
                {signingOutAll ? <Loader2 size={15} className="animate-spin" /> : null}
                {t('account.security.signOutAll')}
              </button>
            </div>
          </section>
        </div>

        <aside>
          <section className="conta-panel" aria-labelledby="conta-info">
            <div className="conta-panel-head">
              <h2 id="conta-info" className="conta-panel-title">
                {t('account.security.infoTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                {t('account.security.infoHint')}
              </p>
              <p className="conta-hint">
                <Link href="/perfil" style={{ color: 'var(--color-brand-accent)' }}>
                  {t('account.security.infoLink')}
                </Link>
                .
              </p>
            </div>
          </section>

          <section className="conta-panel" aria-labelledby="conta-apagar">
            <div className="conta-panel-head">
              <h2 id="conta-apagar" className="conta-panel-title conta-panel-title--danger">
                <Trash2 size={14} />
                {t('account.security.dangerTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              {isInternal ? (
                <p className="conta-hint" style={{ marginTop: 0 }}>
                  {t('account.security.dangerInternal')}
                </p>
              ) : (
                <>
                  <p className="conta-hint" style={{ marginTop: 0 }}>
                    {t('account.security.dangerHint')}
                  </p>

                  <label style={{ display: 'block', marginTop: '0.75rem' }}>
                    <span className="conta-label">{t('account.security.confirmLabel')}</span>
                    <input
                      type="text"
                      value={confirmacao}
                      onChange={(event) => setConfirmacao(event.target.value)}
                      className="conta-field conta-field--danger"
                      placeholder={t('account.security.confirmPlaceholder')}
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
                    {t('account.security.deleteAccount')}
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
