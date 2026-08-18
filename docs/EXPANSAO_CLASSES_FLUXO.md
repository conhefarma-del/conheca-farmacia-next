# Fluxo de Expansão por Classes Terapêuticas

Documento que descreve o método para **expandir systematicamente a base de
dados de fármacos** organizando por **classe terapêutica** e priorizando
pelo **impacto no mercado angolano**.

> **Relação com os fluxos existentes.** Este fluxo é **aditivo e complementar**
> ao Fluxo 1 (INTERACOES_FLUXO_PESQUISA.md). Usa os mesmos padrões SQL,
> fontes e regras de qualidade. A diferença é a **organização do trabalho**:
> em vez de familhas do Prontuário, usa classes do drugs.com como estrutura
> de navegação, e prioriza classes por relevância para Angola.

---

## 1. Princípios

1. **Mesmos padrões de qualidade** — fontes abertas (DailyMed, EMC-UK,
   Health Canada, Prontuário), citações reais, conteúdo autoral,
   migrações idempotentes. Ver secção 1 do INTERACOES_FLUXO_PESQUISA.md.
2. **Organização por classe** — cada classe terapêutica é uma "unidade de
   trabalho". Uma sessão foca-se numa classe (ou subclasse) de cada vez.
3. **Prioridade por impacto** — as classes são ordenadas pelo impacto
   clínico no contexto angolano (prevalência de doenças, disponibilidade
   de medicamentos, orientações OMS).
4. **Cobertura mínima por classe** — cada classe novo exige, no mínimo:
   - Fármacos principais (INN) em `public.drugs` com perfil + farmacologia
   - Pares clinicamente relevantes com fármacos já existentes
   - Dimensões (alimento, doença, gravidez) para os mais relevantes
5. **Referência cruzada** — o drugs.com fornece a estrutura de classes;
   o Prontuário do INFARMED valida a lista de fármacos relevantes para
   o contexto português/angolano; o WHO Essential Medicines List (EML)
   confirma a prioridade de cada classe.

---

## 2. Fonte de classes: drugs.com

A lista completa de classes está em `https://www.drugs.com/drug-classes.html`
(~400 classes). Cada classe liga a uma lista de fármacos que a integram.

**Uso neste fluxo:**
- Mapear quais classes já temos fármacos na BD
- Identificar fármacos ausentes de classes prioritárias
- Cruzar com o WHO EML para confirmar prioridade

---

## 3. Priorização por impacto angolano

### Tier 1 — CRÍTICO (impacto imediato na saúde pública)

| # | Classe | Fármacos-alvo | Justificação |
|---|--------|---------------|--------------|
| 1 | **Antirretrovirais** | TDF, 3TC, DTG, EFV, LPV/r, ABC, NVP, RTV, ATV, RAL, FTC, DOR, OLV | HIV prevalência ~2.8% (UNAIDS 2024); terapêutica ARV é a mais prescrita |
| 2 | **Antimaláricos** | Arteméter, Lumefantrina, Artesunato, SP, Amodiaquina, Cloroquina, Primaquina, Doxiciclina | Malária endémica; 1.º e 2.º escalão OMS |
| 3 | **Antituberculares** | Rifampicina, Isoniazida, Pirazinamida, Etambutol, Estreptomicina, Etionamida, Cicloserina | TB endémica; regime ERIPP |
| 4 | **Antibióticos essenciais** | Amoxicilina, Azitromicina, Ciprofloxacina, Metronidazol, Ceftriaxona, Doxiciclina, Trimetroprim-Sulfametoxazol | Infecções bacterianas mais comuns |
| 5 | **Cardiovasculares** | Enalapril, Losartana, Amlodipina, Hidroclorotiazida, Furosemida, Metoprolol, Espironolactona, Varfarina | Doença cardiovascular crescente |

### Tier 2 — ALTO (cobertura de doenças crónicas)

| # | Classe | Fármacos-alvo | Justificação |
|---|--------|---------------|--------------|
| 6 | **Antidiabéticos** | Metformina, Glibenclamida, Insulina, Glimepirida | Diabetes tipo 2 crescente |
| 7 | **Analgésicos/Anti-inflamatórios** | Paracetamol, Ibuprofeno, Dipirona, Tramadol, Diclofenac, Naproxeno | Uso universal; risco de interações |
| 8 | **Anti-asma/COPD** | Salbutamol, Beclometasona, Montelucaste, Prednisolona, Teofilina | Doença respiratória prevalente |
| 9 | **Antiepilépticos** | Fenitoína, Carbamazepina, Ácido Valproico, Lamotrigina, Levetiracetam, Fenobarbital | Epilepsia; muitas interações |
| 10 | **Antipsicóticos/Antidepressivos** | Haloperidol, Risperidona, Olanzapina, Fluoxetina, Amitriptilina, Sertralina, Escitalopram | Saúde mental subdiagnosticada |

