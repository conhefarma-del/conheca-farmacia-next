'use client'

import { useActionState, useContext } from 'react'
import { guardarDadosInscricao } from '@/lib/actions/account'
import { LangContext } from '@/lib/contexts'

/**
 * Opções guardadas por slug. O rótulo vem do dicionário (`account.inscription.*`)
 * para o formulário seguir o idioma da conta — o valor que segue para o
 * servidor é o slug, que não muda com a língua.
 */
const PROFISSOES = [
  'enfermeiro',
  'medico',
  'farmaceutico',
  'estudante-saude',
  'tecnico-medio-saude',
  'tecnico-radiologia',
  'tecnico-analises-clinicas',
  'medico-dentista',
  'biologo-analista',
  'psicologo',
  'nutricionista',
  'fisioterapeuta',
  'outro',
]

const FAIXAS = ['menor-18', '18-24', '25-34', '35-44', '45-54', '55+']
const GENEROS = ['masculino', 'feminino']
const ESCOLARIDADES = [
  'tecnico-profissional',
  'licenciatura',
  'pos-graduacao-mestrado',
  'doutoramento',
]

const ERROS = {
  SEM_SESSAO: 'account.inscription.errors.session',
  TELEFONE: 'account.inscription.errors.phone',
  INVALIDO: 'account.inscription.errors.invalid',
  FALHOU: 'account.inscription.errors.failed',
}

function Campo({ label, children, wide = false }) {
  return (
    <div style={wide ? { gridColumn: '1 / -1' } : undefined}>
      <label className="conta-label">{label}</label>
      {children}
    </div>
  )
}

/**
 * Dados de inscrição guardados na conta.
 *
 * O formulário público de inscrição lê estes valores de `user_metadata` e
 * arranca já preenchido — a pessoa confirma e submete. Guardar aqui não
 * inscreve em nenhum evento.
 *
 * O `conta-panel-body` é obrigatório: sem ele o formulário encostava às
 * bordas do cartão e os campos pareciam transbordar.
 */
export default function InscriptionDetailsForm({ email, initial = {} }) {
  const { t } = useContext(LangContext)
  const [state, formAction, pending] = useActionState(guardarDadosInscricao, null)

  return (
    <div className="conta-panel-body">
      <form action={formAction}>
        <p className="conta-sub" style={{ marginBottom: '0.875rem' }}>
          {t('account.inscription.intro')}
        </p>

        <div className="conta-form-grid">
          <Campo label={t('account.inscription.name')}>
            <input
              className="conta-field"
              type="text"
              name="nome"
              defaultValue={initial.nome || ''}
              maxLength={200}
              autoComplete="name"
              required
            />
          </Campo>

          <Campo label={t('account.inscription.email')}>
            <input className="conta-field" type="email" value={email} readOnly disabled />
          </Campo>

          <Campo label={t('account.inscription.phone')}>
            <input
              className="conta-field"
              type="tel"
              name="telefone"
              defaultValue={initial.telefone || ''}
              maxLength={20}
              autoComplete="tel"
              placeholder="+244 9xx xxx xxx"
            />
          </Campo>

          <Campo label={t('account.inscription.profession')}>
            <select className="conta-field" name="profissao" defaultValue={initial.profissao || ''}>
              <option value="">{t('account.inscription.choose')}</option>
              {PROFISSOES.map((value) => (
                <option key={value} value={value}>
                  {t(`account.inscription.professions.${value}`)}
                </option>
              ))}
            </select>
          </Campo>

          <Campo label={t('account.inscription.age')}>
            <select
              className="conta-field"
              name="faixa_etaria"
              defaultValue={initial.faixa_etaria || ''}
            >
              <option value="">{t('account.inscription.choose')}</option>
              {FAIXAS.map((value) => (
                <option key={value} value={value}>
                  {t(`account.inscription.ages.${value}`)}
                </option>
              ))}
            </select>
          </Campo>

          <Campo label={t('account.inscription.gender')}>
            <select className="conta-field" name="genero" defaultValue={initial.genero || ''}>
              <option value="">{t('account.inscription.choose')}</option>
              {GENEROS.map((value) => (
                <option key={value} value={value}>
                  {t(`account.inscription.genders.${value}`)}
                </option>
              ))}
            </select>
          </Campo>

          <Campo label={t('account.inscription.education')}>
            <select
              className="conta-field"
              name="nivel_escolaridade"
              defaultValue={initial.nivel_escolaridade || ''}
            >
              <option value="">{t('account.inscription.choose')}</option>
              {ESCOLARIDADES.map((value) => (
                <option key={value} value={value}>
                  {t(`account.inscription.educationLevels.${value}`)}
                </option>
              ))}
            </select>
          </Campo>
        </div>

        <div className="conta-actions" style={{ marginTop: '0.875rem' }}>
          <button
            className="conta-btn conta-btn--primary conta-btn--sm"
            type="submit"
            disabled={pending}
          >
            {pending ? t('account.inscription.saving') : t('account.inscription.save')}
          </button>
          {state?.ok && (
            <span className="conta-row-meta" role="status">
              {t('account.inscription.saved')}
            </span>
          )}
          {state?.error && (
            <span className="conta-row-meta" role="status">
              {t(ERROS[state.error] || 'account.common.saveFailed')}
            </span>
          )}
        </div>
      </form>
    </div>
  )
}
