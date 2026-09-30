// Auditoria de blocos VALUES em migrações SQL.
// Para cada bloco "FROM (VALUES" / "JOIN (VALUES" ... ") AS v(...)",
// valida o nº de valores de topo de cada tuple contra o nº de aliases.
// Uso: node _temp/_auditar_bloco.mjs <ficheiro.sql>
import fs from 'fs';
const file = process.argv[2];
const t = fs.readFileSync(file, 'utf8');
const lines = t.split('\n');
const stripComments = (s) => s.replace(/^\s*--.*$/, '');

// máquina de estados: procurar "(VALUES" → recolher tuples até linha ") AS v(...)" → ler aliases
const blocks = []; // { tuples: [{line, slug, count}], aliases: n, asLine }
let cur = null;
for (let i = 0; i < lines.length; i++) {
  const l = stripComments(lines[i]);
  if (/(FROM|JOIN) \(VALUES/.test(l) && !cur) {
    cur = { startLine: i + 1, tuples: [], asLine: null, ends: [] };
  } else if (cur && /^  \('/.test(l)) {
    const m = l.match(/^  \('([^']+)'/);
    cur.tuples.push({ line: i + 1, slug: m ? m[1] : '?' });
  } else if (cur && /^\) AS v\(/.test(l.trim())) {
    cur.ends.push(i + 1);
    cur.asLine = i + 1;
    const s = l.indexOf('AS v(') + 5;
    let depth = 1, buf = '';
    for (let j = s; j < l.length; j++) {
      const c = l[j];
      if (c === '(') depth++;
      else if (c === ')') { depth--; if (depth === 0) break; }
      if (depth > 0) buf += c;
    }
    // aliases podem continuar na(s) linha(s) seguinte(s)
    let k = i + 1;
    while (depth > 0 && k < lines.length) {
      for (let j = 0; j < lines[k].length; j++) {
        const c = lines[k][j];
        if (c === '(') depth++;
        else if (c === ')') { depth--; if (depth === 0) break; }
        if (depth > 0) buf += c;
      }
      k++;
    }
    cur.aliases = buf.split(',').map(x => x.trim()).filter(Boolean).length;
    blocks.push(cur);
    cur = null;
  }
}
// recalcular limites: tuples de cada bloco são as linhas > startLine e < asLine
for (const b of blocks) {
  b.tuples = b.tuples.filter(t => t.line > b.startLine && t.line < b.asLine);
}

function countTopFields(chunk) {
  // chunk começa no '(' do tuple: vírgulas de topo são as de depth interna 1
  // 2026-09-30: ignora comentários '--' (podem conter vírgulas/parênteses)
  // e trata aspas escapadas com '' (padrão SQL), não apenas \'
  const lines = chunk.split('\n').filter(l => !/^\s*--/.test(l)).join('\n');
  let n = 0, depth = 0, inStr = false;
  for (let i = 0; i < lines.length; i++) {
    const c = lines[i];
    if (inStr) {
      if (c === "'") {
        if (lines[i + 1] === "'") { i++; continue; } // '' escapado
        inStr = false;
      }
      continue;
    }
    if (c === "'") { inStr = true; continue; }
    if (c === '(' || c === '[') depth++;
    else if (c === ')' || c === ']') depth--;
    else if (c === ',' && depth === 1) n++;
  }
  return n + 1;
}

// limites dos tuples (linha de início de cada tuple + fim do bloco)
let fail = false;
for (const b of blocks) {
  console.log(`\n--- bloco (VALUES na linha ${b.startLine}, ${b.aliases} colunas, ${b.tuples.length} tuples)`);
  if (!b.aliases) { console.log('*** sem aliases detectados'); fail = true; continue; }
  const starts = b.tuples.map(x => x.line - 1);
  starts.push(b.asLine ? b.asLine - 1 : lines.length); // tuple termina antes do ") AS v("
  for (let k = 0; k < b.tuples.length; k++) {
    const chunk = lines.slice(starts[k], starts[k + 1]).join('\n');
    const n = countTopFields(chunk);
    const ok = n === b.aliases;
    if (!ok) fail = true;
    console.log(ok ? 'OK ' : '*** MISMATCH ***', b.tuples[k].slug, 'valores:', n, '| esperado:', b.aliases);
  }
}
console.log(fail ? '\n=== FALHOU ===' : '\n=== TODOS OS BLOCOS OK ===');
process.exit(fail ? 1 : 0);
