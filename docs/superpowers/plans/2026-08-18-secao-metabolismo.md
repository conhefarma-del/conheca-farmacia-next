# Secção "Metabolismo" em /medicamento/[slug] — Plano de Implementação (2026-08-18, v1)

> Plano baseado no módulo de Alvos Moleculares já implementado (migração 187,
> `/alvos`, `TargetLinks`) e nos dados reais da base: **226 fármacos com
> `drug_pharmacology.metabolism_pt` preenchido** e **20 alvos moleculares
> publicados** (`molecular_targets`), cada um com `substrates_pt` /
> `inhibitors_pt` / `inducers_pt` em texto corrido (ex.: CYP3A4 lista 15
> substratos, 10 inibidores, 8 indutores; P-gp 13 substratos...).
> **Não inventa conteúdo**: a relação fármaco ↔ alvo é derivada dos dados
> existentes e revista editorialmente com fonte citada.

## Decisões a confirmar (antes da implementação)

| # | Pergunta | Opção recomendada | Alternativa |
|---|----------|-------------------|-------------|
| 1 | Como cruzar fármaco ↔ alvo? | **Tabela estruturada `drug_target_roles`** (drug_id, target_id, role, source) com seed gerado por parse dos textos dos alvos + admin para rever | Parse dinâmico no servidor (match do nome do fármaco nos textos dos alvos) — sem migração, mas frágil (variantes de nome, "sumo de toranja" não é fármaco, sem fonte por linha) |
| 2 | A secção substitui o bloco "Metabolismo" da Farmacologia atual? | **Complementa**: o bloco de texto (`metabolism_pt`) mantém-se e a nova secção "Metabolismo — alvos moleculares" mostra o **mapa estruturado** (substrato/inibidor/indutor por alvo) logo abaixo | Substituir o texto pelo mapa (perde a informação qualitativa detalhada já curada) |
| 3 | Âmbito do seed inicial | **Todos os 226 fármacos**, derivados do parse (qualquer fármaco mencionado num alvo ganha as suas linhas com `source = 'Derivado de molecular_targets (DailyMed/EMC)'`) | Só fármacos verificados à mão (começa vazio — secção invisível até o admin preencher) |
| 4 | Quem revê o seed? | **Admin `/admin/alvos/drug-links`** — lista fármaco × alvo × papel com toggle aceitar/remover e campo de fonte editável | Sem admin (seed fica como está, sem possibilidade de corrigir erros de parse) |
| 5 | Exibição no perfil | **Badges por papel** (Substrato/Inibidor/Indutor) com cores, cada uma a ligar a `/alvos/[slug]`; aviso clínico quando fármaco é inibidor de algo que metaboliza (auto-interação CYP) | Só lista de nomes com links |

## Arquitetura

- **Público:** nova secção no `/medicamento/[slug]` (entre a Farmacologia e os
  "Fármacos relacionados"), lazy-loaded como as restantes secções abaixo da
  dobra. Cada linha: alvo (nome + link para `/alvos/[slug]`), papel
  (Substrato/Inibidor/Indutor com badge colorida) e nota curta do alvo.
  No topo, um aviso clínico quando o fármaco **inibe o próprio enzima que o
  metaboliza** (ex.: inibidor de CYP3A4 que também é substrato de CYP3A4) —
  informação real derivada do cruzamento, sem inventar.
- **Admin:** `/admin/alvos/drug-links` — tabela com filtro por fármaco/alvo/
  papel, edição de fonte e remoção de falsos positivos do parse.
- **Dados:** 1 tabela nova — `drug_target_roles` — padrão RLS do projeto
  (anon_read + admin_all, soft-delete, status, trigger updated_at).
  Seed idempotente `ON CONFLICT (drug_id, target_id, role)`.
- **Conteúdo:** 100% derivado — cada linha nasce do parse dos textos dos
  alvos (substrates/inhibitors/inducers) casando com os nomes reais dos
  fármacos da BD; `source` aponta para a fonte do alvo de origem.
