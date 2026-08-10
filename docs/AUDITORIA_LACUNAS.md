# Auditoria de Lacunas — Conteúdo dos Fármacos

Data: 2026-08-08 · Fonte: consulta read-only à base de dados (service role), estado aplicado.

Objetivo: identificar os fármacos que precisam de informação completa em cada dimensão —
explicação fármaco–fármaco (`drug_interactions.explanation_*/summary_pro_*`),
perfil da ficha `/medicamento/[slug]` (`drug_profiles`) e farmacologia
(`drug_pharmacology`), além das dimensões alimento/doença/gestação.

## Resumo global (182 fármacos publicados)

| Dimensão | Preenchido | Em falta |
|---|---|---|
| Pares fármaco–fármaco | 159 fármacos com ≥1 par (134: benzilpenicilina-benzatina) | 23 fármacos sem qualquer par |
| **Explicação nos pares** (explanation + summary_pro) | 69 pares | **333 pares** |
| Perfil `drug_profiles` | **182 fármacos (todos completos e publicados)** | 0 ✅ |
| Farmacologia `drug_pharmacology` | **182 fármacos (086 + 088 + 091 + 092 + 093 + 094 + 095 + 096 + 132)** | 0 ✅ |
| 3 dimensões (alim + doença + gestação) | 138 + 29 (109) + 15 (110) = **182 completos** ✅ | **0 fármacos em falta** ✅ |

## Pares sem explicação, por severidade (402 pares publicados no total)

| Severidade | Total | Com explicação | **Sem explicação** |
|---|---|---|---|
| critical | 21 | 21 | **0** ✅ |
| moderate | 366 | 47 + 44 (097/098) + 22 (100) + 18 (103) + 17 (104) + 16 (105) + 12 (106) + 15 (107) + 14 (108) + 11 (112) + 10 (113) + 9 (114) + 9 (115) + 8 (117) + 8 (118) + 5 (119) + 6 (120) + 5 (121) + 5 (122) + 5 (123) + 3 (124) + 3 (125) + 3 (126) + 5 (127) + 3 (128) + 19 (129) + 20 (130) + 17 (131) | **0** ✅ |
| minor | 12 | 1 + 11 (111) | **0** ✅ |
| none | 3 | 0 + 3 (111) | **0** ✅ |

## Prioridade sugerida para preencher lacunas

