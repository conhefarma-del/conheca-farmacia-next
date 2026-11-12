-- 299: fechar o INSERT directo em inscricoes
--
-- A política "Public can insert inscricoes" (014/141) e os grants por omissão
-- do Supabase permitem que `anon` insira directamente, sem passar pela RPC —
-- contornando capacidade e duplicados. Toda a escrita pública passa pela
-- Server Action com service role, por isso a porta pode fechar.
--
-- Mantém-se o SELECT dos admins e o UPDATE dos admins (marcar presença);
-- o cancelamento passa a ser feito com service role pela RPC 300.

begin;

drop policy if exists "Public can insert inscricoes" on public.inscricoes;
-- Policy legacy do dashboard, redundante com admin_read_inscricoes.
drop policy if exists "Admins can read inscricoes" on public.inscricoes;

revoke insert on public.inscricoes from anon, authenticated;

commit;
