import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
const env = fs.readFileSync('.env.local', 'utf8');
const get = k => (env.match(new RegExp(k + '=(.+)')) || [])[1]?.trim();
const sb = createClient(get('NEXT_PUBLIC_SUPABASE_URL'), get('SUPABASE_SERVICE_ROLE_KEY'));

const pares = [
  ['cloreto_potassio', 'cloreto-potassio'],
  ['sulfato_magnesio', 'sulfato-magnesio'],
  ['acetilcisteina', 'n-acetilcisteina'],
];
const rank = { critical: 4, moderate: 3, minor: 2, none: 1 };

const { data: drugs } = await sb.from('drugs').select('id,slug').in('slug', pares.flat());
const id = Object.fromEntries(drugs.map(d => [d.slug, d.id]));
const slug = Object.fromEntries(drugs.map(d => [d.id, d.slug]));

// ---- FF ----
const { data: ff } = await sb.from('drug_interactions').select('id,drug_a_id,drug_b_id,severity,is_archived')
  .or(`drug_a_id.in.(${drugs.map(d => d.id).join(',')}),drug_b_id.in.(${drugs.map(d => d.id).join(',')})`);
const dupIds = pares.map(p => id[p[0]]);
const vivos = ff.filter(r => !r.is_archived);
console.log('=== DRUG_INTERACTIONS (FF) ===');
for (const [dup, sob] of pares) {
  const dupId = id[dup];
  const linhasDup = vivos.filter(r => r.drug_a_id === dupId || r.drug_b_id === dupId);
  for (const linha of linhasDup) {
    const parA = linha.drug_a_id === dupId ? id[sob] : linha.drug_a_id;
    const parB = linha.drug_b_id === dupId ? id[sob] : linha.drug_b_id;
    const a = Math.min(parA, parB), b = Math.max(parA, parB);
    // colisão com linha viva do sobrevivente (ou outro remapeado)?
    const colisao = vivos.find(r =>
      r.id !== linha.id &&
      Math.min(r.drug_a_id === dupId ? id[sob] : r.drug_a_id, r.drug_b_id === dupId ? id[sob] : r.drug_b_id) === a &&
      Math.max(r.drug_a_id === dupId ? id[sob] : r.drug_a_id, r.drug_b_id === dupId ? id[sob] : r.drug_b_id) === b);
    if (colisao) {
      // 4B: desempate por severidade
      const rkKeep = rank[colisao.severity] >= rank[linha.severity];
      console.log(`COLISÃO ${slug[linha.drug_a_id]}×${slug[linha.drug_b_id]} (${linha.severity}) vs ${slug[colisao.drug_a_id]}×${slug[colisao.drug_b_id]} (${colisao.severity}) → arquiva-se a ${rkKeep ? 'DO DUPLICADO' : 'DO SOBREVIVENTE'}`);
    } else {
      console.log(`REMAPEIA ${slug[linha.drug_a_id]}×${slug[linha.drug_b_id]} (${linha.severity}) → par destino ${slug[parA] ?? '?'}×${slug[parB] ?? '?'}`);
    }
  }
}

// ---- doença / alimento ----
for (const [tabela, key] of [['drug_disease_interactions','condition_slug'],['drug_food_interactions','entity_slug']]) {
  console.log(`\n=== ${tabela} ===`);
  const { data: regs } = await sb.from(tabela).select(`id,drug_id,${key},is_archived`).in('drug_id', drugs.map(d=>d.id));
  const vivosR = regs.filter(r=>!r.is_archived);
  for (const [dup, sob] of pares) {
    const dupId = id[dup];
    for (const linha of vivosR.filter(r=>r.drug_id===dupId)) {
      const col = vivosR.find(r=>r.drug_id===id[sob] && r[key]===linha[key]);
      console.log((col ? 'ARQUIVA (colisão)' : 'REMAPEIA ').padEnd(18), slug[linha.drug_id].padEnd(18), linha[key]);
    }
  }
}

// ---- perfis/farmacologia/fármaco ----
console.log('\n=== ARCHIVES ===');
for (const [dup, sob] of pares) console.log(`ARQUIVA fármaco ${dup} (sobrevive ${sob}) + perfil + farmacologia`);
