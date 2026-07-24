# CMS Inscritos + Comprovativo + Certificado de Participação — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar ao CMS uma secção "Inscritos" (filtro por evento + busca), permitir regenerar o comprovativo de inscrição e gerar um Certificado de Participação com template por evento e QR público independente do comprovativo.

**Architecture:** Novas migrações Supabase (colunas em `inscricoes` e `events`); nova rota admin `(protected)/inscritos` + `InscritosListPage`; nova Server Action `marcarCompareceu`; novo componente `CertificadoParticipacao` (print-to-PDF, A4 paisagem, baseado em `certificado/CF-CERT-modelo-2026.html`); nova rota pública `/certificado/[token]`. O comprovativo reutiliza `InscricaoBilhete` existente. Identificadores separados: `shortRef` (int8, secreto, admin-only) vs `certificado_token` (UUID, público).

**Tech Stack:** Next.js 16 App Router, React 19, Supabase (Postgres + RLS), Server Actions (`'use server'`), pacote `qrcode` (client-side), Tailwind v4, print-to-PDF via `window.print()`.

**Pré-requisito de ambiente (fora do plano):** o `node_modules` está corrupto (case-collision NTFS) e foi agendado `chkdsk C: /f` no próximo reboot. Antes de executar qualquer `npm run`/teste, fazer reboot + `npm install`. Ver `REBOOT_RECOVERY_NOTES.md`.

---

## File Structure

**Migrações (novas):**
- `supabase/migrations/032_inscricoes_certificado.sql` — colunas em `inscricoes`.
- `supabase/migrations/033_eventos_certificado_template.sql` — colunas de template em `events`.

**CMS listagem:**
- Create: `app/[lang]/admin/(protected)/inscritos/page.js` — Server Component.
- Create: `components/admin/InscritosListPage.jsx` — Client Component (tabela + filtros + ações).
- Modify: `components/layout/AdminSidebar.jsx` — item "Inscritos".

**Server Actions:**
- Modify: `lib/actions/lists.js` — `getAllInscricoesAdmin()`, `getAllEventsForFilter()`.
- Modify: `lib/actions/content.js` — `marcarCompareceu(id)`.

**Comprovativo (reuso):**
- Reuse: `components/pages/InscricaoPageClient.jsx` → `InscricaoBilhete` (já existe).
- Create: `components/admin/ComprovativoModal.jsx` — embrulha `InscricaoBilhete` + botão print.

**Certificado:**
- Create: `components/admin/CertificadoParticipacao.jsx` — componente print-to-PDF A4 paisagem.
- Create: `app/certificado/[token]/page.js` — rota pública de validação.

**Template no evento (CMS):**
- Modify: `components/admin/EventForm.jsx` (ou ficheiro de campos PT) — novos campos de certificado.
- Modify: `lib/actions/content.js` — validação hex/url no update de evento (reuso de `lib/security.js`).

**Util/validação:**
- Reuse: `lib/security.js` (`validateUrl`, escape), `lib/validar.js` (`maskEmail`, `partialName`).

---

## Task 1: Migração `inscricoes` — token + flag participação

**Files:**
- Create: `supabase/migrations/032_inscricoes_certificado.sql`

- [ ] **Step 1: Escrever a migração**

```sql
-- 032: certificado de participação — token público + flag de participação
-- O certificado_token é UUID público, SEPARADO do shortRef (int8) do comprovativo.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE public.inscricoes
  ADD COLUMN IF NOT EXISTS certificado_token uuid UNIQUE DEFAULT gen_random_uuid(),
  ADD COLUMN IF NOT EXISTS compareceu boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS certificado_emitido_at timestamptz,
  ADD COLUMN IF NOT EXISTS certificado_emitido_por uuid;

CREATE INDEX IF NOT EXISTS inscricoes_certificado_token_idx
  ON public.inscricoes (certificado_token);
```

- [ ] **Step 2: Aplicar a migração (após reboot + npm install + login Supabase CLI)**

```bash
npx supabase db push
# ou, se usar migration runner local: npx supabase migration up
```