- **Engine:** `lib/targets/derive.js` (puro, testável) — normaliza nomes
  (minúsculas, sem acentos, plurais), faz match nos textos dos alvos e gera
  as linhas candidatas; usado pelo seed e pelo admin (modo "re-derivar").

---

## Migração 188 — Schema `drug_target_roles`

**Ficheiro:** `supabase/migrations/188_drug_target_roles.sql`

```sql
-- Papel de cada fármaco em cada alvo molecular (substrato/inibidor/indutor).
-- Derivado dos textos de molecular_targets (substrates/inhibitors/inducers);
-- o admin revê e corrige. Sem conteúdo inventado: source = fonte do alvo.
CREATE TABLE IF NOT EXISTS public.drug_target_roles (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  drug_id     UUID NOT NULL REFERENCES public.drugs(id) ON DELETE CASCADE,
  target_id   UUID NOT NULL REFERENCES public.molecular_targets(id) ON DELETE CASCADE,
  role        TEXT NOT NULL CHECK (role IN ('substrate','inhibitor','inducer')),
  source_pt   TEXT NOT NULL DEFAULT '',
  source_en   TEXT NOT NULL DEFAULT '',
  status      TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (drug_id, target_id, role)
);

ALTER TABLE public.drug_target_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_read_drug_target_roles" ON public.drug_target_roles
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);
CREATE POLICY "admin_all_drug_target_roles" ON public.drug_target_roles
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

CREATE INDEX idx_dtr_drug ON public.drug_target_roles(drug_id, status);
CREATE INDEX idx_dtr_target ON public.drug_target_roles(target_id, role, status);

CREATE TRIGGER set_drug_target_roles_updated_at
  BEFORE UPDATE ON public.drug_target_roles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
```

## Migração 189 — Seed derivado do parse

- Script `_temp/derive_target_roles.mjs` (descartável, corre contra a BD via
  service role) que:
  1. Lê os 20 alvos publicados (`substrates_pt/inhibitors_pt/inducers_pt`)
  2. Lê os 226 fármacos publicados (`name_pt`, `slug`)
  3. Normaliza nomes (NFD, minúsculas, plurais comuns: -s, -es, -is) e faz
     match palavra-a-palavra nos textos dos alvos
  4. Gera o SQL `INSERT ... ON CONFLICT (drug_id, target_id, role) DO
     NOTHING` com `source_pt` = fonte do alvo de origem
- Exemplos esperados: simvastatina→CYP3A4(substrato), cetoconazol→CYP3A4
  (inibidor), rifampicina→CYP3A4 (indutor), digoxina→P-gp (substrato),
  fluoxetina→CYP2D6 (inibidor)...
- Falsos positivos conhecidos do parse ficam para o admin remover
  ("sumo de toranja" nunca casa com fármaco da BD — simplesmente não gera
  linha). O seed é idempotente.
- **Atenção à regra das fontes:** o texto dos alvos cita DailyMed/EMC — o
  `source` de cada linha derivada aponta para essa fonte (não é inventado).

---

## Tarefas

### T1 — Engine puro `lib/targets/derive.js` (novo)
- `normalizeName(s)` — NFD, minúsculas, remove acentos/pontuação, plurais
- `matchRole(targetText, drugNames)` — devolve os drugIds cujo nome
  normalizado aparece no texto (fronteira de palavra, mais longo primeiro)
- `deriveRoles(targets, drugs)` → linhas candidatas `{drugId, targetId, role}`
- `findAutoInteraction(drug, roles)` — true se o fármaco é simultaneamente
  substrato e inibidor/indutor do mesmo alvo (para o aviso clínico)
- Testes unitários com casos reais (CYP3A4 + simvastatina/cetoconazol/
  rifampicina; P-gp + digoxina; inibidor que é também substrato).

