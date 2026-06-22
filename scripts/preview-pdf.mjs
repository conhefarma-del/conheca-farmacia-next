// Preview script: fetch the last inscription from Supabase, hit the
// /api/comprovativo/[id]/pdf endpoint on Vercel, save the PDF locally so
// you can open and inspect it BEFORE deciding to commit + push.
//
// Usage: node scripts/preview-pdf.mjs
// Output: .next/preview-comprovativo-<n>.pdf
//
// Requires: .env.local with NEXT_PUBLIC_SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY
// (used only to fetch the inscription row — never sent anywhere else).

import { writeFileSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { createClient } from '@supabase/supabase-js'

// Load .env.local manually (node doesn't auto-load like next dev does).
// Only sets vars that are not already in process.env.
const envPath = join(process.cwd(), '.env.local')
try {
  const envContent = readFileSync(envPath, 'utf8')
  for (const line of envContent.split('\n')) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue
    const eq = trimmed.indexOf('=')
    if (eq === -1) continue
    const key = trimmed.slice(0, eq).trim()
    const value = trimmed
      .slice(eq + 1)
      .trim()
      .replace(/^["']|["']$/g, '')
    if (!process.env[key]) process.env[key] = value
  }
} catch {
  // file missing or unreadable — fall through to the explicit check below
}

const url = process.env.NEXT_PUBLIC_SUPABASE_URL
const key = process.env.SUPABASE_SERVICE_ROLE_KEY
if (!url || !key) {
  console.error('Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env.local')
  process.exit(1)
}

const supabase = createClient(url, key)

// Get the most recent inscription
const { data: rows, error } = await supabase
  .from('inscricoes')
  .select('id, created_at, nome, email, evento_id, events:evento_id(slug, title)')
  .order('created_at', { ascending: false })
  .limit(3)

if (error || !rows?.length) {
  console.error('Failed to fetch inscriptions:', error)
  process.exit(1)
}

console.log(`Found ${rows.length} inscription(s). Fetching PDF for each...`)

for (const row of rows) {
  const pdfUrl = `https://www.conhecafarmacia.com/api/comprovativo/${row.id}/pdf?lang=pt`
  console.log(`\nInscription (id: ${row.id})`)
  console.log(`  Event: ${row.events?.title}`)
  console.log(`  Fetching: ${pdfUrl}`)

  const res = await fetch(pdfUrl)
  if (!res.ok) {
    console.error(`  ✗ HTTP ${res.status}: ${await res.text()}`)
    continue
  }

  const buf = Buffer.from(await res.arrayBuffer())
  const filename = `preview-comprovativo-${row.id}.pdf`
  const out = join(process.cwd(), '.next', filename)
  writeFileSync(out, buf)
  console.log(`  ✓ Wrote ${out} (${buf.length} bytes)`)
}

console.log('\nOpen the PDF(s) in .next/ to inspect before deploying.')
