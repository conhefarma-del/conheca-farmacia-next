# Fluxo de Trabalho — Base Airtable de Pesquisa de Interações

> **Guia autónomo.** Este documento descreve o ciclo completo **pesquisa → migração
> SQL → pack CSV → Airtable → ligações → verificação**, para ser reproduzido em
> qualquer sessão nova **sem depender das memórias da sessão original**. Lê isto
> do início ao fim antes de começar, e consulta os documentos que ele referencia.

Dois documentos irmãos:
- **`docs/INTERACOES_FLUXO_PESQUISA.md`** — a **metodologia de pesquisa clínica**: fontes
  permitidas, como obter/validar setIDs, como redigir citações, severidade, padrões SQL
  fármaco-fármaco (Fluxo 1) e as 3 dimensões novas (Fluxo 2, EMC-UK canónico). As regras de
  conteúdo (domínio público, citações reais, conteúdo autoral) vivem lá.
- **`_temp/airtable-pack/README.md`** — o «manual de operação» do pack: tabelas, campos de
  ligação, variáveis de ambiente, gotchas (BOM, formato do valor de ligação).

**Este** documento amarra os dois num **fluxo passo-a-passo reproduzível**.

---

## 0. Visão geral / diagrama

```
 [Fontes de domínio público]           DailyMed/FDA, EMC-UK (MHRA), Health Canada,
        │                              LiverTox, MedlinePlus, PubMed (+ Prontuário
        ▼                              INFARMED como referência adicional, só)
 [1. Pesquisa + verificação]  ──►  setIDs/URLs validados na API (nunca à mão)
        ▼
 [2. Migração SQL]  supabase/migrations/NNN_*.sql  (padrões do gerador, §2)
        ▼
 [3. Gerar pack]  python scripts/generate_airtable_pack.py
        ▼
 [4. Importar no Airtable]  8 tabelas (191/410/436/319/137/396/191/184) — §4
        ▼
 [5. Ligar registos]  python _temp/airtable-pack/link_records_api.py [--run]  — §5
        ▼
 [6. Verificar]  python _temp/airtable-pack/verify_links.py — §6
        ▼
 [7. Commit + push]  (só quando o utilizador pedir) — §7
```

> **Regra de ouro do ciclo:** as migrações SQL são a **fonte única de verdade**.
> O pack CSV é uma **projeção** delas para o Airtable. Editam-se os dados na
> pesquisa (ou na migração) e regenera-se o pack — nunca se edita o CSV à mão
> e se reimporta.

---

## 1. Pesquisa e verificação (regras de fonte)

Lê primeiro as secções 1–2 de `docs/INTERACOES_FLUXO_PESQUISA.md`. Regras que **não mudam**:

1. **Só fontes abertas / domínio público** (NIH/NLM: DailyMed, MedlinePlus, LiverTox; EMA;
   EMC-UK/MHRA). **Nunca** paywalls (NEJM, etc.) nem contas para contornar o acesso.
2. **Fluxo 1 (fármaco-fármaco)**: fonte formal = DailyMed/FDA (setID aprovado). **Fluxo 2
   (alimento/bebida, doença, gestação)**: fonte canónica = **EMC-UK (MHRA)**; Health Canada
   e DailyMed corroboram / cobrem lacunas.
3. **SetIDs nunca fabricados.** Vêm da API DailyMed (`drug_name=<INN inglês>`) e são
   **revalidados** (`?setId=` → n=1) antes de entrarem no SQL.
4. **Conteúdo clínico sempre autoral.** Cita-se a fonte mas nunca se copia o texto dela.
   O Prontuário Terapêutico (INFARMED) só corrobora/cita bibliograficamente.
5. **Sem pares artificiais e omissões honestas**: só pares por relevância clínica
   documentada; se uma dimensão não está em nenhuma fonte aberta, omite-se e regista-se.

---

## 2. Escrever a migração SQL

Aplicar a migração é sempre **manual pelo utilizador** no Supabase (o agente **nunca**
executa migrações). Numeração **com saltos** (`052, 053, …, 062, 065`) — o gerador
descobre as migrações por ordem de ficheiro, logo não precisa de sequência perfeita.

Padrões que o gerador (`generate_airtable_pack.py`) reconhece (semântica do Postgres):

- **INSERT de fármaco novo** (`public.drugs`):
  ```sql
  INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
  VALUES ('x', 'X', 'X', 'Classe', 'Class', ARRAY['yx'], 'published', 10);
  ```
