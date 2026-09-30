import fs from 'fs';
const t = fs.readFileSync('supabase/migrations/267_interacoes_lote23_lnme.sql', 'utf8');
const lines = t.split('\n');
let fail = false;

// 1. aspas ímpares por linha
const bad = [];
for (let i = 0; i < lines.length; i++) {
  const m = lines[i].match(/'/g);
  if (m && m.length % 2 !== 0) bad.push(i + 1);
}
if (bad.length) { console.log('FAIL aspas ímpares nas linhas:', bad); fail = true; }
else console.log('OK aspas pares em todas as linhas');

// 2. tuples (LEAST) e fechos
const tuples = (t.match(/^\(LEAST\(/gm) || []).length;
const closes = (t.match(/^ 'published', now\(\)\),?$/gm) || []).length;
console.log('tuples:', tuples, '| fechos:', closes);
if (tuples !== closes) { console.log('FAIL tuples != fechos'); fail = true; }

// 3. parênteses equilibrados fora de strings
let depth = 0, inStr = false, ok = true;
for (const c of t) {
  if (inStr) { if (c === "'") inStr = false; continue; }
  if (c === "'") { inStr = true; continue; }
  if (c === '(') depth++;
  else if (c === ')') { depth--; if (depth < 0) { ok = false; } }
}
console.log('parênteses:', ok && depth === 0 ? 'OK' : 'FAIL (depth final=' + depth + ', negativo=' + !ok + ')');
if (!(ok && depth === 0)) fail = true;

// 4. severidades válidas
const sevs = [...t.matchAll(/^ '(minor|moderate|critical|none)',$/gm)].map(m => m[1]);
const counts = sevs.reduce((a, s) => { a[s] = (a[s] || 0) + 1; return a; }, {});
console.log('severidades:', sevs.length, JSON.stringify(counts));
if (sevs.length !== tuples) { console.log('FAIL severidades != tuples'); fail = true; }

// 5. slugs: cada tuple deve ter exatamente 4 refs (2 slugs × LEAST/GREATEST)
const slugLines = [...t.matchAll(/slug='([^']+)'/g)].map(m => m[1]);
if (slugLines.length !== tuples * 4) { console.log('FAIL refs slug:', slugLines.length, 'esperado', tuples * 4); fail = true; }
else console.log('OK refs slug =', slugLines.length);

// 6. pares únicos
const pairRe = /\(LEAST\(\(SELECT id FROM public\.drugs WHERE slug='([^']+)'\), \(SELECT id FROM public\.drugs WHERE slug='([^']+)'\)\),\n GREATEST\(\(SELECT id FROM public\.drugs WHERE slug='\1'\), \(SELECT id FROM public\.drugs WHERE slug='\2'\)\)/g;
const pairs = [...t.matchAll(pairRe)].map(m => [m[1], m[2]].sort().join('×'));
const uniq = new Set(pairs);
console.log('pares únicos:', uniq.size, '/', pairs.length);
if (uniq.size !== pairs.length) { console.log('FAIL pares duplicados'); fail = true; }

// 7. idempotência + colunas
if (!/ON CONFLICT \(drug_a_id, drug_b_id\) DO NOTHING;/.test(t)) { console.log('FAIL idempotência'); fail = true; }
if (!/drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,/.test(t)) { console.log('FAIL header colunas'); fail = true; }
else console.log('OK idempotência e header de colunas');

console.log(fail ? '=== FALHOU ===' : '=== VALIDAÇÃO 267: TODOS OK ===');
process.exit(fail ? 1 : 0);
