---
name: Módulo de Entrevistas
description: Arquitetura e funcionalidades do módulo de Entrevistas - segue padrão Artigos (2026-05-10)
type: project
---

**Módulo de Entrevistas** - Implementação de entrevistas com profissionais de saúde e figuras importantes do sector.

**Arquitetura:** Segue padrão Artigos
- `entrevistas.html` — Página de listagem (grid + filtros + pesquisa)
- `entrevista.html` — Página de detalhe (layout 2/3 conteúdo + 1/3 sidebar)
- `src/content/interviews-catalog.json` — Catálogo de dados
- `src/interviews-logic.js` — Lógica da lista
- `src/interview-detail.js` — Lógica do detalhe
- `src/interview-video.js` — Módulo de vídeo (YouTube API + Video.js)

**Funcionalidades implementadas:**
- Vídeo YouTube com lazy loading (thumbnail clica → carrega player)
- Suporte para áudio embed (Spotify, SoundCloud)
- Sumário executivo opcional (campo `executiveSummary` no JSON)
- Pull quotes com bg-brand-bg e aspas grandes
- Q&A em timeline vertical
- Transcrição expansível (toggle expandir/recolher)
- Botões de partilha (Twitter, LinkedIn, WhatsApp, copiar link)
- Filtros por categoria + pesquisa na lista

**Decisões de design:**
- YouTube API com simulação de lite embed (thumbnail + clique para carregar)
- Apenas entrevistado mostrado (sem autor/entrevistador)
- Video.js skin completo (cores da marca, ícones personalizados, animações)

**Why:** Novo módulo de conteúdo para expandir o site com entrevistas em vídeo e texto.
**How to apply:** Usar como referência para futuros módulos de conteúdo; seguir padrões estabelecidos (JSON catalog + logic.js + detail.js).
