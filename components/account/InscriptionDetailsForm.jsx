'use client'

import { useActionState } from 'react'
import { guardarDadosInscricao } from '@/lib/actions/account'

const PROFISSOES = [
  ['enfermeiro', 'Enfermeiro(a)'],
  ['medico', 'Médico(a)'],
  ['farmaceutico', 'Farmacêutico(a)'],
  ['estudante-saude', 'Estudante da área da saúde'],
  ['tecnico-medio-saude', 'Técnico(a) médio(a) de saúde'],
  ['tecnico-radiologia', 'Técnico(a) de radiologia'],
  ['tecnico-analises-clinicas', 'Técnico(a) de análises clínicas'],
  ['medico-dentista', 'Médico(a) dentista'],
  ['biologo-analista', 'Biólogo(a) analista'],
  ['psicologo', 'Psicólogo(a)'],
  ['nutricionista', 'Nutricionista'],
  ['fisioterapeuta', 'Fisioterapeuta'],
  ['outro', 'Outro'],
]

const FAIXAS = [
  ['menor-18', 'Menos de 18'],
  ['18-24', '18–24'],
  ['25-34', '25–34'],
  ['35-44', '35–44'],
  ['45-54', '45–54'],
  ['55+', '55 ou mais'],
]

const GENEROS = [
  ['masculino', 'Masculino'],
  ['feminino', 'Feminino'],
]

const ESCOLARIDADES = [
  ['tecnico-profissional', 'Técnico-profissional'],
  ['licenciatura', 'Licenciatura'],
  ['pos-graduacao-mestrado', 'Pós-graduação / Mestrado'],
  ['doutoramento', 'Doutoramento'],
]

const MENSAGENS = {
  SEM_SESSAO: 'A sessão expirou. Entre outra vez.',
  TELEFONE: 'O telefone não parece válido.',
  INVALIDO: 'Um dos valores escolhidos não é válido.',
  FALHOU: 'Não foi possível guardar. Tente novamente.',
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
 */
export default function InscriptionDetailsForm({ email, initial = {} }) {
  const [state, formAction, pending] = useActionState(guardarDadosInscricao, null)

  return (
    <form action={formAction}>
      <p className="conta-sub" style={{ marginBottom: '0.875rem' }}>
        Guardamos estes dados na sua conta para a próxima inscrição já vir preenchida. Pode
        alterá-los quando quiser.
      </p>

      <div className="conta-form-grid">
        <Campo label="Nome completo">
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

        <Campo label="E-mail da conta">
          <input className="conta-field" type="email" value={email} readOnly disabled />
        </Campo>

        <Campo label="Telefone">
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

        <Campo label="Profissão">
          <select className="conta-field" name="profissao" defaultValue={initial.profissao || ''}>
            <option value="">Escolher…</option>
            {PROFISSOES.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
        </Campo>

        <Campo label="Faixa etária">
          <select
            className="conta-field"
            name="faixa_etaria"
            defaultValue={initial.faixa_etaria || ''}
          >
            <option value="">Escolher…</option>
            {FAIXAS.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
        </Campo>

        <Campo label="Género">
          <select className="conta-field" name="genero" defaultValue={initial.genero || ''}>
            <option value="">Escolher…</option>
            {GENEROS.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
        </Campo>

        <Campo label="Nível de escolaridade">
          <select
            className="conta-field"
            name="nivel_escolaridade"
            defaultValue={initial.nivel_escolaridade || ''}
          >
            <option value="">Escolher…</option>
            {ESCOLARIDADES.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
        </Campo>
      </div>

      <div className="conta-actions" style={{ marginTop: '0.875rem' }}>
        <button className="conta-btn conta-btn--primary conta-btn--sm" type="submit" disabled={pending}>
          {pending ? 'A guardar…' : 'Guardar dados'}
        </button>
        {state?.ok && (
          <span className="conta-row-meta" role="status">
            Dados guardados. A próxima inscrição já vem preenchida.
          </span>
        )}
        {state?.error && (
          <span className="conta-row-meta" role="status">
            {MENSAGENS[state.error] || 'Não foi possível guardar.'}
          </span>
        )}
      </div>
    </form>
  )
}
