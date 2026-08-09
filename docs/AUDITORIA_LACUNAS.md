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
| **Explicação nos pares** (explanation + summary_pro) | 69 pares | **333 pares** |
| Perfil `drug_profiles` | **182 fármacos (todos completos e publicados)** | 0 ✅ |
| Farmacologia `drug_pharmacology` | **182 fármacos (086 + 088 + 091 + 092 + 093 + 094 + 095 + 096)** | 0 ✅ |
| 3 dimensões (alim + doença + gestação) | 87 fármacos completos | 95 fármacos com ≥1 dimensão em falta |

## Pares sem explicação, por severidade (402 pares publicados no total)

| Severidade | Total | Com explicação | **Sem explicação** |
|---|---|---|---|
| critical | 21 | 21 | **0** ✅ |
| moderate | 366 | 47 | **319** |
| minor | 12 | 1 | **11** |
| none | 3 | 0 | **3** |

## Prioridade sugerida para preencher lacunas

1. ~~**18 pares críticos sem explicação**~~ → **concluído com a 089** (explicação longa + resumo profissional, PT/EN).
2. **319 pares moderados sem explicação** — começar pelos fármacos de topo.
3. ~~**Farmacologia** — alargar a 086 aos 36 fármacos com perfil~~ → **concluído com a 088** (todos os 30 fármacos com perfil sem farmacologia preenchidos). ~~Sem perfil, com mais pares~~ → **lote 091** (claritromicina, rifampicina, cetoconazol, itraconazol, aspirina) → **lote 092** (os 25 restantes da 090: antiácidos, voriconazol, cloroquina, fluconazol, sertralina, dexametasona, fluoxetina, quinina, lítio, mefloquina, ritonavir, isoniazida, arteméter+lumefantrina, cotrimoxazol, hidroclorotiazida, hidroxicloroquina, tramadol, diidroartemisinina+piperaquina, clopidogrel, diclofenac, eritromicina, naproxeno, teofilina, alprazolam, adrenalina). **Faltam 116** (a maioria sem perfil).
4. ~~**Perfis** — criar para os 146 restantes~~ → **lote 1 concluído com a 090** (30 fármacos com mais pares) → **lote 2 concluído com a 093** (26 seguintes por nº de pares) → **lote 3 concluído com a 094** (30 seguintes por nº de pares: nitroglicerina, paracetamol, praziquantel, valsartana, vancomicina, sulfadoxina-pirimetamina, ampicilina, lamotrigina, haloperidol, clozapina, ácido fólico, amicacina, azitromicina, bumetanida, buprenorfina, celecoxib, codeína, desloratadina, domperidona, doxiciclina, fexofenadina, ferro, fentanilo, flecainida, gentamicina, leflunomida, loratadina, metamizol, metoclopramida, febuxostat — perfis + farmacologia na mesma migração) → **lote 4 concluído com a 095** (30 seguintes por nº de pares: morfina, moxifloxacina, nevirapina, orlistat, sulfassalazina, tobramicina, acetazolamida, ácido tranexâmico, amoxicilina, amoxicilina+clavulanato, atovaquona+proguanil, budesonida, ceftazidima, ceftriaxona, cetirizina, cianocobalamina, daptomicina, donepezilo, epoetina alfa, etambutol, fitomenadiona, formoterol, fosfomicina, hidromorfona, indapamida, lamivudina, levocetirizina, loperamida, losartano, mesalazina — perfis + farmacologia na mesma migração) → **lote 5 concluído com a 096** (os últimos 30 sem perfil — 0 pares: acetilcisteína, ácido ursodesoxicolico, artesunato, benzilpenicilina benzatina, butilbrometo de hioscina, cefalexina, cefazolina, cefepima, cefotaxima, cefuroxima, etilefrina, famotidina, fenoximetilpenicilina, filgrastim, fondaparinux, ipratrópio, memantina, midodrina, montelucaste, nistatina, ondansetrom, piperacilina+tazobactam, pirazinamida, poractanto alfa, primaquina, propafenona, salmeterol, tafenoquina, tiotrópio, zidovudina — perfis + farmacologia na mesma migração). **Completos: 182/182** ✅
5. **Dimensões** — preencher as 95 faltantes.

---

## 1. Pares CRÍTICOS — explicações preenchidas (18, migração 089)

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

## 3. Farmacologia — 36 fármacos (086 + 088)

**086 (piloto, 6):** warfarina, ibuprofeno, ramipril, espironolactona, sotalol, furosemida.

**088 (extensão, 30 — todos os fármacos com perfil que faltavam):** amiodarona,
amlodipina, anastrozol, atorvastatina, carbamazepina, ciprofloxacina, digoxina,
doxazosina, dutasterida, estradiol, fenitoína, finasterida, glibenclamida, gliclazida,
glimepirida, levonorgestrel, levotiroxina, metformina, metronidazol, nitrofurantoína,
omeprazol, pioglitazona, prednisolona, sildenafil, tadalafil, tamoxifeno, tansulosina,
tiamazol, valproato, vardenafil.

