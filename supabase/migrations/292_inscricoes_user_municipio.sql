-- Inscrições ligadas à conta, e com município.
--
-- Até aqui `inscricoes` só sabia o e-mail — e um e-mail muda. Com `user_id` a
-- inscrição passa a ter um dono estável, e um endereço novo deixa de esconder
-- o histórico. Inscrever-se sem conta continua a funcionar: `user_id` fica
-- null (a inscrição vive pelo comprovativo e pelo e-mail).
--
-- O backfill liga o que já existe. É seguro repetir: só toca em linhas sem
-- dono cujo e-mail ainda corresponde a uma conta.
--
-- `municipio` é informativo (como o telefone) e é o que a farmácia/organização
-- usa para se orientar; não há lista fechada — o país tem municípios a mais
-- para a manter aqui.

alter table public.inscricoes
  add column if not exists user_id uuid references auth.users (id) on delete set null;

alter table public.inscricoes
  add column if not exists municipio text;

create index if not exists inscricoes_user_idx
  on public.inscricoes (user_id, created_at desc);

update public.inscricoes i
   set user_id = u.id
  from auth.users u
 where i.user_id is null
   and lower(i.email) = lower(u.email);
