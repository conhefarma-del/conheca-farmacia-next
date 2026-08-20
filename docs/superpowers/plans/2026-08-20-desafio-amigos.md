# Desafio entre Amigos — Plano de Implementação (2026-08-20, v1)

> Feature social que permite a utilizadores com conta criar competições
> síncronas de 2-4 jogadores. O criador configura o desafio e convida
> amigos por código ou pesquisa direta. Resultados ficam no perfil de ambos.

## Decisões do utilizador (2026-08-20)

| # | Pergunta | Opção escolhida |
|---|----------|-----------------|
| 1 | Como convidar | **Ambos** — código de convite + pesquisa de amigos por nome/email |
| 2 | Sincronia | **Síncrono** — ambos entram ao mesmo tempo, quiz com timer, resultado imediato |
| 3 | Nº jogadores | **2-4 jogadores** — grupo pequeno, mais competitivo |
| 4 | Encontrar amigo | **Pesquisa por nome/email** — campo de busca que encontra qualquer utilizador com conta |
| 5 | Resultados | **Perfil de ambos** — resultado aparece no histórico de competições de cada jogador |
| 6 | Notificação | **Ambos** — sino no header com badge + página de competição com convites pendentes |
| 7 | Configuração | **Pelo criador** — escolhe nº perguntas (5/10/15), tempo (15s/30s/45s), tipos de perguntas |

## Arquitetura

### Fluxo completo

```
┌─────────────────────────────────────────────────────────────────┐
│  1. CRIAR DESAFIO                                               │
│  /competicao/amigos/criar                                       │
│  → Configurar: nº perguntas, tempo, tipos                       │
│  → Convidar: pesquisa por nome/email OU copiar código            │
│  → Cria competition (status: 'lobby', is_friend_challenge: true)│
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. CONVIDAR                                                    │
│  Opção A: Código → copia → partilha por WhatsApp/SMS             │
│  Opção B: Pesquisa → seleciona amigo → envia convite            │
│     → Amigo vê notificação no sino (header) + em /competicao    │
│     → Amigo clica "Aceitar" → entra no lobby                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. LOBBY                                                       │
│  /competicao/amigos/[code]                                      │
│  → Lista de jogadores (nome + avatar + estado: pronto/pendente) │
│  → Cronograma: "A começar em X segundos" quando todos prontos   │
│  → Criador pode começar quando todos estiverem prontos          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. QUIZ SÍNCRONO                                               │
│  → Perguntas com timer compartilhado                            │
│  → Pontuação ao vivo (cada resposta atualiza o leaderboard)     │
│  → Streak bônus (3+ = +50, 5+ = +100, 8+ = +200)              │
│  → Todos respondem à mesma pergunta ao mesmo tempo              │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  5. RESULTADO                                                   │
│  → Pódio: 1º, 2º, 3º, 4º lugar                                │
│  → Estatísticas: precisão, streak, tempo médio por pergunta     │
│  → Opção: "Desafiar novamente" / "Voltar ao perfil"             │
│  → Resultado guardado no histórico de ambos                     │
└─────────────────────────────────────────────────────────────────┘
```

### Convidar por código vs. pesquisa

