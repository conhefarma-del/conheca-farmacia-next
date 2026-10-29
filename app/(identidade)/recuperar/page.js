import EsqueciClient from '@/components/auth/EsqueciForm'

export const metadata = {
  title: 'Recuperar palavra-passe',
  robots: { index: false, follow: false },
}

/**
 * Pedido de reposição de senha.
 *
 * O link do e-mail cai em `/auth/reset`, que troca o código por sessão e
 * encaminha para `/perfil/seguranca` — é lá que a nova palavra-passe é
 * definida, ao lado das outras opções de segurança. Não há ecrã `/repor-senha`
 * separado: seria o mesmo formulário num sítio a mais.
 */
export default function RecuperarPage() {
  return <EsqueciClient lang="pt" basePath="" resetPath="/auth/reset" />
}
