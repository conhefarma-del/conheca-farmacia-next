# Plano: Expansão da Base de Dados por Classes Terapêuticas

**Data:** 2026-08-18
**Estado:** Pendente de aprovação
**Fluxo associado:** `docs/EXPANSAO_CLASSES_FLUXO.md`
**Migração de referência:** 190 (latest)

---

## Contexto

A base de dados do Conheça Farmácia tem **226 fármacos**, cobrindo
principalmente cardiovascular, anti-infecciosos (parcial), analgésicos e
alguns antiepilépticos. Faltam classes críticas para o contexto angolano,
sobretudo **antirretrovirais** (HIV), **antimaláricos** e **antidepressivos**.

O plano anterior (INTERACOES_FLUXO_PESQUISA.md) organizava por famílias do
Prontuário. O novo fluxo (EXPANSAO_CLASSES_FLUXO.md) organiza por classes
terapêuticas do drugs.com, priorizando pelo impacto no mercado angolano.

---

## Objetivo

Expandir de **226 para ~500+ fármacos** cobrindo as 16 classes prioritárias,
com perfis completos, interações clinicamente relevantes e dimensões
(alimento/doença/gravidez) para os fármacos mais impactantes.

---

## Fases de execução

### Fase 1: Tier 1 — CRÍTICO (4-6 semanas)

| Classe | Fármacos | Migrações estimadas |
|--------|----------|---------------------|
| Antirretrovirais | ~25 | 3-4 |
| Antimaláricos | ~10 | 2 |
| Antituberculares | ~10 | 2 |
| Antibióticos essenciais | ~30 | 4-5 |
| Cardiovasculares | ~25 | 3-4 |

**Entrega esperada:** ~100 fármacos novos + ~300 pares + dimensões

### Fase 2: Tier 2 — ALTO (3-4 semanas)

| Classe | Fármacos | Migrações estimadas |
|--------|----------|---------------------|
| Antidiabéticos | ~10 | 2 |
| Analgésicos/Anti-inflamatórios | ~15 | 2-3 |
| Anti-asma/COPD | ~8 | 1-2 |
| Antiepilépticos | ~10 | 2 |
| Antipsicóticos/Antidepressivos | ~15 | 2-3 |

**Entrega esperada:** ~60 fármacos novos + ~200 pares + dimensões

### Fase 3: Tier 3 — MÉDIO (2-3 semanas)

| Classe | Fármacos | Migrações estimadas |
|--------|----------|---------------------|
| Antifúngicos | ~8 | 1-2 |
| Antivirais (não-HIV) | ~6 | 1 |
| Hormônios/Contraceptivos | ~10 | 2 |
| Diuréticos | ~6 | 1 |
| Laxativos/Antidiarréicos | ~6 | 1 |
| Vitaminas/Minerais | ~8 | 1-2 |

**Entrega esperada:** ~45 fármacos novos + ~100 pares + dimensões

---

## Para cada sessão de classe

1. **Mapear** — drugs.com + Prontuário → lista de INN
2. **Filtrar** — WHO EML + DailyMed disponível
3. **Criar fármacos** — INSERT em `drugs` (padrão 7.3)
4. **Criar perfis** — `drug_profiles` + `drug_pharmacology` (Fluxo 3)
5. **Criar pares** — interações com fármacos existentes (Fluxo 1)
6. **Criar dimensões** — alimento/doença/gravidez (Fluxo 2)
7. **Explicações** — summary_pro + explanation (Fluxo 4)
8. **Validar** — greps estruturais + queries de verificação
9. **Aplicar** — utilizador aplica no Supabase + revalidar cache

---

## Métricas de sucesso

| Métrica | Atual | Meta |
|---------|-------|------|
| Fármacos na BD | 226 | 500+ |
| Classes cobertas | ~8 | 16 |
| Pares com explicação | 551 | 1000+ |
| Fármacos sem interações | 12 | <5 |

---

## Riscos e mitigação

| Risco | Mitigação |
|-------|-----------|
| Fármacos sem rótulo DailyMed | Usar EMC-UK; documentar no cabeçalho |
| Migrações muito grandes | Dividir por subclasse (ex.: penicilinas, cefalosporinas) |
| Dados inconsistentes | Validação cruzada entre fontes; !important só com justificação |
| Tempo excessivo | Priorizar Tier 1; Tier 3 pode ser adiado |

---

## Próximos passos

1. Aprovar o fluxo e este plano
2. Começar pela **classe 1: Antirretrovirais** (maior impacto)
3. Iterar por classe, registando progresso em `EXPANSAO_CLASSES_FLUXO.md`
