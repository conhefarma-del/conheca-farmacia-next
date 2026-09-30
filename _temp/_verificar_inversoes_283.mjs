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
const mapa = Object.fromEntries(pares); // dup -> sob
const { data: drugs } = await sb.from('drugs').select('id,slug').in('slug', pares.flat());
const id = Object.fromEntries(drugs.map(d => [d.slug, d.id]));
const slug = Object.fromEntries(drugs.map(d => [d.id, d.slug]));
const slug2 = x => slug[x] ?? x.slice(0, 8);

const { data: ff } = await sb.from('drug_interactions')
  .select('id,drug_a_id,drug_b_id,severity,is_archived')
  .or(`drug_a_id.in.(${drugs.map(d => d.id).join(',')}),drug_b_id.in.(${drugs.map(d => d.id).join(',')})`);

console.log('linhas vivas envolvendo duplicados:', ff.filter(r => !r.is_archived).length);
for (const r of ff.filter(r => !r.is_archived)) {
  const destA = mapa[slug[r.drug_a_id]] ? id[mapa[slug[r.drug_a_id]]] : r.drug_a_id;
  const destB = mapa[slug[r.drug_b_id]] ? id[mapa[slug[r.drug_b_id]]] : r.drug_b_id;
  const invertido = destA > destB;
  console.log(
    (invertido ? 'INVERTIDO' : 'ok       '),
    slug2(r.drug_a_id).padEnd(20), '×', slug2(r.drug_b_id).padEnd(24),
    '→', slug2(destA).padEnd(20), '×', slug2(destB),
    `(${r.severity})`
  );
}