```
┌─────────────────────────────────────────────────┐
│  CONVIDAR AMIGO                                 │
│                                                 │
│  ┌─────────────────┐  ┌─────────────────────┐  │
│  │  Pesquisar       │  │  Código de convite  │  │
│  │  (nome/email)    │  │  CF-ABC123          │  │
│  │                  │  │  [Copiar] [Partilhar]│  │
│  │  [Buscar]        │  │                     │  │
│  │  → Resultados    │  │  Amigo entra em     │  │
│  │  → Selecionar    │  │  /competicao e usa  │  │
│  │  → Convidar      │  │  o código           │  │
│  └─────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Schema — Alterações necessárias

### Tabela `competitions` — campos novos

| Campo | Tipo | Default | Descrição |
|---|---|---|---|
| `is_friend_challenge` | BOOLEAN | `false` | Marca competição como desafio entre amigos |
| `created_by_user_id` | UUID FK → auth.users | NULL | ID do utilizador que criou (senão é admin/instituição) |
| `max_players` | INTEGER | `4` | Nº máximo de jogadores (2-4) |
| `lobby_timeout_seconds` | INTEGER | `120` | Timeout do lobby (2 min padrão) |

### Tabela `competition_invites` (nova)

```sql
CREATE TABLE public.competition_invites (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  competition_id  UUID NOT NULL REFERENCES public.competitions(id) ON DELETE CASCADE,
  inviter_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invitee_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,  -- NULL se por código
  invite_code     TEXT NOT NULL,        -- código de acesso da competição
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  responded_at    TIMESTAMPTZ,
  UNIQUE (competition_id, invitee_user_id)  -- um convite por amigo por competição
);
```

### Tabela `competition_sessions` — campos novos

| Campo | Tipo | Default | Descrição |
|---|---|---|---|
| `is_ready` | BOOLEAN | `false` | Jogador está pronto no lobby |
| `started_at` | TIMESTAMPTZ | NULL | Quando o jogador começou a responder |

### RLS — Competition invites

| Operação | Regra |
|---|---|
| SELECT | Convites onde sou `inviter_user_id` ou `invitee_user_id` |
| INSERT | Sou o `inviter_user_id` E a competição sou owner |
| UPDATE | Sou o `invitee_user_id` (aceitar/rejeitar) |

## Componentes novos

| Componente | Localização | Descrição |
|---|---|---|
| `FriendChallengeCreate` | `components/pages/FriendChallengeCreate.jsx` | Formulário de criação: config + convidar amigos |
| `FriendChallengeLobby` | `components/pages/FriendChallengeLobby.jsx` | Lobby com lista de jogadores + countdown |
| `FriendChallengeQuiz` | `components/pages/FriendChallengeQuiz.jsx` | Quiz síncrono com leaderboard ao vivo |
| `FriendChallengeResult` | `components/pages/FriendChallengeResult.jsx` | Pódio + estatísticas + opções pós-jogo |
| `InviteSearchBar` | `components/ui/InviteSearchBar.jsx` | Pesquisa de amigos por nome/email |
| `InviteNotifications` | `components/ui/InviteNotifications.jsx` | Convites pendentes no sino do header |
| `CompetitionInviteCard` | `components/ui/CompetitionInviteCard.jsx` | Card de convite para aceitar/rejeitar |

## Rotas novas

| Rota | Tipo | Descrição |
|---|---|---|
| `/[lang]/competicao/amigos` | Auth required | Lista de desafios pendentes + criar novo |
| `/[lang]/competicao/amigos/criar` | Auth required | Criar desafio: config + convidar |
| `/[lang]/competicao/amigos/[code]` | Auth required | Lobby → Quiz → Resultado |

## Server actions novas

| Action | Ficheiro | Descrição |
|---|---|---|
| `createFriendChallenge(config)` | `lib/actions/competition.js` | Cria competição `is_friend_challenge=true` + gera código |
| `searchUsersForInvite(query)` | `lib/actions/competition.js` | Pesquisa utilizadores por nome/email (exclui bloqueados) |
| `sendFriendInvite(competitionId, userId)` | `lib/actions/competition.js` | Envia convite a um utilizador |
| `acceptFriendInvite(inviteId)` | `lib/actions/competition.js` | Aceita convite → entra no lobby |
| `declineFriendInvite(inviteId)` | `lib/actions/competition.js` | Rejeita convite |
| `getPendingInvites()` | `lib/actions/competition.js` | Lista convites pendentes (para sino) |
| `setPlayerReady(sessionId)` | `lib/actions/competition.js` | Marca jogador como pronto no lobby |
| `startFriendQuiz(competitionId)` | `lib/actions/competition.js` | Criador inicia o quiz quando todos prontos |
| `submitFriendAnswer(sessionId, answer)` | `lib/actions/competition.js` | Submete resposta + atualiza leaderboard ao vivo |
| `getFriendLeaderboard(competitionId)` | `lib/actions/competition.js` | Leaderboard ao vivo (polling 3s) |

## Fluxo do sino de notificações

```
Header: [🔔 2] ← badge com nº de convites pendentes
  ↓ clica
┌─────────────────────────────────────────┐
│  Convites Pendentes                      │
│                                          │
│  🧑 Maria Silva desafiou-te!             │
│  "Quiz Rápido — 10 perguntas"            │
│  [Aceitar] [Rejeitar]                    │
│                                          │
│  🧑 João Santos desafiou-te!             │
│  "Desafio Farmacologia"                  │
│  [Aceitar] [Rejeitar]                    │
└─────────────────────────────────────────┘
```

### Componente sino — alterações no Header

```jsx
// components/layout/Header.jsx
// Adicionar sino ao lado do profile dropdown
{user && (
  <InviteNotifications lang={lang} />
)}
```

O sino:
- Mostra badge vermelho com nº de convites pendentes
- Ao clicar, abre dropdown com lista de convites
- Cada convite mostra: nome do desafiador, nome do desafio, data
- Botões "Aceitar" e "Rejeitar" inline
- Redireciona para `/competicao/amigos/[code]` ao aceitar

## Quiz síncrono — Arquitetura técnica

### Como funciona o timer compartilhado

```
1. Server cria sessão com started_at = agora + N segundos (countdown)
2. Todos os jogadores recebem started_at via polling
3. Cada cliente calcula: elapsed = now() - started_at
4. Pergunta atual = floor(elapsed / time_per_question) % total_questions
5. Tempo restante = time_per_question - (elapsed % time_per_question)
```

**Vantagem**: Não depende de conexão perfeita — cada cliente calcula localmente.

### Leaderboard ao vivo

```
Cada 3 segundos:
  → GET /api/competition/[code]/leaderboard
  → Resposta: [{name, score, correct, streak, position}]
  → Cliente atualiza UI com animação de transição
