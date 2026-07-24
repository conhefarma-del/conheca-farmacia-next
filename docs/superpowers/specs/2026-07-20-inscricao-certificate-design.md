# Spec — CMS Inscritos + Regeneração de Comprovativo + Certificado de Participação

**Data:** 2026-07-20
**Branch alvo:** `security/i18n-audit-fixes` (ou branch dedicado a extrair deste trabalho)
**Autor:** bapti + OpenClaude (brainstorming + writing-plans)

## 1. Context

Hoje o fluxo de inscrição gera um comprovativo que o utilizador imprime ("Guardar como PDF") via
`window.print()` do componente `InscricaoBilhete` (boarding pass). O comprovativo usa um
identificador secreto `shortRef = String(inscricoes.id).padStart(6,'0')` (o `id` é **int8**) e o seu
QR aponta para `/validar?ref=<shortRef>` — página **admin-only** (`ValidarBloqueado` se não for admin).

O administrador precisa de, no CMS:
1. Ver todos os inscritos de todos os eventos, filtráveis por evento e por nome/email.
2. Regenerar o **mesmo** comprovativo de inscrição a partir do nome de um inscrito.
3. Gerar um **Certificado de Participação** por inscrito.

O Certificado de Participação tem **exposição pública** (recrutadores lêem o QR). Por isso o seu
identificador **NÃO pode** reutilizar o `shortRef` secreto do comprovativo — caso contrário o
`shortRef` deixaria de ser secreto. O certificado usa um **UUID público separado** (`certificado_token`).

Existe um modelo visual de referência em `certificado/CF-CERT-modelo-2026.html` (A4 paisagem,
paleta verde `#00493A`/`#2E8B6F`, logo SVG, QR box, assinaturas duplas, ref `CF-CERT-000000/2026`).
O certificado segue este modelo.

## 2. Decisões validadas (brainstorming)

1. **Token do certificado:** nova coluna `certificado_token` (UUID, única, `DEFAULT gen_random_uuid()`)
   na tabela `inscricoes`, **separada** do `shortRef` secreto do comprovativo.
2. **Elegibilidade:** admin marca manualmente `compareceu = true` no CMS; só então o botão
   "Gerar certificado" fica ativo.
3. **Formato de saída:** Print-to-PDF (componente React + `window.print()`), igual ao comprovativo atual.
   Sem novas libs de geração de PDF server-side.
4. **Validação pública:** nova rota pública `/certificado/[token]` que valida o UUID, mostra
   nome completo + evento + data e tem o seu próprio QR auto-referenciado.
5. **Listagem CMS:** secção "Inscritos" com filtro por evento (dropdown) + busca por nome/email.
6. **Permissões:** `admin` + `superadmin` operam tudo (reutiliza `requireAdmin()`). Sidebar **PT only**
   (hardcoded, igual ao resto da sidebar atual — sem mirror EN por agora).
7. **Template por evento:** cada evento tem cor/tema, texto de encerramento, logo e assinantes
   próprios, editáveis na página do evento no CMS.
8. **Assinantes editáveis:** admin edita "Nome do Responsável" e "Nome do Representante".
   Se o Representante estiver vazio → **apenas um assinante**, centralizado entre o QR (esquerda)
   e a data de emissão (direita).
9. **Nome na página pública:** `/certificado/[token]` mostra **nome completo** + evento + data
   ("Certificado válido").
10. **Formato:** A4 paisagem (`@page { size: 297mm 210mm }`), igual ao modelo.

## 3. Modelo de dados

### 3.1 Tabela `inscricoes` (migração `032_inscricoes_certificado.sql`)
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- para gen_random_uuid()

ALTER TABLE public.inscricoes
  ADD COLUMN IF NOT EXISTS certificado_token uuid UNIQUE DEFAULT gen_random_uuid(),
  ADD COLUMN IF NOT EXISTS compareceu boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS certificado_emitido_at timestamptz,
  ADD COLUMN IF NOT EXISTS certificado_emitido_por uuid;  -- user_id do admin

CREATE INDEX IF NOT EXISTS inscricoes_certificado_token_idx
  ON public.inscricoes (certificado_token);
