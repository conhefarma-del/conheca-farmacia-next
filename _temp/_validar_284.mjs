// Valida a migração 284: extrai os tuples do VALUES (13 campos) e verifica
// balanço de parênteses do ficheiro inteiro.
import fs from 'fs';

const file = process.argv[2] || 'supabase/migrations/284_pregnancy_lotes34.sql';
const sql = fs.readFileSync(file, 'utf8');

// 1. Balanço de parênteses (ignorar conteúdo de strings '')
let depth = 0, inStr = false, min = 0;
for (let i = 0; i < sql.length; i++) {
  const c = sql[i];
  if (c === "'") { if (inStr && sql[i+1] === "'") { i++; continue; } inStr = !inStr; continue; }
  if (inStr) continue;
  if (c === '(') depth++;
  if (c === ')') { depth--; if (depth < min) min = depth; }
}
console.log('balanço parênteses: final =', depth, '| min =', min, depth === 0 && min >= 0 ? 'OK' : 'FAIL');

// 2. Extrair bloco VALUES ... ) AS v (remover comentários -- primeiro)
const start = sql.indexOf('JOIN (VALUES');
const end = sql.indexOf(') AS v(', start);
if (start < 0 || end < 0) { console.log('FAIL: bloco VALUES não encontrado'); process.exit(1); }
const block = sql.slice(start, end).replace(/^\s*--.*$/gm, '');

// 3. Parse de tuples: split a nível de profundidade-0 fora de strings
//    O '(' inicial de JOIN (VALUES abre a "lista" (tupleDepth 0→1 mas é o
//    parêntese do VALUES, não de um tuple). Estratégia: o parêntese de abertura
//    imediatamente após VALUES é o wrapper; os tuples são os de nível seguinte.
const tuples = [];
let cur = '', tupleDepth = 0, s = false, started = false;
for (let i = 0; i < block.length; i++) {
  const c = block[i];
  if (c === "'") {
    if (s && block[i+1] === "'") { cur += "''"; i++; continue; }
    s = !s; cur += c; continue;
  }
  if (s) { cur += c; continue; }
  if (c === '(') {
    tupleDepth++;
    if (tupleDepth === 2) { started = true; cur = ''; continue; }
  }
  if (c === ')') {
    if (tupleDepth === 2 && started) { tuples.push(cur); started = false; cur = ''; tupleDepth--; continue; }
    tupleDepth--;
  }
  if (started) cur += c;
}

// 4. Contar campos por tuple (vírgulas top-level fora de strings)
let fail = 0;
const expected = 12; // 13 colunas, mas 'status' é fornecido no SELECT ('published'), não no tuple
for (const t of tuples) {
  let fields = 1, s2 = false;
  for (let i = 0; i < t.length; i++) {
    const c = t[i];
    if (c === "'") { if (s2 && t[i+1] === "'") { i++; continue; } s2 = !s2; continue; }
    if (s2) continue;
    if (c === ',') fields++;
  }
  const first = t.split(/(?<=')[^\n]*/)[0].slice(0, 40);
  const slug = (t.match(/^'([a-z0-9-]+)'/) || [])[1] || '?';
  if (fields !== expected) { console.log(`MISMATCH ${slug}: ${fields} campos (esperado ${expected})`); fail++; }
  else console.log(`OK  ${slug.padEnd(20)} ${fields} campos`);
}
console.log(`\n${tuples.length} tuples, ${fail} mismatches`);
process.exit(fail ? 1 : 0);