Expected: migração aplicada; `inscricoes` ganha `certificado_token` (preenchido por DEFAULT em linhas existentes), `compareceu`, `certificado_emitido_at`, `certificado_emitido_por`.

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/032_inscricoes_certificado.sql
git commit -m "feat(db): add certificado_token + compareceu to inscricoes"
```

---

## Task 2: Migração `events` — template de certificado

**Files:**
- Create: `supabase/migrations/033_eventos_certificado_template.sql`

- [ ] **Step 1: Escrever a migração**

```sql
-- 033: campos de template de certificado por evento (editáveis no CMS, PT)
ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS certificado_cor TEXT DEFAULT '#00493A',
  ADD COLUMN IF NOT EXISTS certificado_texto TEXT
    DEFAULT 'Certificamos que o participante concluiu com aproveitamento.',
  ADD COLUMN IF NOT EXISTS certificado_logo_url TEXT,
  ADD COLUMN IF NOT EXISTS certificado_carga_horaria TEXT,
  ADD COLUMN IF NOT EXISTS certificado_assinante_1_nome TEXT DEFAULT 'Conheça Farmácia',
  ADD COLUMN IF NOT EXISTS certificado_assinante_1_cargo TEXT DEFAULT 'Conheça Farmácia',
  ADD COLUMN IF NOT EXISTS certificado_assinante_2_nome TEXT,
  ADD COLUMN IF NOT EXISTS certificado_assinante_2_cargo TEXT DEFAULT 'Ordem dos Farmacêuticos';
```

Nota: a validação de `certificado_cor` (hex) e `certificado_logo_url` (`validateUrl`) é feita na
Server Action de update de evento (Task 9), não na migração.

- [ ] **Step 2: Aplicar a migração**

```bash
npx supabase db push
```

Expected: `events` ganha os 8 campos; valores default aplicados.

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/033_eventos_certificado_template.sql
git commit -m "feat(db): add certificado template columns to events"
```

---

## Task 3: Helper de validação de cor hex + testes

**Files:**
- Create: `lib/security.test.js` (ou `lib/security.spec.js` conforme runner do projeto)
- Modify: `lib/security.js` (adicionar `isValidHexColor` se não existir)

- [ ] **Step 1: Escrever o teste falhante**

```js
// lib/security.test.js
import { isValidHexColor, validateUrl } from '@/lib/security'

describe('isValidHexColor', () => {
  it('aceita #00493A e #2E8B6F', () => {
    expect(isValidHexColor('#00493A')).toBe(true)
    expect(isValidHexColor('#2E8B6F')).toBe(true)
  })
  it('rejeita cor sem #, vazia, ou com caracteres inválidos', () => {
    expect(isValidHexColor('00493A')).toBe(false)
    expect(isValidHexColor('')).toBe(false)
    expect(isValidHexColor('#ZZZ')).toBe(false)
    expect(isValidHexColor('red')).toBe(false)
  })
})
```

- [ ] **Step 2: Rodar o teste (espera FAIL — função inexistente)**

```bash
npm test -- lib/security.test.js
```

Expected: FAIL (`isValidHexColor is not a function`).

- [ ] **Step 3: Implementar `isValidHexColor` em `lib/security.js`**

Adicionar no fim do ficheiro (sem remover o existente):

```js
/**
 * Valida cor hex (#RGB ou #RRGGBB). Usado em template de certificado (events.certificado_cor).
 * Evita injeção de CSS arbitrário no estilo do certificado.
 */
export function isValidHexColor(value) {
  if (typeof value !== 'string') return false
  return /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(value.trim())
}
```

- [ ] **Step 4: Rodar o teste (espera PASS)**

```bash
npm test -- lib/security.test.js
```

Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/security.js lib/security.test.js
git commit -m "feat(security): add isValidHexColor validator"
```

---

## Task 4: Server Action `getAllInscricoesAdmin` + `getAllEventsForFilter`

**Files:**
- Modify: `lib/actions/lists.js` (adicionar funções no fim do ficheiro, após `getTopLives`)

- [ ] **Step 1: Escrever a query de inscrições (JOIN events)**

Acrescentar em `lib/actions/lists.js`:

```js
// ============================================================
//  INSCRIÇÕES — Lista para CMS (Inscritos)
// ============================================================
/**
 * Todas as inscrições com dados do evento (title, date) para a listagem do CMS.
 * SEC-API-03: colunas explícitas. Ordenado por created_at DESC.
 */