Fontes: secção 12 CLINICAL PHARMACOLOGY dos rótulos DailyMed (setIDs na migração),
SmPC EMC-UK para a gliclazida e PubMed (PMID 6172233 / 15745981) para o tiamazol.

**091 (sem perfil, com mais pares — 5):** claritromicina, rifampicina, cetoconazol,
itraconazol (secção 12 CLINICAL PHARMACOLOGY dos rótulos DailyMed, setIDs iguais aos
perfis da 090) e aspirina (revisão clássica de farmacocinética dos salicilatos,
Levy G. Clin Pharmacokinet 1985, PMID 3888490 — os rótulos OTC não têm secção 12).

**092 (perfis da 090 sem farmacologia — 25):** antiácidos, voriconazol, cloroquina,
fluconazol, sertralina, dexametasona, fluoxetina, quinina, lítio, mefloquina, ritonavir,
isoniazida, arteméter+lumefantrina, cotrimoxazol, hidroclorotiazida, hidroxicloroquina,
tramadol, diidroartemisinina+piperaquina, clopidogrel, diclofenac, eritromicina,
naproxeno, teofilina, alprazolam, adrenalina. Fontes: secção 12 CLINICAL PHARMACOLOGY
dos rótulos DailyMed (setIDs na migração); diidroartemisinina+piperaquina pela SmPC
européia EMA (Eurartesim, secção 5.2); antiácidos pelo Prontuário Terapêutico do
INFARMED (6.2.1 — os rótulos OTC não têm secção 12).

Com a 092, **todos os 30 fármacos da 090 ficam com perfil + farmacologia**.

**093 (26 fármacos sem perfil com mais pares — perfil + farmacologia na mesma
migração):** alendronato, alopurinol, apixabano, artesunato+amodiaquina, atazanavir,
azatioprina, bedaquilina, calcitriol, captopril, colchicina, dabigatrano,
dextrometorfano, difenidramina, efavirenz, enalapril, enoxaparina, estreptomicina,
fenobarbital, levofloxacina, linezolida, metotrexato, pseudoefedrina, rifabutina,
rivaroxabano, salbutamol, sucralfato. Fontes: secção 12 CLINICAL PHARMACOLOGY dos
rótulos DailyMed (setIDs na migração); pseudoefedrina/dextrometorfano/difenidramina
(rótulos OTC sem secção 12) pela farmacocinética PubMed (PMID 7507589/7438686,
7593709/8841152, 3760245/2391399); salbutamol (MDI sem farmacocinética formal) por
PubMed (PMID 3653233/1457264); artesunato+amodiaquina pela SmPC WHO-prequalificada
(MA102, secção 5.2).

**094 (30 fármacos sem perfil com mais pares — perfil + farmacologia na mesma
migração):** nitroglicerina, paracetamol, praziquantel, valsartana, vancomicina,
sulfadoxina-pirimetamina, ampicilina, lamotrigina, haloperidol, clozapina, ácido
fólico, amicacina, azitromicina, bumetanida, buprenorfina, celecoxib, codeína,
desloratadina, domperidona, doxiciclina, fexofenadina, ferro, fentanilo, flecainida,
gentamicina, leflunomida, loratadina, metamizol, metoclopramida, febuxostat. Fontes:
secção 12 CLINICAL PHARMACOLOGY dos rótulos DailyMed (setIDs na migração);
sulfadoxina-pirimetamina pela SmPC WHO-prequalificada (MA193, secção 5.2);
domperidona pela SmPC europeia Motilium (secção 5.2); fexofenadina/ferro/loratadina
(rótulos OTC sem secção 12) pela farmacocinética PubMed (PMC11677975, PMID
26289639/29032957, 12169042); metamizol por Levy et al. 1995 (PMID 7758252). Com a
094, **122 fármacos têm perfil + farmacologia**.

**095 (30 fármacos sem perfil com mais pares — perfil + farmacologia na mesma
migração):** morfina, moxifloxacina, nevirapina, orlistat, sulfassalazina, tobramicina,
acetazolamida, ácido tranexâmico, amoxicilina, amoxicilina+clavulanato,
atovaquona+proguanil, budesonida, ceftazidima, ceftriaxona, cetirizina,
cianocobalamina, daptomicina, donepezilo, epoetina alfa, etambutol, fitomenadiona,
formoterol, fosfomicina, hidromorfona, indapamida, lamivudina, levocetirizina,
loperamida, losartano, mesalazina. Fontes: secção 12 CLINICAL PHARMACOLOGY dos
rótulos DailyMed (setIDs na migração); cetirizina/levocetirizina (rótulos OTC sem
secção 12) pela farmacocinética PubMed (PMID 8477559 e 11758635); cianocobalamina
pelo rótulo DailyMed de injeção + revisão PMC9822362. Com a 095, **152 fármacos têm
perfil + farmacologia**.

