'use client'

import { useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { deleteMyAccount } from '@/lib/actions/account'
import { ArrowLeft, KeyRound, Loader2, LogOut, ShieldAlert, Trash2 } from 'lucide-react'

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
    <div className="container-center py-10 sm:py-14">
      <div className="mx-auto max-w-2xl">
        <Link
          href="/perfil"
          className="mb-6 inline-flex items-center gap-2 text-sm text-brand-deep/55 hover:text-brand-deep"
        >
          <ArrowLeft size={16} />
          A minha conta
        </Link>

        <h1 className="text-3xl font-bold text-brand-deep">Segurança</h1>
        <p className="mt-2 text-sm text-brand-deep/60">
          Sessão iniciada como <span className="font-medium text-brand-deep">{email}</span>.
        </p>

        {/* Palavra-passe */}
        <section className="mt-8 rounded-2xl border border-brand-divider bg-brand-card p-6 shadow-soft">
          <div className="mb-4 flex items-center gap-2 text-sm font-semibold text-brand-deep">
            <KeyRound size={16} className="text-brand-accent" />
            Alterar palavra-passe
          </div>

          <form onSubmit={handleChangePassword} className="space-y-3">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-brand-deep/60">
                Nova palavra-passe
              </span>
              <input
                type="password"
                value={newPassword}
                onChange={(event) => setNewPassword(event.target.value)}
                autoComplete="new-password"
                minLength={8}
                placeholder="Mínimo 8 caracteres"
                className="w-full rounded-lg border border-brand-divider bg-brand-bg px-4 py-2.5 text-brand-deep focus:outline-none focus:ring-2 focus:ring-brand-accent"
              />
            </label>

            <label className="block">
              <span className="mb-1 block text-xs font-medium text-brand-deep/60">
                Confirmar palavra-passe
              </span>
              <input
                type="password"
                value={confirmPassword}
                onChange={(event) => setConfirmPassword(event.target.value)}
                autoComplete="new-password"
                minLength={8}
                placeholder="Repita a palavra-passe"
                className="w-full rounded-lg border border-brand-divider bg-brand-bg px-4 py-2.5 text-brand-deep focus:outline-none focus:ring-2 focus:ring-brand-accent"
              />
            </label>

            {passwordError && <p className="text-xs text-red-600">{passwordError}</p>}
            {passwordMessage && <p className="text-xs text-green-600">{passwordMessage}</p>}

            <button
              type="submit"
              disabled={savingPassword || !newPassword || !confirmPassword}
              className="flex w-full items-center justify-center gap-2 rounded-lg bg-brand-accent px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-brand-accent/90 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {savingPassword ? <Loader2 size={16} className="animate-spin" /> : null}
              Atualizar palavra-passe
            </button>
          </form>
        </section>

        {/* Sessões */}
        <section className="mt-4 rounded-2xl border border-brand-divider bg-brand-card p-6 shadow-soft">
          <div className="mb-2 flex items-center gap-2 text-sm font-semibold text-brand-deep">
            <LogOut size={16} className="text-brand-accent" />
            Sessões
          </div>
          <p className="mb-4 text-xs leading-relaxed text-brand-deep/55">
            Sair aqui termina a sessão neste aparelho. Se perdeu um telemóvel ou entrou num
            computador partilhado, termine todas.
          </p>
          <button
            type="button"
            onClick={handleSignOutEverywhere}
            disabled={signingOutAll}
            className="flex w-full items-center justify-center gap-2 rounded-lg border border-brand-divider px-4 py-2.5 text-sm font-medium text-brand-deep transition-colors hover:bg-brand-deep/5 disabled:opacity-50"
          >
            {signingOutAll ? <Loader2 size={16} className="animate-spin" /> : null}
            Terminar sessão em todos os dispositivos
          </button>
        </section>

        {/* Apagar conta */}
        <section className="mt-4 rounded-2xl border border-red-200 bg-brand-card p-6 shadow-soft dark:border-red-900/40">
          <div className="mb-2 flex items-center gap-2 text-sm font-semibold text-red-600 dark:text-red-400">
            <Trash2 size={16} />
            Apagar conta
          </div>

          {isInternal ? (
            <p className="text-xs leading-relaxed text-brand-deep/60">
              Esta conta pertence à equipa interna e não pode ser apagada por aqui. Fale com um
              superadmin.
            </p>
          ) : (
            <>
              <p className="mb-4 text-xs leading-relaxed text-brand-deep/60">
                Apaga a conta e tudo o que está ligado a ela: guardados do Localizador e do site,
                anotações e histórico de estudo. As reservas que fez ficam na farmácia, sem
                ligação à sua conta. Não há como desfazer.
              </p>

              <label className="mb-1 block text-xs font-medium text-brand-deep/60">
                Escreva <span className="font-semibold text-brand-deep">APAGAR</span> para
                confirmar
              </label>
              <input
                type="text"
                value={confirmacao}
                onChange={(event) => setConfirmacao(event.target.value)}
                className="w-full rounded-lg border border-red-200 bg-brand-bg px-4 py-2.5 text-brand-deep focus:outline-none focus:ring-2 focus:ring-red-400 dark:border-red-900/40"
                placeholder="APAGAR"
                autoComplete="off"
              />

              {deleteError && <p className="mt-2 text-xs text-red-600">{deleteError}</p>}

              <button
                type="button"
                onClick={handleDelete}
                disabled={deleting || confirmacao.trim().toUpperCase() !== 'APAGAR'}
                className="mt-3 flex w-full items-center justify-center gap-2 rounded-lg bg-red-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-red-700 disabled:cursor-not-allowed disabled:opacity-40"
              >
                {deleting ? <Loader2 size={16} className="animate-spin" /> : <ShieldAlert size={16} />}
                Apagar a minha conta
              </button>
            </>
          )}
        </section>
      </div>
    </div>
  )
}