- **INSERT de par fármaco-fármaco novo** (obrigatório `LEAST/GREATEST` por causa do
  `CHECK (drug_a_id < drug_b_id)` e `ON CONFLICT DO NOTHING` para idempotência):
  ```sql
  INSERT INTO public.drug_interactions (drug_a_id, drug_b_id, severity, summary_pt, …,
    source_pt, source_en, status)
  SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id), 'moderate', '…', '…', '…', '…', …,
    'DailyMed/FDA (NIH/NLM) — rótulo aprovado …: <url>', '…', 'published'
  FROM public.drugs a, public.drugs b
  WHERE a.slug = 'x' AND b.slug = 'y'
  ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
  ```
  O gerador também aceita o estilo das migrações 062–069 para pares —
  `INSERT ... SELECT ... FROM (VALUES …) AS v(slug_a, slug_b, …) JOIN public.drugs a
  ON a.slug = v.slug_a …` (a severidade pode vir como `v.severity` ou como literal na
  lista SELECT), e o estilo 083/085/094 — `INSERT ... SELECT ... FROM public.drugs a,
  public.drugs b WHERE a.slug = 'x' AND b.slug = 'y'` com literais na lista SELECT.
  Os campos novos `explanation_pt/en` e `summary_pro_pt/en` são lidos nos três estilos.
- **INSERT das 3 dimensões novas** (fármaco que já existe em `drugs`; `drug_id` resolve-se
  pelo `slug`, com ou sem subscritura `JOIN (VALUES ...)`):
  ```sql
  INSERT INTO public.drug_food_interactions (drug_id, entity_slug, entity_pt, entity_en,
    severity, mechanism_pt, mechanism_en, advice_pt, advice_en, source_pt, source_en, status)
  SELECT d.id, 'sumo_toranja', 'Sumo de toranja', 'Grapefruit', 'moderate', '…', '…', '…', '…',
    'EMC-UK (MHRA) — SmPC aprovada …: <url>', 'EMC-UK (MHRA) — approved SmPC …: <url>',
    'published'
  FROM public.drugs d
  WHERE d.slug = 'atorvastatina'
  ON CONFLICT (drug_id, entity_slug) DO NOTHING;
  ```
  (Idem para `public.drug_disease_interactions` com `condition_slug`/`condition_pt`/`en`,
  `interaction_type`, `reason`, `advice`; e `public.drug_pregnancy_info` 1:1 por `drug_id`.)
- **INSERT de perfil editorial / farmacologia** (tabelas 1:1 com `drugs`;
  `drug_id` resolve-se pelo `slug`):
  ```sql
  INSERT INTO public.drug_profiles (drug_id, overview_public_pt, …)
  SELECT d.id, v.overview_public_pt, … FROM public.drugs d
  JOIN (VALUES ('varfarina', '…', …)) AS v(slug, overview_public_pt, …)
    ON d.slug = v.slug
  ON CONFLICT (drug_id) DO NOTHING;
  ```
  (Idem para `public.drug_pharmacology` com `pharmacodynamics_*`, `mechanism_*`,
  `metabolism_*`, `absorption_*`, `half_life_*`. O gerador junta as duas numa linha
  por fármaco — a 8.ª tabela do pack.)
- **Códigos ATC**: `UPDATE public.drugs SET atc_code = v.atc_code FROM (VALUES …)
  AS v(slug, atc_code) WHERE d.slug = v.slug` (padrão da 084).
- **Correcções de conteúdo**: `UPDATE public.drug_interactions SET severity = …, …
  WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id … WHERE slug='a'), (SELECT id … WHERE
  slug='b')) AND GREATEST(...) = GREATEST(...)` — o `WHERE` é **independente da ordem dos ids**.
  (As explicações longas 097–131 usam `UPDATE … SET explanation_pt/en, summary_pro_pt/en`
  com este mesmo `WHERE`.)

> Convenções de valor (mesmos CHECKs do Postgres → enum no Airtable):
> `estado` = rascunho | em_verificacao | verificado | publicado ·
> `severidade` = critical | moderate | minor | none ·
> `pregnancy_category` = contraindicated | caution | compatible ·
> `tipo_interacao` = contraindication | precaution.

---

## 3. Gerar o pack CSV

```bash
python scripts/generate_airtable_pack.py
```

Faz replay de **todas** as migrações em ordem de ficheiro (descoberta automática) e escreve
**8 ficheiros** em `_temp/airtable-pack/` (o 8.º, `08-perfil-farmacologia.csv`, junta perfil
editorial + farmacologia 1:1 por fármaco). Confere a contagem esperada no README do pack. Se
os números não baterem, uma migração nova não seguiu os padrões do §2 — corrige antes de
avançar.

> O pack é um **replay das migrações em disco**, não um espelho da BD atual: se uma migração
> existir no ficheiro mas não tiver sido aplicada à BD (p. ex., 069/134 nesta BD), os registos
> aparecem no pack mas não na BD — e vice-versa. A fonte única de verdade é o conjunto de
> migrações.

---