```
- `certificado_token` gerado no signup via DEFAULT (backfill automático de inscrições antigas).
- RLS: SELECT em `inscricoes` já está restrito a admins (migration 014). O token UUID **nunca**
  é exposto fora de `/certificado/[token]` e do CMS admin.

### 3.2 Tabela `events` (migração `033_eventos_certificado_template.sql`)
```sql
ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS certificado_cor TEXT DEFAULT '#00493A',          -- hex, validado
  ADD COLUMN IF NOT EXISTS certificado_texto TEXT
    DEFAULT 'Certificamos que o participante concluiu com aproveitamento.',
  ADD COLUMN IF NOT EXISTS certificado_logo_url TEXT,                       -- validateUrl, nullable
  ADD COLUMN IF NOT EXISTS certificado_carga_horaria TEXT,                  -- ex: '8 horas'
  ADD COLUMN IF NOT EXISTS certificado_assinante_1_nome TEXT DEFAULT 'Conheça Farmácia',
  ADD COLUMN IF NOT EXISTS certificado_assinante_1_cargo TEXT DEFAULT 'Conheça Farmácia',
  ADD COLUMN IF NOT EXISTS certificado_assinante_2_nome TEXT,               -- nullable (opcional)
  ADD COLUMN IF NOT EXISTS certificado_assinante_2_cargo TEXT DEFAULT 'Ordem dos Farmacêuticos';
```
- Validação na Server Action de update de evento: `certificado_cor` via regex hex estrito
  (estilo `validateUrl`/`security.js`); `certificado_logo_url` via `validateUrl`.

### 3.3 Mapeamento do modelo CF-CERT → dados
| Placeholder no modelo | Fonte |
|---|---|
| `[NOME DO EVENTO]` (title) | `events.title` |
| `[Nome Completo do Participante]` | `inscricoes.nome` |
| `[participante / formador / palestrante]` | texto fixo "participante" (v1) |
| `[nome do evento]` | `events.title` |
| `[cidade]` | `events.location` |
| `[DD a DD de mês de AAAA]` | `events.date` (+ `end_time` se presente) |
| `[X horas]` | `events.certificado_carga_horaria` |
| `Ref: CF-CERT-000000/2026` | `CF-CERT-${shortRef}/${ano}` |
| QR CODE | `/certificado/[certificado_token]` |
| `[Nome do Responsável]` | `events.certificado_assinante_1_nome` |
| `[Nome do Representante]` | `events.certificado_assinante_2_nome` (se vazio → 1 assinante) |

## 4. Estrutura de ficheiros e mudanças

### 4.1 Migrações (novas)
- `supabase/migrations/032_inscricoes_certificado.sql`
- `supabase/migrations/033_eventos_certificado_template.sql`

### 4.2 CMS — listagem "Inscritos"
- **Nova rota:** `app/[lang]/admin/(protected)/inscritos/page.js` (Server Component)
  - `getAllInscricoesAdmin()` (nova em `lib/actions/lists.js`): query `inscricoes` LEFT JOIN `events`
    (title, date), ordenado por `created_at DESC`.
  - `getCurrentRole()` para `currentUserRole`.
- **Novo componente:** `components/admin/InscritosListPage.jsx` (Client)
  - Tabela: Nome, Email (mascarado via `maskEmail` de `lib/validar.js`), Evento, Data inscrição,
    Compareceu (toggle), Ações (Ver comprovativo / Gerar certificado).
  - Filtro por evento (dropdown de eventos publicados) + busca cliente por nome/email.
  - Reutiliza padrão de `EventosListPage` (role gating, `logAudit`).
- **Sidebar:** adicionar item `Inscritos` → `/{lang}/admin/inscritos` em `components/layout/AdminSidebar.jsx`
  (PT only, hardcoded, igual aos demais itens).

### 4.3 CMS — regenerar comprovativo
- Botão "Ver comprovativo" na linha do inscrito → modal/componte que renderiza `InscricaoBilhete`
  (já existe em `components/pages/InscricaoPageClient.jsx`) com `shortRef` e dados do evento.
- Admin faz `window.print()` → PDF. Sem novo UUID.

### 4.4 CMS — gerar certificado
- **Toggle "Compareceu":** Server Action `marcarCompareceu(id)` em `lib/actions/content.js`
  (`requireAdmin()` + `logAudit()`) → set `compareceu=true`, `certificado_emitido_at=now()`,
  `certificado_emitido_por = auth.uid()`.
- Botão "Gerar certificado" **ativo só se `compareceu=true`** → abre `CertificadoParticipacao`.
- **Novo componente:** `components/admin/CertificadoParticipacao.jsx` (React, baseado no modelo
  CF-CERT, A4 paisagem). Recebe: dados do inscrito (`nome`, `shortRef`, `created_at`),
  template do evento (`certificado_*`) e `events.title/date/time/end_time/location`.
  - Renderiza QR (client-side, biblioteca já usada no projeto para `InscricaoBilhete`) apontando
    a `/certificado/[certificado_token]`.
  - **Assinantes:** se `certificado_assinante_2_nome` vazio → 1 assinante centralizado
    (`justify-content: center`) entre QR (esquerda) e "Emitido em" (direita). Caso contrário,
    lado-a-lado (esquerda + direita) igual ao modelo.
  - Admin faz `window.print()` → PDF A4 paisagem.
- Cor tema (`certificado_cor`) aplica-se a gradient bands, frame border e títulos (substitui o
  `#00493A` fixo do modelo).