### T2 — Migrações 188 (schema) + 189 (seed)
- Aplicar no Supabase; validar contagens por papel (esperado: milhares de
  linhas; cada fármaco com ≥1 papel na maioria dos casos).

### T3 — Camada de dados `lib/api/targets.js` (estender)
- `getDrugTargetRoles(drugId, lang)` — papéis publicados do fármaco com
  `{ target: {slug, name, targetType}, role }` (join com molecular_targets)
- `getTargetRoleCounts()` — para o admin (contagem por fármaco/papel)
- Padrão `unstable_cache` + tag `alvos`; colunas explícitas; `createAnonClient`.

### T4 — Secção no perfil `/medicamento/[slug]`
- `components/medicamento/MetabolismSection.jsx` (novo, lazy via
  `next/dynamic` como a PharmacologySection):
  - Badges coloridas por papel: Substrato (verde), Inibidor (âmbar),
    Indutor (azul) — cada uma com link para `/alvos/[slug]` (tooltip no
    hover com "o que é", reutilizando o padrão do `TargetLinks`)
  - Aviso clínico destacado quando `findAutoInteraction` é true
  - Vazio → secção não renderiza
- `page.js` do slug: carregar `getDrugTargetRoles` e passar ao client.
- i18n: `medicamento_detalhe.secao_metabolismo_alvos`, `papel_substrato`,
  `papel_inibidor`, `papel_indutor`, `aviso_auto_interacao`.

### T5 — Admin `/admin/alvos/drug-links`
- Listagem: filtro por fármaco (search), alvo e papel; tabela com badges,
  fonte editável, estado, ações arquivar/restaurar/eliminar (superadmin)
- Botão "Re-derivar do parse" (chama o engine com os dados atuais e mostra
  candidatos novos vs existentes, sem gravar automaticamente)
- Form inline de fonte + toggle aceitar/remover (para limpar falsos
  positivos do seed sem perder a linha)
- Sidebar: item dentro do submenu Interações/Alvos (ícone `GitBranch` ou
  `Workflow`).

### T6 — SEO, pesquisa e navegação
- `/pesquisa` já indexa `alvos`; opcional: incluir a contagem de papéis no
  card do fármaco nos resultados (sem nova rota)
- Sitemap: sem novas rotas (secção dentro de página existente)
- `revalidar.sh` continua a usar o tag `alvos` (a secção usa a mesma tag).

---

## Ficheiros

| Ficheiro | Ação |
|---|---|
| `supabase/migrations/188_drug_target_roles.sql` | Novo (schema) |
| `supabase/migrations/189_seed_drug_target_roles.sql` | Novo (seed derivado) |
| `lib/targets/derive.js` + `lib/targets/derive.test.js` | Novo (engine + testes) |
| `lib/api/targets.js` | Estender (papéis por fármaco) |
| `components/medicamento/MetabolismSection.jsx` | Novo (secção lazy) |
| `app/[lang]/(public)/medicamento/[slug]/page.js` | Modificar (carregar papéis) |
| `app/[lang]/admin/(protected)/alvos/drug-links/page.js` | Novo (listagem admin) |
| `components/admin/DrugTargetRolesAdminPage.jsx` | Novo |
| `components/layout/AdminSidebar.jsx` | Modificar (item drug-links) |
| `public/i18n/pt.json` + `en.json` | Modificar (chaves da secção) |
| `styles/globals.css` | Modificar (badges `.target-role-*`, aviso) |
| `_temp/derive_target_roles.mjs` | Descartável (gera o seed 189) |

## Fora de âmbito (consciente)

- Não cria página própria de "metabolismo" — é uma secção do perfil do fármaco.
- Não altera `molecular_targets` (o dicionário de alvos mantém-se como está).
- Não inventa relações: o que o parse não encontrar fica por preencher até o
  admin adicionar manualmente com fonte.
- A "auto-interação CYP" é um aviso informativo derivado do cruzamento, não
  uma nova dimensão de interações na BD.
