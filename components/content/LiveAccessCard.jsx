import { validateUrl } from '@/lib/security'

export default function LiveAccessCard({ live, t }) {
  const hasCredentials = live.id_reuniao || live.senha
  const accessLabel = t ? t('live_detail.aceder_agora') : 'Aceder Agora'
  const credentialsTitle = t ? t('live_detail.credenciais') : 'Credenciais da Reunião'
  const meetingIdLabel = t ? t('live_detail.id_reuniao') : 'ID da Reunião'
  const passwordLabel = t ? t('live_detail.senha') : 'Senha'

  return (
    <div className="quick-access-card">
      <h3 className="text-lg font-bold text-brand-deep mb-4">{accessLabel}</h3>
      {live.link_acesso ? (
        <a
          href={validateUrl(live.link_acesso)}
          target="_blank"
          rel="noopener noreferrer"
          className="block w-full text-center py-3 px-6 bg-brand-primary text-white rounded-xl font-semibold hover:bg-brand-primary/90 transition-colors"
        >
          {accessLabel}
        </a>
      ) : (
        <p className="text-brand-deep/60 text-sm">
          {t ? t('live_detail.link_indisponivel') : 'Link de acesso indisponível'}
        </p>
      )}

      {hasCredentials && (
        <div className="mt-4 pt-4 border-t border-brand-divider/20">
          <h4 className="text-sm font-semibold text-brand-deep mb-2">{credentialsTitle}</h4>
          {live.id_reuniao && (
            <p className="text-sm text-brand-deep/70">
              <span className="font-medium">{meetingIdLabel}:</span> {live.id_reuniao}
            </p>
          )}
          {live.senha && (
            <p className="text-sm text-brand-deep/70">
              <span className="font-medium">{passwordLabel}:</span> {live.senha}
            </p>
          )}
        </div>
      )}
    </div>
  )
}
