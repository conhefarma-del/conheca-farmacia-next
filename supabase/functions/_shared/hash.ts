// djb2 hash, 8 chars hex lowercase.
// Espelha `hashEmail()` em `lib/actions/inscription.js:53-63` (Server Action)
// para que os logs das Edges e os logs do Next.js sejam correlacionáveis
// sem expor PII (email raw nunca vai para os logs).
export function hashEmail(email: string | null | undefined): string | null {
  const s = (email || '').toLowerCase().trim();
  if (!s) return null;
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = (h * 31 + s.charCodeAt(i)) | 0;
  }
  return (h >>> 0).toString(16).padStart(8, '0');
}
