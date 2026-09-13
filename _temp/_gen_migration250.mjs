// Gerador da migração 250 — Flockhart Table™ nos alvos CYP
//  1. Atualiza substrates/inhibitors/inducers (pt/en) dos 8 alvos CYP com
//     listas CURADAS (evidência strong/moderate da Flockhart Table™)
//  2. Popula drug_target_roles cruzando os nomes Flockhart com os fármacos
//     da BD (match por nome/alias normalizado, estilo lib/targets/derive.js)
//  3. Registra a citação exigida pela IU School of Medicine em source_pt/en
import fs from 'node:fs';

const flock = JSON.parse(fs.readFileSync('_temp/_flockhart_consolidated.json', 'utf8'));
const drugs = JSON.parse(fs.readFileSync('_temp/_drugs_bd.json', 'utf8'));
const targets = JSON.parse(fs.readFileSync('_temp/_targets_cyp.json', 'utf8')); // do Supabase

const norm = (s) =>
  (s || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

// Índice BD: nome normalizado → drug
const index = new Map();
for (const dr of drugs) {
  for (const n of [dr.name_pt, ...(dr.aliases || [])]) {
    const nn = norm(n);
    if (nn && !index.has(nn)) index.set(nn, dr);
  }
}

// Traduções PT dos nomes Flockhart que batem com fármacos da BD via alias EN
// (o name_pt da BD já está em PT; o texto das listas usa os nomes Flockhart EN
//  para EN e um mapa manual para PT dos principais)
const NAME_PT = {
  caffeine: 'cafeína', clozapine: 'clozapina', fluvoxamine: 'fluvoxamina',
  lidocaine: 'lidocaína', melatonin: 'melatonina', theophylline: 'teofilina',
  ciprofloxacin: 'ciprofloxacina', fluconazole: 'fluconazol',
  clarithromycin: 'claritromicina', erythromycin: 'eritromicina',
  carbamazepine: 'carbamazepina', phenytoin: 'fenitoína', phenobarbital: 'fenobarbital',
  rifampin: 'rifampicina', rifabutin: 'rifabutina', nevirapine: 'nevirapina',
  efavirenz: 'efavirenz', ritonavir: 'ritonavir', dexamethasone: 'dexametasona',
  amiodarone: 'amiodarona', metronidazole: 'metronidazol', quinidine: 'quinidina',
  bupropion: 'bupropiona', terbinafine: 'terbinafina', tramadol: 'tramadol',
  tamoxifen: 'tamoxifeno', codeine: 'codeína', oxycodone: 'oxicodona',
  venlafaxine: 'venlafaxina', voriconazole: 'voriconazol', omeprazole: 'omeprazol',
  esomeprazole: 'esomeprazol', pantoprazole: 'pantoprazol', lansoprazole: 'lansoprazol',
  warfarin: 'varfarina', celecoxib: 'celecoxib', ibuprofen: 'ibuprofeno',
  losartan: 'losartana', fluvastatin: 'fluvastatina', gemfibrozil: 'gemfibrozila',
  clopidogrel: 'clopidogrel', ticlopidine: 'ticlopidina', omeprazol: 'omeprazol',
  'St. John\'s Wort': 'hipericão (St. John\'s Wort)',
  modafinil: 'modafinila', isoniazid: 'isoniazida', disulfiram: 'dissulfiram',
};

const ptName = (en) => NAME_PT[en] || NAME_PT[en.toLowerCase()] || en;

// Mapa EN→PT construído do cruzamento com a BD: se o nome Flockhart casa
// com um fármaco da BD (nome ou alias), usar o name_pt da BD — tradução
// consistente com o resto do site.
const findDrugForMap = (name) => {
  const nn = norm(name.replace(/\s*\(.*?\)\s*/g, ' '));
  let hit = index.get(nn);
  if (!hit && nn.includes(' ')) hit = index.get(nn.split(' ')[0]);
  return hit || null;
};
const enToPt = new Map();
for (const [iso, r] of Object.entries(flock.isoforms)) {
  for (const item of [...r.substrates, ...r.inhibitors]) {
    const dr = findDrugForMap(item.name);
    if (dr) enToPt.set(item.name.toLowerCase(), dr.name_pt);
  }
  for (const n of r.inducers) {
    const dr = findDrugForMap(n);
    if (dr) enToPt.set(n.toLowerCase(), dr.name_pt);
  }
}

// Capitalização: minúscula exceto siglas/exceções; espaços normalizados
const fixCaps = (s) => {
  let x = s.replace(/\s+/g, ' ').trim();
  // Siglas a preservar (tudo maiúsculas na Flockhart)
  if (/^[A-Z0-9-]+$/.test(x)) return x;
  // Exceções com maiúscula própria
  if (/st\. john/i.test(x)) return x.replace(/st\. john's wort/i, "St. John's Wort");
  // Primeira letra minúscula (nomes de fármacos genéricos)
  x = x.charAt(0).toLowerCase() + x.slice(1);
  return x;
};
// Mapa de correções de capitalização após tradução BD (o name_pt da BD pode
// começar por maiúscula; nas listas os itens são minúsculos)
const lowerFirst = (s) =>
  s
    ? s
        .charAt(0)
        .toLowerCase()
        .replace(/(.)/, (m) => m.toLowerCase()) + s.slice(1).replace(/(\s\+\s+)([A-Z])/g, (m, sp, c) => sp + c.toLowerCase())
    : s;
const ptNameSmart = (en) => {
  const key = en.toLowerCase().trim();
  if (enToPt.has(key)) return lowerFirst(enToPt.get(key));
  // Já traduzido por NAME_PT? devolver direto — NÃO passar pela cadeia de
  // replaces (evita dupla tradução: 'modafinila' → 'modafinilaa')
  const direct = NAME_PT[en] || NAME_PT[en.toLowerCase()];
  if (direct) return lowerFirst(direct);
  // Dicionário adicional (nomes sem match na BD)
  const dict = PT_DICT[key] || PT_DICT[key.replace(/\s*\(.*?\)\s*/g, ' ').trim()];
  if (dict) return lowerFirst(dict);
  let pt = ptName(en);
  pt = pt
    .replace(/tipranavir and ritonavir/i, 'tipranavir + ritonavir')
    .replace(/beta-naphthoflavone/i, 'beta-naftoflavona')
    .replace(/broccoli/i, 'brócolos')
    .replace(/brussel sprouts/i, 'couve-de-bruxelas')
    .replace(/tobacco/i, 'tabaco (fumo)')
    .replace(/ethanol/i, 'álcool (etanol)')
    .replace(/methylprednisolone/i, 'metilprednisolona')
    .replace(/prednisone/i, 'prednisona')
    .replace(/prednisolone/i, 'prednisolona')
    .replace(/phenobarbital/i, 'fenobarbital')
    .replace(/phenytoin/i, 'fenitoína')
    .replace(/carbamazepine/i, 'carbamazepina')
    .replace(/dabrafenib/i, 'dabrafenib')
    .replace(/enzalutamide/i, 'enzalutamida')
    .replace(/nevirapine/i, 'nevirapina')
    .replace(/efavirenz/i, 'efavirenz')
    .replace(/rifampin/i, 'rifampicina')
    .replace(/rifabutin/i, 'rifabutina')
    .replace(/dexamethasone/i, 'dexametasona')
    .replace(/betamethasone/i, 'betametasona')
    .replace(/modafinil/i, 'modafinila')
    .replace(/secobarbital/i, 'secobarbital')
    .replace(/omeprazole/i, 'omeprazol')
    .replace(/letermovir/i, 'letermovir')
    .replace(/ritonavir/i, 'ritonavir')
    .replace(/isoniazid/i, 'isoniazida')
    .replace(/pioglitazone/i, 'pioglitazona')
    .replace(/troglitazone/i, 'troglitazona')
    .replace(/artemisinin/i, 'artemisinina')
    .replace(/lemborexant/i, 'lemborexanto')
    .replace(/eslicarbazepine/i, 'eslicarbazepina')
    .replace(/oxcarbazepine/i, 'oxcarbazepina')
    .replace(/cenobamate/i, 'cenobamato')
    .replace(/clobazam/i, 'clobazam')
    .replace(/elagolix/i, 'elagolix')
    .replace(/brigatinib/i, 'brigatinibe')
    .replace(/sotorasib/i, 'sotorasibe')
    .replace(/lorlatinib/i, 'lorlatinibe')
    .replace(/telotristat/i, 'telotristate')
    .replace(/suzetrigine/i, 'suzetrigina')
    .replace(/vemurafenib/i, 'vemurafenib');
  return fixCaps(pt);
};
const enNameSmart = (en) => fixCaps(en);
// Nome EN: igual ao nome Flockhart (EN é a língua original da tabela).
// Nome PT: traduzido (mapa BD + regras). Sem derivação do slug.

// Isoformas: chave Flockhart → slug do alvo na BD
const ISO_TO_SLUG = {
  '1A2': 'cyp1a2', '3A4/5': 'cyp3a4', '2D6': 'cyp2d6', '2C19': 'cyp2c19',
  '2C9': 'cyp2c9', '2C8': 'cyp2c8', '2B6': 'cyp2b6', '2E1': 'cyp2e1',
};

const CITATION_PT = 'Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)';
const CITATION_EN = 'Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)';

const Q = (s) => "'" + String(s).replace(/'/g, "''") + "'";
const QArr = (arr) => "ARRAY[" + arr.map(Q).join(', ') + "]";

// ---------- 0. Dicionário adicional PT (nomes sem match na BD) ----------
// Chaves = nome EN Flockhart normalizado; ignorar entradas de metadados
const PT_DICT = Object.fromEntries(
  Object.entries(JSON.parse(fs.readFileSync('_temp/_flockhart_pt_dict.json', 'utf8')))
    .filter(([k, v]) => !k.startsWith('_') && !k.endsWith('_dup') && !k.endsWith('_note'))
);

// ---------- 1. Listas curadas por alvo ----------
const curated = {}; // slug → { substrates_en, inhibitors_en, inducers_en, substrates_pt, ... , roles: [{drug, role}] }
const rolesBySlug = {}; // slug → [{drugSlug, role}]

for (const [iso, slug] of Object.entries(ISO_TO_SLUG)) {
  const r = flock.isoforms[iso];
  const pick = (items) => items.filter((x) => !x.evidence || ['strong', 'moderate'].includes(x.evidence));

  // Substratos e inibidores: só strong/moderate (curado)
  const subs = pick(r.substrates);
  const inhs = pick(r.inhibitors);
  // Indutores: todos (a lista Flockhart de indutores já é seletiva)
  const inds = r.inducers;

  const target = targets.find((t) => t.slug === slug);
  if (!target) { console.error('ALVO NÃO ENCONTRADO:', slug); continue; }

  curated[slug] = {
    substrates_en: subs.map((x) => enNameSmart(x.name)),
    inhibitors_en: inhs.map((x) => enNameSmart(x.name)),
    inducers_en: inds.map(enNameSmart),
  };
  curated[slug].substrates_pt = subs.map((x) => ptNameSmart(x.name));
  curated[slug].inhibitors_pt = inhs.map((x) => ptNameSmart(x.name));
  curated[slug].inducers_pt = inds.map(ptNameSmart);

  // ---------- 2. drug_target_roles: cruzar com a BD (qualquer evidência) ----------
  const findDrug = (name) => {
    const nn = norm(name.replace(/\s*\(.*?\)\s*/g, ' ')); // remove notas "(3A5)", "(oral)"
    let hit = index.get(nn);
    if (!hit && nn.includes(' ')) hit = index.get(nn.split(' ')[0]);
    return hit || null;
  };
  rolesBySlug[slug] = [];
  const seen = new Set();
  for (const [role, list] of [
    ['substrate', r.substrates],
    ['inhibitor', r.inhibitors],
    ['inducer', r.inducers.map((n) => ({ name: n }))],
  ]) {
    for (const item of list) {
      const dr = findDrug(item.name);
      if (!dr) continue;
      const key = `${dr.slug}|${role}`;
      if (seen.has(key)) continue;
      seen.add(key);
      rolesBySlug[slug].push({ drugSlug: dr.slug, drugId: dr.id, role });
    }
  }
}

// ---------- 3. Gerar SQL ----------
const NL = '\n';
let sql = `-- =====================================================================
-- 250: Flockhart Table™ — listas curadas nos alvos CYP + drug_target_roles
--
-- Fonte: Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart
--   Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical
--   Pharmacology, Indiana University School of Medicine (atualizada 2021).
--   https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)
--
-- Conteúdo:
--   1. UPDATE em molecular_targets (8 alvos CYP): substrates/inhibitors/
--      inducers pt+en com listas CURADAS (evidência strong/moderate da
--      tabela; indutores: lista completa Flockhart, já seletiva).
--   2. INSERT em drug_target_roles: cruzamento nome Flockhart × drugs da BD
--      (qualquer evidência, match por nome/alias normalizado).
--
-- Idempotente: UPDATEs e ON CONFLICT DO NOTHING.
-- Aplica-se manualmente no Supabase (SQL editor).
-- =====================================================================

`;

// 1. Updates
sql += `-- ============================================================
-- 1. Listas curadas nos alvos CYP (molecular_targets)
-- ============================================================
`;
for (const [slug, c] of Object.entries(curated)) {
  const fmt = (arr, prefix) => {
    if (!arr.length) return "E'" + prefix + ' (lista em revisão).\'';
    // Escapar apóstrofos internos (St. John's Wort) para string SQL: ' → ''
    const body = (prefix + ': ' + arr.join(', ') + '.').replace(/'/g, "''");
    return "E'" + body + "'";
  };
  sql += `UPDATE public.molecular_targets SET
  substrates_pt = ${fmt(c.substrates_pt, 'Substratos (evidência forte/moderada)')},
  substrates_en = ${fmt(c.substrates_en, 'Substrates (strong/moderate evidence)')},
  inhibitors_pt = ${fmt(c.inhibitors_pt, 'Inibidores (evidência forte/moderada)')},
  inhibitors_en = ${fmt(c.inhibitors_en, 'Inhibitors (strong/moderate evidence)')},
  inducers_pt   = ${fmt(c.inducers_pt, 'Indutores')},
  inducers_en   = ${fmt(c.inducers_en, 'Inducers')},
  source_pt     = ${Q('Flockhart Table™ (IU School of Medicine, 2021) — ' + CITATION_PT)},
  source_en     = ${Q('Flockhart Table™ (IU School of Medicine, 2021) — ' + CITATION_EN)}
WHERE slug = ${Q(slug)};
`;
}

// 2. drug_target_roles — precisa dos ids dos alvos; usar subselect por slug
sql += `
-- ============================================================
-- 2. drug_target_roles — cruzamento Flockhart × drugs da BD
-- ============================================================
`;
const targetIdBySlug = Object.fromEntries(targets.map((t) => [t.slug, t.id]));
let roleLines = [];
for (const [slug, roles] of Object.entries(rolesBySlug)) {
  const tid = targetIdBySlug[slug];
  if (!tid) continue;
  for (const r of roles) {
    roleLines.push(
      `  (${Q(r.drugId)}, ${Q(tid)}, ${Q(r.role)}, ${Q('Flockhart Table™ (IU School of Medicine, 2021)')}, ${Q('Flockhart Table™ (IU School of Medicine, 2021)')})`
    );
  }
}
sql += `INSERT INTO public.drug_target_roles (drug_id, target_id, role, source_pt, source_en)
VALUES
${roleLines.join(',' + NL)}
ON CONFLICT (drug_id, target_id, role) DO NOTHING;
`;

fs.mkdirSync('_temp', { recursive: true });
fs.writeFileSync('supabase/migrations/250_flockhart_cyp_targets.sql', sql);

// Resumo
console.log('=== RESUMO DA MIGRAÇÃO 250 ===');
for (const [slug, c] of Object.entries(curated)) {
  console.log(`${slug}: ${c.substrates_en.length} substratos, ${c.inhibitors_en.length} inibidores, ${c.inducers_en.length} indutores | roles novos: ${rolesBySlug[slug].length}`);
}
console.log('Total linhas drug_target_roles a inserir:', roleLines.length);
console.log('Migração: supabase/migrations/250_flockhart_cyp_targets.sql');