```

### Anti-cheating (simplificado para amigos)

- Respostas validadas no servidor (mesmo padrão de competições existentes)
- Cada resposta inclui `client_timestamp` + `server_timestamp`
- Se diferença > 5 segundos → flag como suspicious (não bane, mas mostra aviso)

## Página /competicao/amigos — Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  🏆 DESAFIOS ENTRE AMIGOS                                       │
│  Desafia os teus amigos a um quiz de farmacologia!              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Desafios Pendentes (2)                                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ 🧑 Maria Silva desafiou-te — "Quiz Rápido"              │   │
│  │ 10 perguntas • 30s • Farmacologia                       │   │
│  │ [Aceitar] [Rejeitar]                                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ 🧑 João Santos desafiou-te — "Desafio Interactions"      │   │
│  │ 15 perguntas • 45s • Interações + Classes               │   │
│  │ [Aceitar] [Rejeitar]                                     │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  [+ Criar Desafio]         [Entrar com Código]                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Histórico de Desafios                                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ 🥇 1º lugar — vs Maria Silva — 850 pts — 12/ago         │   │
│  │ 🥈 2º lugar — vs João Santos — 720 pts — 10/ago         │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Página /competicao/amigos/criar — Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  CRIAR DESAFIO                                                  │
│  Configura o teu quiz e convida amigos!                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Configuração                                                   │
│  Nome do desafio: [Quiz Farmacologia     ]                      │
│  Perguntas:       [5] [10✓] [15]                                │
│  Tempo por pergunta: [15s] [30s✓] [45s]                         │
│  Tipos de perguntas:                                            │
│  [✓] Farmacologia  [✓] Interações  [ ] Flashcards              │
│  [ ] Protocolos    [✓] Classes                                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Convidar Amigos                                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Pesquisar por nome ou email...              [Buscar]     │   │
│  │                                                          │   │
│  │ Resultados:                                              │   │
│  │ 🧑 Maria Silva — maria@email.com        [Convidar]       │   │
│  │ 🧑 Pedro Costa — pedro@email.com        [Convidar]       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ─── OU ───                                                     │
│                                                                 │
│  Código de convite: CF-ABC123  [Copiar] [Partilhar WhatsApp]    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  [Criar Desafio]                                                │
└─────────────────────────────────────────────────────────────────┘
```

## i18n keys necessárias

### PT
```json
{
  "friend_challenge": {
    "title": "Desafios entre Amigos",
    "subtitle": "Desafia os teus amigos a um quiz de farmacologia!",
    "create_title": "Criar Desafio",
    "create_subtitle": "Configura o teu quiz e convida amigos!",
    "config_name": "Nome do desafio",
    "config_questions": "Perguntas",
    "config_time": "Tempo por pergunta",
    "config_types": "Tipos de perguntas",
    "invite_search": "Pesquisar por nome ou email...",
    "invite_searching": "A pesquisar...",
    "invite_no_results": "Nenhum utilizador encontrado",
    "invite_send": "Convidar",
    "invite_sent": "Convite enviado!",
    "invite_code": "Código de convite",
    "invite_copy": "Copiar",
    "invite_copied": "Copiado!",
    "invite_share": "Partilhar WhatsApp",
    "invite_or": "OU",
    "pending_title": "Desafios Pendentes",
    "pending_empty": "Nenhum desafio pendente",
    "pending_from": "{name} desafiou-te!",
    "accept": "Aceitar",
    "decline": "Rejeitar",
    "lobby_title": "Sala de Espera",
    "lobby_waiting": "A esperar por {name}...",
    "lobby_ready": "Pronto!",
    "lobby_not_ready": "Ainda não",
    "lobby_start": "Começar Quiz",
    "lobby_start_all": "Todos prontos! A começar...",
    "lobby_timeout": "A competição vai começar em {seconds}s",
    "quiz_title": "Desafio em Curso",
    "quiz_position": "{position}º lugar",
    "quiz_score": "{score} pontos",
    "quiz_streak": "Streak: {streak}",
    "result_title": "Resultado Final",
    "result_winner": "Vencedor!",
    "result_stats_accuracy": "Precisão",
    "result_stats_streak": "Melhor Streak",
    "result_stats_avg_time": "Tempo Médio",
    "result_rematch": "Desafiar Novamente",
    "result_profile": "Ver Perfil",
    "history_title": "Histórico de Desafios",
    "history_vs": "vs {name}",
    "history_place": "{place}º lugar"
  }
}
```