### Tier 3 — MÉDIO (completude terapêutica)

| # | Classe | Fármacos-alvo |
|---|--------|---------------|
| 11 | **Antifúngicos** | Fluconazol, Nistatina, Griseofulvina, Itraconazol, Amfotericina B |
| 12 | **Antivirais (não-HIV)** | Aciclovir, Oseltamivir, Valaciclovir |
| 13 | **Hormônios/Contraceptivos** | Levonorgestrel, Etinilestradiol, Progesterona, Medroxiprogesterona |
| 14 | **Diuréticos** | Espironolactona, Hidroclorotiazida, Furosemida (completar perfis) |
| 15 | **Laxativos/Antidiarréicos** | Lactulose, Bisacodil, Loperamida, Sais de reidratação oral |
| 16 | **Vitaminas/Minerais** | Ácido Fólico, Ferro, Zinco, Vitamina D, Multivitamínicos |

### Tier 4 — BAIXO (completude)

| # | Classe |
|---|--------|
| 17 | Gastrointestinais (PPIs, H2, antiácidos) — já parcialmente cobertos |
| 18 | Dermatológicos tópicos |
| 19 | Oftálmicos/Otic |
| 20 | Outros (antigout, antiespasmódicos, etc.) |

---

## 4. Passo a passo por classe

### Passo 4.1 — Mapear o estado atual

1. Listar os fármacos da classe no drugs.com (ou SmPCs europeias).
2. Cruzar com `public.drugs` (BD atual) → identificar fármacos **ausentes**.
3. Filtrar por **INN inglês com rótulo DailyMed** (sem rótulo = omitir,
   registar no cabeçalho da migração).
4. Consultar o **WHO EML** para confirmar que o fármaco é essencial.

### Passo 4.2 — Definir o lote

1. Escolher 5–15 fármacos da classe (priorizar os mais prescritos em Angola).
2. Para cada fármaco:
   - Confirmar INN inglês
   - Verificar se já existe na BD (slug)
   - Verificar rótulo DailyMed disponível
3. Nota: fármacos **sem rótulo FDA** (ex.: dipirona) são admitidos neste
   fluxo se existirem no Prontuário do INFARMED — usar EMC-UK como fonte
   alternativa. Documentar no cabeçalho.

### Passo 4.3 — Criar perfis (Fluxo 3)

Para cada fármaco novo do lote:
1. Criar INSERT em `public.drugs` (padrão 7.3)
2. Criar perfil em `drug_profiles` (padrão 7.6, secção 13)
3. Criar farmacologia em `drug_pharmacology` (padrão 7.6, secção 13.6)
4. Criar `drug_pregnancy_info` se não existir (Fluxo 2, secção 12.5)

### Passo 4.4 — Criar pares de interação (Fluxo 1)

1. Identificar parceiros **já existentes** na BD (cross-class pairs).
2. Identificar parceiros **da mesma classe** (intra-class pairs) — apenas
   se clinicamente relevantes (ex.: dois antiepilépticos com interação
   documentada).
3. Para cada par: setID validado, severidade, citação, resumo (padrão 7.4).
4. **Regra de ouro**: sem pares artificiais. Se a classe tem poucas
   interações reais, gera-se poucos pares.

### Passo 4.5 — Criar dimensões (Fluxo 2)

Para os fármacos mais relevantes da classe:
1. Interações alimento/bebida (EMC-UK como fonte canónica)
2. Interações doença/condição
3. Gravidez/lactação (já coberto no Passo 4.3 se `drug_pregnancy_info`)

### Passo 4.6 — Explicações longas (Fluxo 4)

Para os pares novos critical/moderate:
1. `summary_pro_pt/en` (resumo profissional)
2. `explanation_pt/en` (explicação longa com mecanismo)

### Passo 4.7 — Gerar migração

Uma sessão = uma classe = **1–3 migrações**:
- **Migração A**: INSERT de fármacos novos + perfis + farmacologia
- **Migração B**: Pares de interação (drug_interactions)
- **Migração C** (opcional): Dimensões + explicações longas

### Passo 4.8 — Validar e entregar