**096 (lote 5, final — os últimos 30 sem perfil, 0 pares — perfil + farmacologia na
mesma migração):** acetilcisteína, ácido ursodesoxicolico, artesunato,
benzilpenicilina benzatina, butilbrometo de hioscina, cefalexina, cefazolina, cefepima,
cefotaxima, cefuroxima, etilefrina, famotidina, fenoximetilpenicilina, filgrastim,
fondaparinux, ipratrópio, memantina, midodrina, montelucaste, nistatina, ondansetrom,
piperacilina+tazobactam, pirazinamida, poractanto alfa, primaquina, propafenona,
salmeterol, tafenoquina, tiotrópio, zidovudina. Fontes: secção 12 CLINICAL
PHARMACOLOGY dos rótulos DailyMed (setIDs na migração); artesunato pela SmPC-padrão
WHO-prequalificada (MA152); butilbrometo de hioscina pela SmPC Buscopan (EMC-UK,
product 1775); etilefrina por Hengstmann 1975 (PMID 9300). Com a 096, **182 fármacos
têm perfil + farmacologia — cobertura total** ✅.

## 4. Perfis — 182 fármacos

**080/081 (piloto + lote 2):** warfarina, ibuprofeno, ramipril, espironolactona, sotalol,
+ 12 (ver migração 081).

**083 (secao7) / 085 (secao8):** fármacos das secções 7 e 8 do Prontuário (ver migrações).

**090 (lote 1 — 30 fármacos com mais pares):** rifampicina, claritromicina, cetoconazol,
antiácidos, itraconazol, aspirina, voriconazol, cloroquina, fluconazol, sertralina,
dexametasona, fluoxetina, quinina, lítio, mefloquina, ritonavir, isoniazida,
arteméter+lumefantrina, cotrimoxazol, hidroclorotiazida, hidroxicloroquina, tramadol,
diidroartemisinina+piperaquina, clopidogrel, diclofenac, eritromicina, naproxeno,
teofilina, alprazolam, adrenalina.

Fontes: secções INDICATIONS/ADVERSE REACTIONS/CONTRAINDICATIONS/WARNINGS dos rótulos
DailyMed (setIDs na migração); diidroartemisinina+piperaquina pela SmPC europeia EMA
(Eurartesim).

**095 (lote 4 — 30 fármacos sem perfil com mais pares):** morfina, moxifloxacina,
nevirapina, orlistat, sulfassalazina, tobramicina, acetazolamida, ácido tranexâmico,
amoxicilina, amoxicilina+clavulanato, atovaquona+proguanil, budesonida, ceftazidima,
ceftriaxona, cetirizina, cianocobalamina, daptomicina, donepezilo, epoetina alfa,
etambutol, fitomenadiona, formoterol, fosfomicina, hidromorfona, indapamida,
lamivudina, levocetirizina, loperamida, losartano, mesalazina. Fontes: secções
INDICATIONS/ADVERSE/CONTRAINDICATIONS/WARNINGS + secção 12 CLINICAL PHARMACOLOGY dos
rótulos DailyMed (setIDs na migração); cetirizina/levocetirizina pela farmacocinética
PubMed (PMID 8477559, 11758635); cianocobalamina pelo rótulo DailyMed de injeção +
revisão PMC9822362.

**096 (lote 5, final — os últimos 30 sem perfil, 0 pares):** acetilcisteína, ácido
ursodesoxicolico, artesunato, benzilpenicilina benzatina, butilbrometo de hioscina,
cefalexina, cefazolina, cefepima, cefotaxima, cefuroxima, etilefrina, famotidina,
fenoximetilpenicilina, filgrastim, fondaparinux, ipratrópio, memantina, midodrina,
montelucaste, nistatina, ondansetrom, piperacilina+tazobactam, pirazinamida,
poractanto alfa, primaquina, propafenona, salmeterol, tafenoquina, tiotrópio,
zidovudina. Fontes: secções INDICATIONS/ADVERSE/CONTRAINDICATIONS/WARNINGS + secção
12 CLINICAL PHARMACOLOGY dos rótulos DailyMed (setIDs na migração); artesunato pela
SmPC-padrão WHO-prequalificada (MA152); butilbrometo de hioscina pela SmPC Buscopan
(EMC-UK, product 1775); etilefrina por Hengstmann 1975 (PMID 9300).

✅ **Cobertura total: 182/182 fármacos com perfil + farmacologia.**

## 5. Fármacos sem perfil — próximos lotes (prioridade por nº de pares)

Os lotes seguintes (de 30 em 30) são calculados dinamicamente na sessão de preenchimento
(consulta read-only à BD: fármacos sem perfil ordenados por nº de pares decrescente),
como foi feito para o lote 1 da 090.

## 6. Fármacos sem qualquer conteúdo (0 pares, sem perfil, sem farmacologia)

~~24 fármacos — a maioria com dimensões parciais~~ → **concluído com a 096**: todos os
fármacos com 0 pares ficaram com perfil + farmacologia completos. ✅

---

Ficheiro de apoio com a matriz completa (um linha por fármaco): consulta gerada
na sessão (ver `drugs` × pares/perfil/farmacologia/dimensões).
