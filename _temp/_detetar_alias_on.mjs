// Detecta referências ao alias do target de um UPDATE dentro da secção
// FROM/JOIN/ON — padrão que o Postgres rejeita com 42P01 ("invalid reference
// to FROM-clause entry"). O alias do target só pode ser usado no SET e no WHERE.
import fs from 'fs';

const file = process.argv[2] || 'supabase/migrations/283_fusao_duplicados_underscore.sql';
const sql = fs.readFileSync(file, 'utf8');

// partir em statements ao nível top-level (fora de strings, respeitando '')
const statements = [];
{
  let s = false, cur = '', start = 0;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (c === "'") { if (s && sql[i+1] === "'") { cur += "''"; i++; continue; } s = !s; cur += c; continue; }
    if (s) { cur += c; continue; }
    if (c === ';') { statements.push({ text: cur, start }); cur = ''; continue; }
    cur += c;
  }
  if (cur.trim()) statements.push({ text: cur, start });
}

let fails = 0;
for (const st of statements) {
  const m = st.text.match(/UPDATE\s+(public\.[a-z_]+)\s+([a-z][a-z0-9_]*)/);
  if (!m) continue;
  const [, tbl, alias] = m;
  const fromIdx = st.text.indexOf('\nFROM ');
  if (fromIdx < 0) continue;
  const whereIdx = st.text.search(/\nWHERE /);
  const fromPart = st.text.slice(fromIdx, whereIdx > 0 ? whereIdx : undefined);
  const re = new RegExp('\\b' + alias + '\\b\\s*\\.', 'g');
  const hits = fromPart.match(re);
  if (hits) {
    const line = sql.slice(0, st.start).split('\n').length;
    console.log(`FAIL linha ~${line}: ${tbl} AS ${alias} — ${hits.length} referências ao target no FROM/JOIN/ON`);
    fails++;
  }
}
console.log(fails === 0 ? 'OK — nenhuma referência inválida ao alias do target' : `${fails} statement(s) com problema`);
process.exit(fails ? 1 : 0);