1. Validação estrutural (secção 8 do INTERACOES_FLUXO_PESQUISA.md)
2. O utilizador aplica no Supabase
3. Revalidar cache: `./revalidar.sh interacoes`

---

## 5. Schema de uma sessão típica

Cada sessão de trabalho gera:
- **1 ficheiro de migração** (ou 2-3 se a classe é grande)
- **1 atualização do INTERACOES_FLUXO_PESQUISA.md** (registo da classe concluída)
- **1 atualização deste documento** (marcar classe como concluída na tabela de progresso)

Formato do nome da migração:
```
{N}_expansao_{slug_da_classe}.sql
```
Exemplo: `191_expansao_antirretrovirais.sql`

---

## 6. Tabela de progresso

| # | Classe | Tier | Fármacos | Pares | Dimensões | Perfil | Estado |
|---|--------|------|----------|-------|-----------|--------|--------|
| 1 | Antirretrovirais | 1 | 17/25 | 13 | 11 | 11 | ✅ 191-193 |
| 2 | Antimaláricos | 1 | —/10 | — | — | — | ⏳ Pendente |
| 3 | Antituberculares | 1 | 14/10 | 8 | 5 | 7 | ✅ 195-197 |
| 4 | Antibióticos essenciais | 1 | —/30 | — | — | — | ⏳ Pendente |
| 5 | Cardiovasculares | 1 | —/25 | — | — | — | ⏳ Pendente |
| 6 | Antidiabéticos | 2 | —/10 | — | — | — | ⏳ Pendente |
| 7 | Analgésicos/Anti-inflamatórios | 2 | —/15 | — | — | — | ⏳ Pendente |
| 8 | Anti-asma/COPD | 2 | —/8 | — | — | — | ⏳ Pendente |
| 9 | Antiepilépticos | 2 | —/10 | — | — | — | ⏳ Pendente |
| 10 | Antipsicóticos/Antidepressivos | 2 | —/15 | — | — | — | ⏳ Pendente |
| 11 | Antifúngicos | 3 | —/8 | — | — | — | ⏳ Pendente |
| 12 | Antivirais (não-HIV) | 3 | —/6 | — | — | — | ⏳ Pendente |
| 13 | Hormônios/Contraceptivos | 3 | —/10 | — | — | — | ⏳ Pendente |
| 14 | Diuréticos | 3 | —/6 | — | — | — | ⏳ Pendente |
| 15 | Laxativos/Antidiarréicos | 3 | —/6 | — | — | — | ⏳ Pendente |
| 16 | Vitaminas/Minerais | 3 | —/8 | — | — | — | ⏳ Pendente |

---

## 7. Lições aprendidas (aditivas ao INTERACOES_FLUXO_PESQUISA.md)

1. **Dipirona não tem rótulo DailyMed** — usar EMC-UK (metamizole) como
   fonte. O Prontuário INFARMED documenta o dipirona como止痛剂 essencial.
2. **Fármacos OTC** (paracetamol, ibuprofeno) têm secções simplificadas
   no DailyMed — usar secções próprias (Purpose/Use/Warnings) e corroborar
   com Prontuário.
3. **Insulina** não tem setID DailyMed convencional — tratar como caso
   especial (usar EMC-UK ou Humalog/NovoRapid como referência).
4. **Fármacos genéricos** — o DailyMed pode ter múltiplos rótulos para o
   mesmo INN. Escolher o genérico mais comum (dosagem habitual) e validar
   o setID.
5. **WHO EML como filtro** — se um fármaco não está no EML e não é
   amplamente usado em Angola, descer na prioridade.
6. **Classes com muitos fármacos** (antibióticos, cardiovascular) — dividir
   em sub-sessões por subclasse (ex.: penicilinas, cefalosporinas,
   macrólidos) para manter as migrações gerenciáveis.

---

## 8. Integração com os fluxos existentes

| Fluxo | Papel neste fluxo |
|-------|-------------------|
| **Fluxo 1** (pares) | Criar pares entre fármacos novos e existentes |
| **Fluxo 2** (dimensões) | Preencher alimento/doença/gravidez dos fármacos novos |
| **Fluxo 3** (perfis) | Criar perfil + farmacologia de cada fármaco novo |
| **Fluxo 4** (explicações) | Preencher summary_pro + explanation dos pares novos |
| **Fluxo 5** (Airtable) | Regenerar pack após cada classe concluída |
| **Fluxo 6** (perfis tópicos) | Aplicar a fármacos tópicos desta classe (se aplicável) |
| **Este fluxo** | Organizar, priorizar e orquestrar os fluxos 1–4 por classe |
