// Validação básica: aspas pares por linha + parênteses equilibrados fora de strings
// Uso: node _temp/_validar_sql_basico.mjs <ficheiro.sql> [...]
import fs from 'fs';
let allOk = true;
for (const file of process.argv.slice(2)) {
  const t = fs.readFileSync(file, 'utf8');
  const lines = t.split('\n');
  const bad = [];
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/'/g);
    if (m && m.length % 2 !== 0) bad.push(i + 1);
  }
  let depth = 0, inStr = false, ok = true;
  for (const c of t) {
    if (inStr) { if (c === "'") inStr = false; continue; }
    if (c === "'") { inStr = true; continue; }
    if (c === '(') depth++;
    else if (c === ')') { depth--; if (depth < 0) ok = false; }
  }
  const okAll = bad.length === 0 && ok && depth === 0;
  if (!okAll) allOk = false;
  console.log(okAll ? 'OK  ' : 'FAIL', file,
    bad.length ? `aspas ímpares nas linhas ${bad.join(',')}` : '',
    (!ok || depth !== 0) ? `parênteses (depth=${depth}, negativo=${!ok})` : '');
}
console.log(allOk ? '=== TODOS OK ===' : '=== FALHOU ===');
process.exit(allOk ? 0 : 1);
