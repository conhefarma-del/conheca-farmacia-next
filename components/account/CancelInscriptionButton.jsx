'use client'

import { useActionState } from 'react'
import { cancelarInscricao } from '@/lib/actions/account'

const MENSAGENS = {
  SEM_SESSAO: 'A sessão expirou. Entre outra vez.',
  NAO_ENCONTRADA: 'Esta inscrição já não existe.',
  SEM_PERMISSAO: 'Esta inscrição não pertence a esta conta.',
  JA_DECORREU: 'Este evento já decorreu — não é possível cancelar.',
  INVALIDA: 'Pedido inválido.',
  FALHOU: 'Não foi possível cancelar. Tente novamente.',
}

/**
 * Cancelar a própria inscrição.
 *
 * O servidor confirma de novo a sessão, o e-mail e a data do evento — o botão
 * só existe para não mandar um pedido que se sabe de antemão recusado.
 */
export default function CancelInscriptionButton({ id }) {
  const [state, formAction, pending] = useActionState(cancelarInscricao, null)

  return (
    <form
      action={formAction}
      onSubmit={(event) => {
        if (!window.confirm('Cancelar esta inscrição? Esta ação não pode ser desfeita.')) {
          event.preventDefault()
        }
      }}
    >
      <input type="hidden" name="id" value={String(id)} />
      <button className="conta-remove" type="submit" disabled={pending}>
        {pending ? 'A cancelar…' : 'Cancelar'}
      </button>
      {state?.error && (
        <span className="conta-row-meta" role="status">
          {MENSAGENS[state.error] || 'Não foi possível cancelar.'}
        </span>
      )}
    </form>
  )
}