### 4.5 Rota pública `/certificado/[token]`
- **Nova rota:** `app/certificado/[token]/page.js` (pública, fora de `(public)`/admin;
  segue padrão de `app/validar/page.js`).
  - Valida formato UUID; lookup `inscricoes` por `certificado_token` JOIN `events`.
  - Se inválido/inexistente → "Certificado inválido ou expirado".
  - Mostra: nome completo, evento, data, "Certificado válido" + próprio QR auto-referenciado
    (`/certificado/[token]`).
  - **Não expõe** `shortRef`, nem dados de admin, nem PII de contacto.

### 4.6 Edição de template no evento (CMS)
- `EventForm` / `BilingualTabs` (PT): novos campos para `certificado_cor`, `certificado_texto`,
  `certificado_logo_url`, `certificado_carga_horaria`, `certificado_assinante_1_nome`,
  `certificado_assinante_1_cargo`, `certificado_assinante_2_nome`, `certificado_assinante_2_cargo`.
- Validação server-side (hex / `validateUrl`) antes do update.

## 5. Segurança

- **Separação de identificadores:** `shortRef` (comprovativo, admin-only) e `certificado_token`
  (certificado, público) são independentes. O certificado **nunca** revela o `shortRef`.
- **RLS:** SELECT `inscricoes` restrito a admins (migration 014). Server Actions de escrita usam
  `requireAdmin()` + `logAudit()`.
- **Validação de inputs:** `certificado_cor` (hex), `certificado_logo_url` (`validateUrl`) — evita
  XSS/injeção de CSS. Reutiliza `lib/security.js`.
- **CSP:** nenhuma mudança necessária (sem novo inline script); QR via biblioteca existente.
- **Página pública:** só expõe nome + evento + data + token; sem PII de contacto, sem `shortRef`.

## 6. Verificação (pós-reboot + `npm install`)

Pré-requisito: o `node_modules` está corrupto (case-collision NTFS) e foi agendado `chkdsk C: /f`
para o próximo reboot. Após reboot e `npm install`:
1. `npm run build` (ou `npm run dev`) sobe sem erros.
2. Admin acede `/pt/admin/inscritos` → vê inscritos; filtra por evento; busca por nome/email.
3. Marca "Compareceu" → botão "Gerar certificado" ativa.
4. Gera certificado → print → PDF A4 paisagem com cor/template do evento + QR + assinantes
   (testar caso 1 assinante = centralizado; caso 2 = lado-a-lado).
5. Abre `/certificado/[token]` em modo anónimo → mostra nome completo + "Certificado válido".
6. Confirma que `/certificado/[token]` NÃO expõe `shortRef` nem dados de admin (ver source).
7. Regenera comprovativo via "Ver comprovativo" → print → PDF idêntico ao fluxo original.
8. Edita template num evento no CMS → certificado reflete cor/texto/logo/assinantes.

## 7. Fora de âmbito (YAGNI)

- Editor visual drag-and-drop de certificados.
- Mirror EN da secção "Inscritos" (sidebar hardcoded PT, igual ao resto).
- Geração de PDF server-side (download binário) — mantém-se print-to-PDF.
- Check-in por QR no evento para definir participação (admin marca manualmente).
- Papel diferenciado (formador/palestrante) — v1 usa "participante" fixo.
