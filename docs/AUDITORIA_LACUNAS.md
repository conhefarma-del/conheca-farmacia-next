# Auditoria de Lacunas — Conteúdo dos Fármacos

Data: 2026-08-08 · Fonte: consulta read-only à base de dados (service role), estado aplicado.

Objetivo: identificar os fármacos que precisam de informação completa em cada dimensão —
explicação fármaco–fármaco (`drug_interactions.explanation_*/summary_pro_*`),
perfil da ficha `/medicamento/[slug]` (`drug_profiles`) e farmacologia
(`drug_pharmacology`), além das dimensões alimento/doença/gestação.

## Resumo global (182 fármacos publicados)

| Dimensão | Preenchido | Em falta |
|---|---|---|
| Pares fármaco–fármaco | 158 fármacos com ≥1 par | 24 fármacos sem qualquer par |
| **Explicação nos pares** (explanation + summary_pro) | 51 pares | **351 pares** |
| Perfil `drug_profiles` | 36 fármacos (todos completos e publicados) | 146 fármacos |
| Farmacologia `drug_pharmacology` | 6 fármacos (086) | 176 fármacos |
| 3 dimensões (alim + doença + gestação) | 87 fármacos completos | 95 fármacos com ≥1 dimensão em falta |

## Pares sem explicação, por severidade (402 pares publicados no total)

| Severidade | Total | Com explicação | **Sem explicação** |
|---|---|---|---|
| critical | 21 | 3 | **18** |
| moderate | 366 | 47 | **319** |
| minor | 12 | 1 | **11** |
| none | 3 | 0 | **3** |

## Prioridade sugerida para preencher lacunas

1. **18 pares críticos sem explicação** (urgente — contraindicações/risco grave).
2. **319 pares moderados sem explicação** — começar pelos fármacos de topo.
3. **Farmacologia** — alargar a 086 aos 36 fármacos com perfil (os mais visitados).
4. **Perfis** — criar para os 146 restantes, priorizando os com mais pares.
5. **Dimensões** — preencher as 95 faltantes.

---

## 1. Pares CRÍTICOS sem explicação (18)

| Par |
|---|
| Alprazolam + Morfina |
| Alprazolam + Codeína |
| Alprazolam + Hidromorfona |
| Azatioprina + Alopurinol |
| Azatioprina + Febuxostat |
| Claritromicina + Carbamazepina |
| Claritromicina + Domperidona |
| Colchicina + Claritromicina |
| Espironolactona + Enalapril |
| Fluoxetina + Sertralina |
| Ibuprofeno + Warfarina |
| Linezolida + Fluoxetina |
| Linezolida + Sertralina |
| Linezolida + Tramadol |
| Nitroglicerina + Sildenafil |
| Rifampicina + Arteméter + Lumefantrina |
| Sotalol + Hidroclorotiazida |
| Warfarina + Ácido acetilsalicílico |

## 2. Top fármacos com mais pares SEM explicação

| Fármaco | Pares sem explicação |
|---|---|
| Warfarina | 46 |
| Digoxina | 22 |
| Claritromicina | 20 |
| Amiodarona | 20 |
| Carbamazepina | 18 |
| Ibuprofeno | 17 |
| Rifampicina | 17 |
| Ciprofloxacina | 15 |
| Cetoconazol | 15 |
| Omeprazol | 14 |
| Antiácidos | 14 |
| Itraconazol | 13 |
| Ácido acetilsalicílico | 12 |
| Cloroquina | 12 |
| Voriconazol | 12 |

## 3. Farmacologia (086) — só 6 fármacos

warfarina, ibuprofeno, ramipril, espironolactona, sotalol, furosemida.

Próximo alvo natural: os restantes fármacos com perfil completo (36 − 6 = 30),
incluindo os lotes da secção 8 (tiamazol, glimepirida, gliclazida, pioglitazona,
levonorgestrel, estradiol, tamoxifeno, anastrozol) e da secção 7 (nitrofurantoína,
tadalafil, vardenafil, tansulosina, doxazosina, finasterida, dutasterida, sildenafil).

## 4. Fármacos sem perfil com mais pares (prioridade de perfil)

claritromicina (23), rifampicina (23), cetoconazol (22), antiácidos (15),
itraconazol (14), aspirina (13), cloroquina (12), voriconazol (12), fluconazol (11),
sertralina (11), dexametasona (10), fluoxetina (10), quinina (10), lítio (9),
mefloquina (8), ritonavir (8), cotrimoxazol (7), isoniazida (7), tramadol (7), …

## 5. Fármacos sem qualquer conteúdo (0 pares, sem perfil, sem farmacologia)

24 fármacos — a maioria com dimensões parciais: acetilcisteína, ácido ursodesoxicólico,
artesunato, benzilpenicilina benzatínica, ipratrópio, butilbrometo de hioscina, cefalexina,
cefazolina, cefepima, cefotaxima, cefuroxima, etilefrina, famotidina, fenoximetilpenicilina,
filgrastim, fondaparinux, memantina, montelucaste, nistatina, pirazinamida, poractanto alfa,
primaquina, tafenoquina, tiotrópio.

---

Ficheiro de apoio com a matriz completa (um linha por fármaco): consulta gerada
na sessão (ver `drugs` × pares/perfil/farmacologia/dimensões).