1. ~~**18 pares críticos sem explicação**~~ → **concluído com a 089** (explicação longa + resumo profissional, PT/EN).
2. **319 pares moderados sem explicação** — começar pelos fármacos de topo → **lote warfarina concluído com a 097/098** (44 pares: anti-infeciosos/antimaláricos/antirretrovíricos + AINEs/cardiovasculares/hormonas/antiepiléticos; padrão da 089 com LEAST/GREATEST canónico) → **lote digoxina concluído com a 100** (22 pares: substrato da P-gp/CYP3A4 com janela terapêutica estreita — amiodarona, verapamilo, espironolactona, betabloqueadores, AINEs, macrólidos, azóis, etc.) → **lote amiodarona concluído com a 103** (18 pares: QT aditivo com antimaláricos/azóis/fluoroquinolonas/bedaquilina, inibição do CYP3A4 (azóis), indução (rifampicina/rifabutina), CYP2D6 (flecainida), bidirecional com fenitoína, simpaticomimético com pseudoefedrina) → **lote carbamazepina concluído com a 104** (17 pares: indutor potente do CYP3A4 — reduz níveis de antimaláricos/antipsicóticos/teofilina/efavirenz; inibidores do CYP3A4 (azóis, isoniazida, ritonavir) elevam a carbamazepina; bidirecional com lamotrigina e voriconazol) → **lote claritromicina concluído com a 105** (16 pares: inibidor do CYP3A4/P-gp — alprazolam, atorvastatina, budesonida, loperamida, teofilina, dexametasona; QT aditivo com antimaláricos/bedaquilina/cloroquina/hidroxicloroquina; bidirecional com rifabutina e efavirenz) → **lote rifampicina concluído com a 106** (12 pares restantes: indutor potente do CYP3A4 — atorvastatina, bedaquilina, doxiciclina, fluconazol, itraconazol, linezolida, omeprazol, praziquantel, prednisolona, sildenafil, voriconazol, cetoconazol; amiodarona e carbamazepina já cobertos nas 103/104) → **lote ibuprofeno concluído com a 107** (15 pares: AINE não seletivo — anticoagulantes/DOACs (apixabano, dabigatrano, rivaroxabano — hemorragia aditiva), AINE+AINE (celecoxib, diclofenac, naproxeno), corticosteroides (dexametasona, prednisolona — úlcera/hemorragia GI), IECA (enalapril — função renal/TA), lítio e metotrexato (redução da depuração renal), estreptomicina (nefrotoxicidade), levofloxacina (SNC/convulsões), alendronato (GI alta), paracetamol (uso prolongado renal/GI)) → **lote antiácidos concluído com a 108** (14 pares: quelação/adsorção dos catiões Al/Mg/Ca — ciprofloxacina, levofloxacina, moxifloxacina, doxiciclina, alendronato, levotiroxina; pH gástrico elevado — cetoconazol, itraconazol, atazanavir; absorção reduzida — cloroquina, etambutol, fosfomicina; interferência local — sucralfato, omeprazol) → **minor/none concluído com a 111** (11 minor: ácido fólico+ciprofloxacina, adrenalina+ciprofloxacina (QT teórico), alopurinol+febuxostat, aspirina+hidroxicloroquina (GI aditivo), aspirina+ibuprofeno (interfere com a aspirina), calcitriol+furosemida, cianocobalamina+omeprazol, difenidramina+sertralina (sedação), fluoxetina+pseudoefedrina, glibenclamida+metformina, pseudoefedrina+sertralina; 3 none: amlodipina+captopril, amlodipina+enalapril, espironolactona+hidroclorotiazida — associações sem interação adversa relevante) → **lote ciprofloxacina concluído com a 112** (11 pares: QT aditivo com antimaláricos (arteméter+lumefantrina, diidroartemisinina+piperaquina, mefloquina, quinina), cloroquina, bedaquilina e domperidona; quelação com ferro e sucralfato (2h/6h); inibição do CYP1A2 (teofilina ~30–40%); redução da depuração renal do metotrexato) → **lote omeprazol concluído com a 113** (10 pares: pH gástrico elevado — cetoconazol, itraconazol, atazanavir (~75%), cloroquina, ferro, levotiroxina, alendronato; inibição do CYP2C19 — clopidogrel (evitar, preferir pantoprazol/H2) e fenitoína; bidirecional com voriconazol — reduzir dose do omeprazol para metade) → **lote aspirina concluído com a 114** (9 pares: hemorragia aditiva com apixabano, dabigatrano, rivaroxabano, enoxaparina e clopidogrel (dupla antiagregação); GI aditivo com dexametasona e naproxeno (AINE+AINE + interferência com a antiagregação); metotrexato (depuração renal ↓); metamizol (interfere com a aspirina + agranulocitose)) → **lote atorvastatina concluído com a 115** (9 pares: substrato do CYP3A4 — azóis (cetoconazol, itraconazol, voriconazol, fluconazol), eritromicina e ritonavir elevam os níveis com risco de miopatia/rabdomiólise (suspender ou reduzir a estatina); rifabutina (indução — perda de eficácia); colchicina e daptomicina (risco muscular aditivo)) → **lote furosemida concluído com a 117** (8 pares: ototoxicidade aditiva com aminoglicosídeos — estreptomicina, gentamicina, amicacina, tobramicina ("except in life-threatening situations, avoid this combination" — rótulo da furosemida); hipotensão sintomática de primeira dose com ramipril (IECA) em doentes com depleção de volume pelo diurético + risco renal; hipocaliemia aditiva com acetazolamida e corticosteroides (prednisolona, dexametasona)) → **lote lítio concluído com a 118** (8 pares: janela terapêutica estreita e eliminação renal que acompanha o sódio — AINEs (diclofenac, naproxeno: litemia ↑ ~15%, depuração ↓ ~20%), tiazidas (hidroclorotiazida: "generally should not be given with diuretics"), IECA (enalapril, captopril), metronidazol (litemia ↑ em doentes estabilizados), fluoxetina (síndrome serotoninérgica), haloperidol (síndrome encefalopática)) → **lote prednisolona concluído com a 119** (5 pares: úlcera/hemorragia GI aditiva com AINEs (diclofenac, naproxeno), hipocaliemia aditiva com hidroclorotiazida ("Hypokalemia may develop... during concomitant use of corticosteroid"), inibição do CYP3A4 pelos azóis (fluconazol, voriconazol — excesso de corticoide, Cushing e supressão adrenal)) → **lote sertralina concluído com a 120** (6 pares: síndrome serotoninérgica com opioides/serotonérgicos — tramadol (também CYP2D6/convulsões), codeína, fentanilo, buprenorfina, dextrometorfano; isoniazida (atividade inibidora da MAO do rótulo)) → **lote tramadol concluído com a 121** (5 pares restantes — sertralina já coberto na 120: fluoxetina (serotonina + CYP2D6/convulsões), isoniazida (atividade MAO), dextrometorfano (serotonina aditiva), ondansetron (5-HT3 + serotonina + possível aumento do uso de tramadol), difenidramina (sedação aditiva)) → **lote cotrimoxazol concluído com a 122** (5 pares: inibição do OCT2 pelo trimetoprim — metformina (risco de acidose láctica) e lamivudina (sem ajuste de dose); metotrexato ("Avoid concurrent use" — antifolato aditivo + deslocamento proteico + competição renal); sulfadoxina-pirimetamina (sulfonamida+sulfonamida, antifolato aditivo — OMS); zidovudina (mielossupressão aditiva — profilaxia em VIH)). → **lote cloroquina concluído com a 123** (5 pares: QT aditivo — mefloquina, quinina, hidroxicloroquina, moxifloxacina, fluconazol) → **lote fluconazol concluído com a 124** (3 restantes — cloroquina e prednisolona já cobertos nas 123/119: glibenclamida (CYP2C9 — AUC +44%), quinina (QT + CYP3A4), mefloquina (QT)) → **lote hidroclorotiazida concluído com a 125** (3 restantes — prednisolona já coberta na 119: calcitriol (hipercalcemia), dexametasona (hipocaliemia aditiva), enalapril (anti-hipertensão aditiva + eletrólitos)) → **lote isoniazida concluído com a 126** (3 restantes — sertralina/tramadol já cobertos nas 120/121: fenitoina (níveis ↑), fluoxetina (atividade MAO), paracetamol (CYP2E1 — hepatotoxicidade)) → **lote itraconazol concluído com a 127** (5 pares: CYP3A4 potente — fentanilo, buprenorfina, donepezilo, amlodipina, sildenafil) → **lote quinina concluído com a 128** (3 restantes — cloroquina/fluconazol já cobertos nas 123/124: artemeter-lumefantrina, diidroartemisinina-piperaquina, voriconazol — QT) → **lote 129 (19 pares)** (ritonavir 5 + voriconazol 3 + clopidogrel/anticoagulação 5 + praziquantel/efavirenz, clozapina/fluoxetina, dexametasona/fenitoína + antimaláricos 3) → **lote 130 (20 pares)** (β2/teofilina/sotalol 8, antiepiléticos 4, vancomicina/aminoglicosídeos 5, eritromicina+anti-histamínicos 3). → **lote 131 concluído com a 131** (17 pares: IECA/ARA/espironolactona 5, levotiroxina/absorção 4, azatioprina/aminosalicilatos/folato 3, alopurinol+penicilinas 2, diclofenac+naproxeno, leflunomida+metotrexato, difenidramina+morfina, fluoxetina+dextrometorfano). **Faltam 0 moderados** ✅ — todos os 366 pares moderados têm explicação completa (summary_pro + explanation, PT/EN).
3. ~~**Farmacologia** — alargar a 086 aos 36 fármacos com perfil~~ → **concluído com a 088** (todos os 30 fármacos com perfil sem farmacologia preenchidos). ~~Sem perfil, com mais pares~~ → **lote 091** (claritromicina, rifampicina, cetoconazol, itraconazol, aspirina) → **lote 092** (os 25 restantes da 090: antiácidos, voriconazol, cloroquina, fluconazol, sertralina, dexametasona, fluoxetina, quinina, lítio, mefloquina, ritonavir, isoniazida, arteméter+lumefantrina, cotrimoxazol, hidroclorotiazida, hidroxicloroquina, tramadol, diidroartemisinina+piperaquina, clopidogrel, diclofenac, eritromicina, naproxeno, teofilina, alprazolam, adrenalina). **Faltam 116** (a maioria sem perfil).
4. ~~**Perfis** — criar para os 146 restantes~~ → **lote 1 concluído com a 090** (30 fármacos com mais pares) → **lote 2 concluído com a 093** (26 seguintes por nº de pares) → **lote 3 concluído com a 094** (30 seguintes por nº de pares: nitroglicerina, paracetamol, praziquantel, valsartana, vancomicina, sulfadoxina-pirimetamina, ampicilina, lamotrigina, haloperidol, clozapina, ácido fólico, amicacina, azitromicina, bumetanida, buprenorfina, celecoxib, codeína, desloratadina, domperidona, doxiciclina, fexofenadina, ferro, fentanilo, flecainida, gentamicina, leflunomida, loratadina, metamizol, metoclopramida, febuxostat — perfis + farmacologia na mesma migração) → **lote 4 concluído com a 095** (30 seguintes por nº de pares: morfina, moxifloxacina, nevirapina, orlistat, sulfassalazina, tobramicina, acetazolamida, ácido tranexâmico, amoxicilina, amoxicilina+clavulanato, atovaquona+proguanil, budesonida, ceftazidima, ceftriaxona, cetirizina, cianocobalamina, daptomicina, donepezilo, epoetina alfa, etambutol, fitomenadiona, formoterol, fosfomicina, hidromorfona, indapamida, lamivudina, levocetirizina, loperamida, losartano, mesalazina — perfis + farmacologia na mesma migração) → **lote 5 concluído com a 096** (os últimos 30 sem perfil — 0 pares: acetilcisteína, ácido ursodesoxicolico, artesunato, benzilpenicilina benzatina, butilbrometo de hioscina, cefalexina, cefazolina, cefepima, cefotaxima, cefuroxima, etilefrina, famotidina, fenoximetilpenicilina, filgrastim, fondaparinux, ipratrópio, memantina, midodrina, montelucaste, nistatina, ondansetrom, piperacilina+tazobactam, pirazinamida, poractanto alfa, primaquina, propafenona, salmeterol, tafenoquina, tiotrópio, zidovudina — perfis + farmacologia na mesma migração). **Completos: 182/182** ✅
5. **Dimensões** — preencher as 95 faltantes → **lote 1 concluído com a 099** (15 anti-infeciosos: claritromicina, rifampicina, cetoconazol, ciprofloxacina, itraconazol, cloroquina, voriconazol, fluconazol, eritromicina, isoniazida, metronidazol, cotrimoxazol, levofloxacina, azitromicina, doxiciclina — alimento + doença + gestação completos, fontes DailyMed) → **lote 2 concluído com a 101** (12 antituberculosos/antirretrovíricos com as 3 dimensões: pirazinamida, etambutol, rifabutina, estreptomicina, linezolida, bedaquilina, atazanavir, efavirenz, lamivudina, nevirapina, ritonavir, zidovudina; + 8 com alimento completado: tamoxifeno, anastrozol, acetazolamida, clopidogrel, sotalol, amiodarona, ondansetrom, acetilcisteína) → **lote 3 concluído com a 102** (10 antimaláricos + 6 beta-lactâmicos com as 3 dimensões: artesunato, arteméter+lumefantrina, artesunato+amodiaquina, diidroartemisinina+piperaquina, sulfadoxina+pirimetamina, mefloquina, primaquina, quinina, atovaquona+proguanil, tafenoquina, ampicilina, amoxicilina+clavulanato, piperacilina+tazobactam, ceftriaxona, cefalexina, cefuroxima; fontes DailyMed + OMS/EMA para os sem rótulo nos EUA) → **lote 4 concluído com a 109** (29 fármacos a faltar as 3 dimensões: alprazolam, amicacina, amlodipina, amoxicilina, benzilpenicilina-benzatina, cefazolina, cefepima, cefotaxima, ceftazidima, clozapina, daptomicina, fenitoina, fenobarbital, fenoximetilpenicilina, fluoxetina, fosfomicina, gentamicina, haloperidol, lamotrigina, litio, moxifloxacina, nitroglicerina, paracetamol, praziquantel, sertralina, tobramicina, tramadol, valproato, vancomicina — 58 alimento + 58 doença + 29 gestação) → **lote 4b concluído com a 110** (os 15 restantes: 9 só-alimento — acido_tranexamico, epoetina_alfa, etilefrina, fitomenadiona, fondaparinux, formoterol, ipratropio, salmeterol, tiotropio; 4 alimento+doença — filgrastim, levonorgestrel, poractant_alfa, tiamazol; 2 só-doença — dextrometorfano, nistatina). **Completos: 182/182** ✅

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

**132 (correção — os 2 que a 096 deixou de fora por slug com underscore):**
benzilpenicilina-benzatina e piperacilina-tazobactam existem na BD com slug de hífen,
mas a 096 usou underscore ('benzilpenicilina_benzatina') — o JOIN `ON d.slug = v.slug`
falhou silenciosamente (lição 7.6). A 132 repete o mesmo conteúdo com os slugs
corretos. Com a 132, **182/182 fármacos com perfil + farmacologia — cobertura total** ✅.

**134 (interações da benzilpenicilina-benzatina — 2 pares):** warfarina (rótulo da
varfarina 7.4 Antibiotics and Antifungals) e metotrexato (rótulo do metotrexato 7.1 —
penicilinas aumentam a exposição). A probenecida está documentada no rótulo da
Bicillin L-A mas **não existe na BD** (182 fármacos) — par não criado.

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

✅ **Cobertura total: 182/182 fármacos com perfil + farmacologia** (a 132 corrige os 2 que a 096 deixou de fora por slug com underscore — ver secção 3).

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