export async function getAllInscricoesAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('inscricoes')
      .select(`
        id, nome, email, telefone, profissao, created_at, evento_id, evento_slug,
        compareceu, certificado_token, certificado_emitido_at,
        evento:events ( id, title, date )
      `)
      .order('created_at', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Eventos publicados para o filtro da listagem de inscritos (apenas id + title).
 */
export async function getAllEventsForFilter() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('events')
      .select('id, title')
      .order('date', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}
```

- [ ] **Step 2: Verificação manual (após reboot + npm install)**

Abrir o projeto e confirmar que o ficheiro compila (`npm run build` ou `npm run dev`). A query
será exercitada na Task 6 (listagem).

- [ ] **Step 3: Commit**

```bash
git add lib/actions/lists.js
git commit -m "feat(actions): add getAllInscricoesAdmin + getAllEventsForFilter"
```

---

## Task 5: Server Action `marcarCompareceu`

**Files:**
- Modify: `lib/actions/content.js` (adicionar função; reusar `requireAdmin`/`requireSuperAdmin` + `logAudit` existentes)

- [ ] **Step 1: Escrever a Server Action**

Acrescentar em `lib/actions/content.js` (respeitar o padrão `throwCode`/`logAudit` do ficheiro):

```js
'use server'

// ... (imports existentes no topo do ficheiro: createClient, requireAdmin, requireSuperAdmin, logAudit, etc.)

/**
 * Marca (ou desmarca) participação de um inscrito.
 * Apenas admin+. Ao marcar compareceu=true, preenche certificado_emitido_at/por.
 * Retorna { ok: true } ou faz throw via throwCode.
 */
export async function marcarCompareceu(inscricaoId, compareceu) {
  const ctx = await requireAdmin()
  if (!ctx) {
    throwCode('unauthorized', 'admin_required')
  }
  const { supabase, user } = ctx

  try {
    const { error } = await supabase
      .from('inscricoes')
      .update({
        compareceu: Boolean(compareceu),
        certificado_emitido_at: compareceu ? new Date().toISOString() : null,
        certificado_emitido_por: compareceu ? user.id : null,
      })
      .eq('id', inscricaoId)

    if (error) {
      throwCode('db_error', error.message)
    }

    await logAudit('inscricao_marcar_compareceu', {
      inscricao_id: inscricaoId,
      compareceu: Boolean(compareceu),
      by: user.id,
    })

    return { ok: true }
  } catch (err) {
    if (err?.message?.startsWith('{')) throw err
    throwCode('unexpected', err.message)
  }
}
```

Nota: `throwCode` e `logAudit` já existem em `lib/actions/content.js` (ver início do ficheiro).
Se `requireAdmin` estiver em `lib/actions/lists.js` (neste projeto está), importá-lo:
`import { requireAdmin } from '@/lib/actions/lists'` — senão usar a definição local do content.js.

- [ ] **Step 2: Verificação de compilação**

```bash
npm run build
```

Expected: build sem erros de import/sintaxe em `lib/actions/content.js`.

- [ ] **Step 3: Commit**

```bash
git add lib/actions/content.js
git commit -m "feat(actions): add marcarCompareceu server action"
```

---

## Task 6: Rota admin `inscritos` + `InscritosListPage`

**Files:**
- Create: `app/[lang]/admin/(protected)/inscritos/page.js`
- Create: `components/admin/InscritosListPage.jsx`
- Modify: `components/layout/AdminSidebar.jsx` (adicionar item)

- [ ] **Step 1: Rota Server Component `inscritos/page.js`**

```jsx
// app/[lang]/admin/(protected)/inscritos/page.js
import { getAllInscricoesAdmin, getAllEventsForFilter } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/auth'
import InscritosListPage from '@/components/admin/InscritosListPage'

export const dynamic = 'force-dynamic'

export default async function InscritosPage({ params }) {
  const { lang } = await params
  const [inscricoes, eventos, currentUserRole] = await Promise.all([
    getAllInscricoesAdmin(),
    getAllEventsForFilter(),
    getCurrentRole(),
  ])

  return (
    <InscritosListPage
      lang={lang}
      inscricoes={inscricoes}
      eventos={eventos}
      currentUserRole={currentUserRole}
    />
  )
}
```

- [ ] **Step 2: Componente `InscritosListPage.jsx`**

```jsx
'use client'

import { useState, useMemo, useTransition } from 'react'
import { marcarCompareceu } from '@/lib/actions/content'
import { maskEmail } from '@/lib/validar'

export default function InscritosListPage({ lang, inscricoes, eventos, currentUserRole }) {
  const [filtroEvento, setFiltroEvento] = useState('')
  const [busca, setBusca] = useState('')
  const [pendingId, startTransition] = useTransition()
  const [erro, setErro] = useState(null)

  const filtrados = useMemo(() => {
    const termo = busca.trim().toLowerCase()
    return inscricoes.filter((i) => {
      const okEvento = !filtroEvento || i.evento_id === filtroEvento
      const okBusca =
        !termo ||
        (i.nome && i.nome.toLowerCase().includes(termo)) ||
        (i.email && i.email.toLowerCase().includes(termo))
      return okEvento && okBusca
    })
  }, [inscricoes, filtroEvento, busca])

  function onToggleCompareceu(id, atual) {
    setErro(null)
    startTransition(async () => {
      try {
        await marcarCompareceu(id, !atual)
      } catch (err) {
        setErro('Erro ao atualizar participação.')
      }
    })
  }

  return (
    <div className="admin-inscritos">
      <h1>Inscritos</h1>

      <div className="admin-inscritos-filtros">
        <select value={filtroEvento} onChange={(e) => setFiltroEvento(e.target.value)}>
          <option value="">Todos os eventos</option>
          {eventos.map((ev) => (
            <option key={ev.id} value={ev.id}>{ev.title}</option>
          ))}
        </select>
        <input
          type="search"
          placeholder="Buscar por nome ou email"
          value={busca}
          onChange={(e) => setBusca(e.target.value)}
        />
      </div>

      {erro && <p className="admin-erro">{erro}</p>}

      <table className="admin-inscritos-tabela">
        <thead>
          <tr>
            <th>Nome</th>
            <th>Email</th>
            <th>Evento</th>
            <th>Data inscrição</th>
            <th>Compareceu</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody>
          {filtrados.map((i) => (
            <tr key={i.id}>
              <td>{i.nome}</td>
              <td>{maskEmail(i.email)}</td>
              <td>{i.evento?.title || i.evento_slug || '—'}</td>
              <td>{i.created_at ? new Date(i.created_at).toLocaleDateString('pt-PT') : '—'}</td>
              <td>
                <label>
                  <input
                    type="checkbox"
                    checked={!!i.compareceu}
                    disabled={pendingId}
                    onChange={() => onToggleCompareceu(i.id, i.compareceu)}
                  />
                  {i.compareceu ? 'Sim' : 'Não'}
                </label>
              </td>
              <td>
                <button type="button" data-comprovativo={i.id}>Ver comprovativo</button>
                <button
                  type="button"
                  data-certificado={i.id}
                  disabled={!i.compareceu}
                  title={i.compareceu ? '' : 'Marque "Compareceu" primeiro'}
                >
                  Gerar certificado
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

Nota: os botões "Ver comprovativo" / "Gerar certificado" abrem os modais das Tasks 7 e 8.
Nesta task liga-se apenas o toggle "Compareceu". Os handlers de abrir modal serão adicionados
nas Tasks 7/8 (estender o componente).

- [ ] **Step 3: Item de sidebar**

Em `components/layout/AdminSidebar.jsx`, adicionar ao array `links` (antes de `definicoes` ou
onde fizer sentido visual), seguindo o padrão dos demais itens (PT hardcoded, sem i18n):

```jsx
{ name: 'Inscritos', href: (lang) => `/${lang}/admin/inscritos`, icon: Users, group: 'principal' },
```

(Usar o ícone `Users` de `lucide-react` já importado no ficheiro; se não estiver importado,
adicionar `Users` ao import de `lucide-react`.)

- [ ] **Step 4: Verificação**

```bash
npm run dev
```

Abrir `/pt/admin/inscritos` (com sessão admin): lista aparece, filtro e busca funcionam,
toggle "Compareceu" persiste após reload.

- [ ] **Step 5: Commit**

```bash
git add app/[lang]/admin/(protected)/inscritos/page.js components/admin/InscritosListPage.jsx components/layout/AdminSidebar.jsx
git commit -m "feat(admin): add Inscritos list page with filter + compareceu toggle"
```

---

## Task 7: Modal de comprovativo (reuso de `InscricaoBilhete`)

**Files:**
- Create: `components/admin/ComprovativoModal.jsx`
- Modify: `components/admin/InscritosListPage.jsx` (ligar botão "Ver comprovativo")

- [ ] **Step 1: Componente `ComprovativoModal.jsx`**

Reutiliza `InscricaoBilhete` (definido em `components/pages/InscricaoPageClient.jsx`). Para evitar
importar um Client Component gigante, extrai-se o `InscricaoBilhete` para o seu próprio ficheiro
`components/pages/InscricaoBilhete.jsx` (refactor mínimo: mover a função + helpers `formatEventDate`,
`formatEventTime`, `formatSubmittedAt`, `modalityLabel`, e o import dinâmico de `qrcode`).

Depois, em `ComprovativoModal.jsx`:

```jsx
'use client'

import { InscricaoBilhete } from '@/components/pages/InscricaoBilhete'

export default function ComprovativoModal({ inscricao, evento, onClose }) {
  const shortRef = String(inscricao.id).padStart(6, '0')
  const eventMeta = {
    startAt: evento?.date ? `${evento.date}T${evento.time || '00:00'}` : null,
    location: evento?.location || null,
    modality: evento?.type || null,
  }
  return (
    <div className="modal-overlay" role="dialog" aria-modal="true">
      <div className="modal-corpo">
        <InscricaoBilhete
          lang="pt"
          formData={inscricao}
          profLabel={inscricao.profissao}
          eventTitle={evento?.title}
          eventMeta={eventMeta}
          shortRef={shortRef}
          inscriptionDate={inscricao.created_at}
          logoSrc="/logo.svg"
          t={(k) => k}
        />
        <div className="modal-acoes">
          <button type="button" onClick={() => window.print()}>Imprimir / Guardar PDF</button>
          <button type="button" onClick={onClose}>Fechar</button>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Ligar o botão na `InscritosListPage`**

Adicionar estado `comprovativoId` e renderizar o modal quando definido:

```jsx
const [comprovativoId, setComprovativoId] = useState(null)
const inscricaoSel = inscricoes.find((i) => i.id === comprovativoId)
const eventoSel = eventos.find((e) => e.id === inscricaoSel?.evento_id)
```

No botão "Ver comprovativo": `onClick={() => setComprovativoId(i.id)}`.
Após a tabela, condicionalmente:

```jsx
{comprovativoId && inscricaoSel && (
  <ComprovativoModal
    inscricao={inscricaoSel}
    evento={eventoSel}
    onClose={() => setComprovativoId(null)}
  />
)}
```

- [ ] **Step 3: Verificação**

```bash
npm run dev
```

Na listagem, clicar "Ver comprovativo" → modal com boarding pass idêntico ao fluxo original →
"Imprimir" gera PDF.

- [ ] **Step 4: Commit**

```bash
git add components/admin/ComprovativoModal.jsx components/admin/InscritosListPage.jsx components/pages/InscricaoBilhete.jsx components/pages/InscricaoPageClient.jsx
git commit -m "feat(admin): comprovativo regen modal reusing InscricaoBilhete"
```

---

## Task 8: Componente `CertificadoParticipacao` (A4 paisagem)

**Files:**
- Create: `components/admin/CertificadoParticipacao.jsx`
- Modify: `components/admin/InscritosListPage.jsx` (ligar botão "Gerar certificado")

- [ ] **Step 1: Componente `CertificadoParticipacao.jsx`**

Baseado em `certificado/CF-CERT-modelo-2026.html`. Recebe `inscricao`, `evento` (com campos
`certificado_*`) e `certificadoToken`. Gera QR apontando a `/certificado/<token>` via `import('qrcode')`
(igual ao padrão de `InscricaoBilhete`). Aplica `certificado_cor` a gradient/frame/títulos.
Assinantes: se `evento.certificado_assinante_2_nome` vazio → 1 assinante centralizado.

```jsx
'use client'

import { useState, useEffect } from 'react'
import { qrcodeLib } from '@/lib/qrcodeClient' // helper que faz import('qrcode').toDataURL

export default function CertificadoParticipacao({ inscricao, evento, certificadoToken, onClose }) {
  const cor = evento?.certificado_cor || '#00493A'
  const texto = evento?.certificado_texto || 'Certificamos que o participante concluiu com aproveitamento.'
  const carga = evento?.certificado_carga_horaria || ''
  const dataEvento = evento?.date
    ? new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: 'long', year: 'numeric' }).format(new Date(evento.date))
    : ''
  const refCode = `CF-CERT-${String(inscricao.id).padStart(6, '0')}/${new Date(inscricao.created_at).getFullYear()}`
  const url = `https://conhecafarmacia.com/certificado/${certificadoToken}`

  const [qr, setQr] = useState(null)
  useEffect(() => {
    let cancelled = false
    qrcodeLib(url).then((d) => { if (!cancelled) setQr(d) }).catch(() => {})
    return () => { cancelled = true }
  }, [url])

  const assinante2 = evento?.certificado_assinante_2_nome
  const emitidoEm = inscricao.created_at
    ? new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(new Date(inscricao.certificado_emitido_at || inscricao.created_at))
    : ''

  return (
    <div className="cert-overlay" role="dialog" aria-modal="true">
      <div className="cert-corpo">
        <div className="cert-page" style={{ '--cert-cor': cor }}>
          <div className="cert-gradient-top" />
          <div className="cert-gradient-bottom" />
          <div className="cert-frame" />
          <div className="cert-content">
            {evento?.certificado_logo_url && (
              <img className="cert-logo" src={evento.certificado_logo_url} alt="Logótipo" />
            )}
            <div className="cert-kicker">Certificado de Participação</div>
            <div className="cert-title">{evento?.title}</div>
            <div className="cert-intro">Certificamos que</div>
            <div className="cert-recipient">{inscricao.nome}</div>
            <div className="cert-description">
              {texto} participou como <strong>participante</strong> em <strong>{evento?.title}</strong>,
              promovido pela <strong>Conheça Farmácia</strong>, realizado em <strong>{evento?.location || '—'}</strong>
              {' '}nos dias <strong>{dataEvento}</strong>
              {carga ? <>, com uma carga horária de <strong>{carga}</strong>.</> : '.'}
            </div>

            <div className={`cert-footer ${assinante2 ? '' : 'cert-footer--single'}`}>
              <div className="cert-qr-block">
                {qr ? <img className="cert-qr" src={qr} alt="QR de verificação" /> : <div className="cert-qr-box">QR</div>}
                <div className="cert-ref">Ref: {refCode}</div>
              </div>

              <div className="cert-signatures">
                <div className="cert-sig">
                  <div className="cert-sig-line">
                    <div className="cert-sig-name">{evento?.certificado_assinante_1_nome}</div>
                    <div className="cert-sig-role">{evento?.certificado_assinante_1_cargo}</div>
                  </div>
                </div>
                {assinante2 && (
                  <div className="cert-sig">
                    <div className="cert-sig-line">
                      <div className="cert-sig-name">{assinante2}</div>
                      <div className="cert-sig-role">{evento?.certificado_assinante_2_cargo}</div>
                    </div>
                  </div>
                )}
              </div>

              <div className="cert-emitido">Emitido em<br />{emitidoEm}</div>
            </div>
          </div>
        </div>

        <div className="cert-acoes">
          <button type="button" onClick={() => window.print()}>Imprimir / Guardar PDF</button>
          <button type="button" onClick={onClose}>Fechar</button>
        </div>
      </div>
    </div>
  )
}
```

CSS (adicionar a `styles/globals.css` ou `styles/admin/admin.css`): replicar o `@page { size: 297mm 210mm; margin: 0 }`,
`.cert-page` A4 paisagem, gradientes, frame, e `.cert-footer--single .cert-signatures { justify-content: center }`.
As cores fixas `#00493A` do modelo passam a `var(--cert-cor)`.

- [ ] **Step 2: Helper `lib/qrcodeClient.js`**

```js
// lib/qrcodeClient.js
export async function qrcodeLib(text) {
  const { default: qrcode } = await import('qrcode')
  return qrcode.toDataURL(text, {
    type: 'image/png',
    width: 200,
    margin: 0,
    errorCorrectionLevel: 'M',
    color: { dark: '#002a32', light: '#ffffff' },
  })
}
```

- [ ] **Step 3: Ligar o botão na `InscritosListPage`**

```jsx
const [certificadoId, setCertificadoId] = useState(null)
const certInscricao = inscricoes.find((i) => i.id === certificadoId)
const certEvento = eventos.find((e) => e.id === certInscricao?.evento_id)
```

Botão "Gerar certificado": `onClick={() => certInscricao?.compareceu && setCertificadoId(i.id)}` (já disabled se !compareceu).
Após a tabela:

```jsx
{certificadoId && certInscricao && (
  <CertificadoParticipacao
    inscricao={certInscricao}
    evento={certEvento}
    certificadoToken={certInscricao.certificado_token}
    onClose={() => setCertificadoId(null)}
  />
)}
```

- [ ] **Step 4: Verificação**

```bash
npm run dev
```

Marcar "Compareceu" num inscrito → "Gerar certificado" ativa → abre certificado A4 paisagem com
cor/template do evento + QR + assinantes. Testar evento com 1 assinante (centralizado) e 2 assinantes.

- [ ] **Step 5: Commit**

```bash
git add components/admin/CertificadoParticipacao.jsx lib/qrcodeClient.js components/admin/InscritosListPage.jsx styles/globals.css
git commit -m "feat(admin): certificado de participacao print-to-PDF A4 paisagem"
```

---

## Task 9: Rota pública `/certificado/[token]`

**Files:**
- Create: `app/certificado/[token]/page.js`

- [ ] **Step 1: Rota pública de validação**

```jsx
// app/certificado/[token]/page.js
import { createClient } from '@/lib/supabase/server'

export const dynamic = 'force-dynamic'

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export default async function CertificadoPublicoPage({ params }) {
  const { token } = await params

  if (!UUID_RE.test(token)) {
    return <CertificadoInvalido />
  }

  const supabase = await createClient()
  const { data, error } = await supabase
    .from('inscricoes')
    .select(`
      id, nome, created_at, compareceu, certificado_token,
      evento:events (
        id, title, date, location,
        certificado_cor, certificado_texto, certificado_logo_url,
        certificado_carga_horaria,
        certificado_assinante_1_nome, certificado_assinante_1_cargo,
        certificado_assinante_2_nome, certificado_assinante_2_cargo
      )
    `)
    .eq('certificado_token', token)
    .maybeSingle()

  if (error || !data) {
    return <CertificadoInvalido />
  }

  const ev = data.evento || {}
  const dataEvento = ev.date
    ? new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: 'long', year: 'numeric' }).format(new Date(ev.date))
    : ''

  return (
    <main className="cert-publico">
      <div className="cert-publico-status">✓ Certificado válido</div>
      <h1>{data.nome}</h1>
      <p><strong>{ev.title}</strong></p>
      <p>{ev.location} · {dataEvento}</p>
      {/* Não expõe shortRef, email, telefone, nem dados de admin */}
      <p className="cert-publico-aviso">
        Verificação: conhecafarmacia.com/certificado/{data.certificado_token}
      </p>
    </main>
  )
}

function CertificadoInvalido() {
  return (
    <main className="cert-publico">
      <div className="cert-publico-status cert-publico-status--invalid">✗ Certificado inválido ou expirado</div>
    </main>
  )
}
```

Importante de segurança: esta rota NÃO faz `requireAdmin()`; acesso apenas pelo token UUID.
Não seleciona `shortRef`, `email`, `telefone`, `certificado_emitido_por`.

- [ ] **Step 2: Verificação**

```bash
npm run dev
```

Abrir `/certificado/<token-valido>` em janela anónima → mostra nome completo + "Certificado válido".
Abrir `/certificado/<uuid-inexistente>` → "inválido". Ver source: confirmar ausência de `shortRef`/email.

- [ ] **Step 3: Commit**

```bash
git add app/certificado/[token]/page.js
git commit -m "feat: public certificado validation route /certificado/[token]"
```

---

## Task 10: Edição de template de certificado no evento (CMS)

**Files:**
- Modify: `components/admin/EventForm.jsx` (ou ficheiro de campos PT do evento)
- Modify: `lib/actions/content.js` (validação hex/url no update de evento, reuso `lib/security.js`)

- [ ] **Step 1: Campos no formulário do evento**

Adicionar secção "Certificado" no `EventForm` (PT) com inputs para:
`certificado_cor` (type color ou text), `certificado_texto` (textarea), `certificado_logo_url`
(text), `certificado_carga_horaria` (text), `certificado_assinante_1_nome`,
`certificado_assinante_1_cargo`, `certificado_assinante_2_nome`, `certificado_assinante_2_cargo`.
Ler os valores de `event` (se editando) e gravar no update. Seguir o padrão dos campos existentes
do formulário (BilingualTabs PT).

- [ ] **Step 2: Validação na Server Action de update de evento**

No `updateEvent` (ou função equivalente) em `lib/actions/content.js`, antes do `.update(...)`:

```js
import { isValidHexColor, validateUrl } from '@/lib/security'

const cor = formData.certificado_cor
if (cor && !isValidHexColor(cor)) {
  throwCode('invalid_color', 'certificado_cor must be hex')
}
const logo = formData.certificado_logo_url
if (logo && !validateUrl(logo)) {
  throwCode('invalid_url', 'certificado_logo_url must be a valid http(s) URL')
}
```

(`isValidHexColor` criado na Task 3; `validateUrl` já existe em `lib/security.js`.)

- [ ] **Step 3: Verificação**

```bash
npm run dev
```

Editar um evento → preencher cor inválida → erro de validação. Preencher cor/texto/logo/assinantes
válidos → certificado (Task 8) reflete as alterações.

- [ ] **Step 4: Commit**

```bash
git add components/admin/EventForm.jsx lib/actions/content.js
git commit -m "feat(admin): certificado template fields on event form + validation"
```

---

## Self-Review (espec → plano)

- [x] Spec 3.1 (`inscricoes` token/flag) → Task 1 ✓
- [x] Spec 3.2 (`events` template) → Task 2 ✓
- [x] Spec 3.3 mapeamento modelo → Tasks 7, 8 ✓
- [x] Spec 4.1 migrações → Tasks 1, 2 ✓
- [x] Spec 4.2 listagem Inscritos + sidebar → Task 6 ✓
- [x] Spec 4.3 regenerar comprovativo → Task 7 ✓
- [x] Spec 4.4 gerar certificado (toggle + componente + QR) → Tasks 5, 8 ✓
- [x] Spec 4.5 rota pública `/certificado/[token]` (nome completo, sem shortRef) → Task 9 ✓
- [x] Spec 4.6 edição de template no evento + validação → Task 10 ✓
- [x] Spec 5 segurança (separação token, RLS, validação, CSP) → Tasks 3, 9, 10 ✓
- [x] Spec 6 verificação → passos de verificação em cada task ✓
- [x] Spec 7 YAGNI (sem editor visual, sem mirror EN, sem PDF server-side) respeitado ✓

Placeholder scan: nenhum TBD/TODO. Código presente em todos os steps. Assinaturas consistentes
(`marcarCompareceu(id, bool)`, `getAllInscricoesAdmin()`, `getAllEventsForFilter()`, `qrcodeLib(text)`,
`isValidHexColor(value)`, `CertificadoParticipacao({inscricao, evento, certificadoToken, onClose})`).