## 4. Importar e preparar o Airtable

1. Criar a base: *Create a base* → *Start from scratch*.
2. Importar por CSV (via *Add or import* → *Upload CSV*) **primeiro `Fármacos` e `Fontes`**
   (são os alvos das ligações) e só depois as 5 tabelas de interações. O Airtable usa o nome
   do ficheiro como nome da tabela — **renomear para**:
   - `01-farmacos.csv` → **Fármacos** · `02-fontes.csv` → **Fontes**
   - `03-interacoes-farmaco-farmaco.csv` → **Interações Fármaco-Fármaco**
   - `04-interacoes-alimento-bebida.csv` → **Interações Alimento/Bebida**
   - `05-doencas.csv` → **Doenças** · `06-interacoes-doenca.csv` → **Interações Doença**
   - `07-gravidez-lactacao.csv` → **Gravidez/Lactação**
   - `08-perfil-farmacologia.csv` → **Perfil e Farmacologia**
3. **Campo primário** = `slug` (chave única de cada registo). Verifica o **BOM**: os CSVs
   usam `utf-8-sig`, logo a 1.ª coluna pode vir com um carácter invisível (U+FEFF) no nome.
   Se acontecer, renomeia o campo primário para `slug` limpo (seleciona tudo e apaga antes de
   escrever). O ligador lê pela posição, logo é imune — mas a importação manual não é.

   Na **Perfil e Farmacologia** o campo primário é `slug` (igual a `farmaco_slug`); o campo
   `farmaco_slug` mantém-se como texto (chave de junção).
4. **NÃO converte** os campos `*_slug` (`farmaco_a_slug`, `farmaco_b_slug`, `farmaco_slug`,
   `doenca_slug` **lem-se como texto**) em campos de ligação — a conversão apaga os slugs e
   quebra a chave de junção portável. Mantê-los como texto.

---

## 5. Ligar os registos (relações)

Cria os campos de ligação (*Link to another record*), se ainda não existirem:
- **Interações Fármaco-Fármaco**: `farmaco_a` → Fármacos · `farmaco_b` → Fármacos
- **Interações Alimento/Bebida**: `farmaco` → Fármacos
- **Interações Doença**: `farmaco` → Fármacos · `doenca` → Doenças
- **Gravidez/Lactação**: `farmaco` → Fármacos
- **Perfil e Farmacologia**: `farmaco` → Fármacos

Liga em massa com o ligador REST (prefere-se à extensão Scripting, que na base pendurava em
`selectRecordsAsync`):

```bash
# Cria um PAT com scopes data.records:read, data.records:write, schema.bases:read,
# com acesso só a esta base de pesquisa.
AIRTABLE_BASE_ID=appXXXX AIRTABLE_PAT=patXXXX python _temp/airtable-pack/link_records_api.py        # pré-visualiza
AIRTABLE_BASE_ID=appXXXX AIRTABLE_PAT=patXXXX python _temp/airtable-pack/link_records_api.py --run  # aplica
```

- `AIRTABLE_BASE_ID` = segmento `appXXXX` do URL da base. `AIRTABLE_PAT` = token criado em
  **airtable.com/create/tokens** (scopes acima, acesso só à base de pesquisa).
- **Revoga o PAT quando terminar** (fica visível no histórico da sessão).
- A lista de relações está fixa no script (`RELS`): origem = campo `*_slug` de texto, alvo =
  `Fármacos`/`Doenças`.
- **Formato do valor de ligação**: a API desta base aceita **apenas** o array de strings
  `["recXXXX"]`. O `[{"id":"recXXXX"}]` devolve `INVALID_RECORD_ID`.

---

## 6. Verificar

```bash
AIRTABLE_BASE_ID=appXXXX AIRTABLE_PAT=patXXXX python _temp/airtable-pack/verify_links.py
```

Conta registos de ligação não-vazia por campo e confirma o baseline esperado (384/384/116/198/198/102) — agora com um campo extra: `farmaco` → Fármacos na **Perfil e Farmacologia** (184/184).

---

## 7. Commit / push

O agente só commita/push quando o utilizador pedir. Numa sessão nova, rever o que entra.
**Nunca** incluir o PAT no commit, nem temp build/lint (`_temp/*.exit`, `.freebuff/` (SQLite DB)
nem outros artefactos privados. Incluir: migrações SQL, scripts, docs, pack.

---

## Referências

- Metodologia clínica + padrões SQL completos: `docs/INTERACOES_FLUXO_PESQUISA.md`
- Pack + manual operacional: `_temp/airtable-pack/README.md`
- Gerador: `scripts/generate_airtable_pack.py` · Ligador: `_temp/airtable-pack/link_records_api.py` · Verificação: `_temp/airtable-pack/verify_links.py`