### EN
```json
{
  "friend_challenge": {
    "title": "Friend Challenges",
    "subtitle": "Challenge your friends to a pharmacy quiz!",
    "create_title": "Create Challenge",
    "create_subtitle": "Set up your quiz and invite friends!",
    "config_name": "Challenge name",
    "config_questions": "Questions",
    "config_time": "Time per question",
    "config_types": "Question types",
    "invite_search": "Search by name or email...",
    "invite_searching": "Searching...",
    "invite_no_results": "No users found",
    "invite_send": "Invite",
    "invite_sent": "Invite sent!",
    "invite_code": "Invite code",
    "invite_copy": "Copy",
    "invite_copied": "Copied!",
    "invite_share": "Share on WhatsApp",
    "invite_or": "OR",
    "pending_title": "Pending Challenges",
    "pending_empty": "No pending challenges",
    "pending_from": "{name} challenged you!",
    "accept": "Accept",
    "decline": "Decline",
    "lobby_title": "Waiting Room",
    "lobby_waiting": "Waiting for {name}...",
    "lobby_ready": "Ready!",
    "lobby_not_ready": "Not yet",
    "lobby_start": "Start Quiz",
    "lobby_start_all": "Everyone ready! Starting...",
    "lobby_timeout": "Quiz starts in {seconds}s",
    "quiz_title": "Challenge in Progress",
    "quiz_position": "{position}th place",
    "quiz_score": "{score} points",
    "quiz_streak": "Streak: {streak}",
    "result_title": "Final Results",
    "result_winner": "Winner!",
    "result_stats_accuracy": "Accuracy",
    "result_stats_streak": "Best Streak",
    "result_stats_avg_time": "Average Time",
    "result_rematch": "Rematch",
    "result_profile": "View Profile",
    "history_title": "Challenge History",
    "history_vs": "vs {name}",
    "history_place": "{place}th place"
  }
}
```

## Roadmap de implementação

| Fase | O que | Tempo est. | Dependências |
|---|---|---|---|
| **1** | Migração: `is_friend_challenge`, `max_players`, `competition_invites` | 1h | — |
| **2** | Server actions: criar desafio, convidar, aceitar, lobby, leaderboard | 3h | Fase 1 |
| **3** | Página criar desafio (config + pesquisa amigos + código) | 2h | Fase 2 |
| **4** | Lobby (lista jogadores + countdown + ready state) | 2h | Fase 2 |
| **5** | Quiz síncrono (timer compartilhado + leaderboard ao vivo) | 3h | Fase 4 |
| **6** | Resultado (pódio + stats + rematch) | 1.5h | Fase 5 |
| **7** | Sino de notificações no header (convites pendentes) | 2h | Fase 2 |
| **8** | Página /competicao/amigos (histórico + convites pendentes) | 1.5h | Fase 7 |
| **9** | i18n + loading skeletons + polish | 1h | Todas |
| **Total** | | **~17h** | |

## Dependências com planos anteriores

| Plano | Relação |
|---|---|
| `2026-08-19-quiz-competicao.md` | Reutiliza engine de quiz, server actions, CompetitionSessionClient |
| `2026-08-20-instituicoes.md` | Independente — feature social vs. feature institucional |
| Migração 234 (`competition_sessions`) | Adiciona `is_ready`, `started_at` |
| Migração 233 (`schools`) | Independente |

## Checklist de implementação

- [ ] **Fase 1**: Migração SQL (campos novos + competition_invites)
- [ ] **Fase 2**: Server actions (criar, convidar, aceitar, lobby, leaderboard)
- [ ] **Fase 3**: Página criar desafio (config + pesquisa + código)
- [ ] **Fase 4**: Lobby (jogadores + countdown + ready)
- [ ] **Fase 5**: Quiz síncrono (timer + leaderboard ao vivo)
- [ ] **Fase 6**: Resultado (pódio + stats + rematch)
- [ ] **Fase 7**: Sino de notificações no header
- [ ] **Fase 8**: Página /competicao/amigos (histórico + pendentes)
- [ ] **Fase 9**: i18n + polish
