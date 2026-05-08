# Guia de Adição de Lives e Webinars

Este documento descreve como adicionar novas lives e webinars ao catálogo do site Conheça Farmácia.

## Visão Geral

As lives e webinars são geridos separadamente dos eventos presenciais/online tradicionais. Enquanto os eventos (workshops, palestras, congressos) usam o sistema de inscrições com o Supabase, as lives e webinars são páginas de acesso direto com links para plataformas de streaming.

- **Eventos**: `events-catalog.json` → `evento.html?id=<slug>`
- **Lives/Webinars**: `lives-catalog.json` → `lives.html?id=<slug>`

## Arquivo: `lives-catalog.json`

O ficheiro `src/content/lives-catalog.json` contém todos as lives e webinars do site.

### Estrutura do JSON

Cada entrada deve seguir este formato:

```json
{
  "slug": "004-live-covid-tratamento",
  "titulo": "Live: COVID-19 e Novos Tratamentos — O que Mudou?",
  "data": "2026-05-10",
  "hora": "19:00",
  "plataforma": "YouTube Live",
  "link_acesso": "https://youtube.com/live/exemplo",
  "id_reuniao": "",
  "senha": "",
  "materiais_apoio": ["https://exemplo.com/material-covid.pdf"],
  "categoria": "live",
  "categoriaLabel": "Live",
  "imagem": "/content/articles/live_valorizacao_carreira.png",
  "resumo": "Transmissão ao vivo discutindo atualizações sobre COVID-19 e opções terapêuticas emergentes.",
  "anfitriao": {
    "nome": "João Pedro",
    "cargo": "Farmacêutico · Palestrante",
    "organizacao": "Conheça Farmácia"
  }
}
```

### Campos Obrigatórios

| Campo                   | Tipo                | Descrição                           | Exemplo                                 |
| ----------------------- | ------------------- | ----------------------------------- | --------------------------------------- |
| `slug`                  | string              | Identificador único em URL-friendly | `004-live-covid-tratamento`             |
| `titulo`                | string              | Título completo da live/webinar     | `Live: COVID-19 e Novos Tratamentos`    |
| `data`                  | string (YYYY-MM-DD) | Data do evento                      | `2026-05-10`                            |
| `hora`                  | string (HH:MM)      | Hora de início                      | `19:00`                                 |
| `plataforma`            | string              | Plataforma de streaming             | `YouTube Live`, `Zoom`, `Facebook Live` |
| `link_acesso`           | string (URL)        | Link direto para aceder à live      | `https://youtube.com/live/exemplo`      |
| `id_reuniao`            | string (opcional)   | ID da reunião (Zoom, Teams)         | `123 456 7890`                          |
| `senha`                 | string (opcional)   | Senha de acesso                     | `abc123`                                |
| `materiais_apoio`       | array               | Lista de URLs de materiais          | `["https://exemplo.com/material.pdf"]`  |
| `categoria`             | string              | `live` ou `webinar`                 | `live`                                  |
| `categoriaLabel`        | string              | Rótulo para exibição                | `Live` ou `Webinar`                     |
| `imagem`                | string (URL)        | Caminho da imagem de capa           | `/content/articles/live.png`            |
| `resumo`                | string              | Descrição curta do evento           | `Transmissão ao vivo sobre...`          |
| `anfitriao.nome`        | string              | Nome do apresentador                | `João Pedro`                            |
| `anfitriao.cargo`       | string              | Cargo/função                        | `Farmacêutico · Palestrante`            |
| `anfitriao.organizacao` | string              | Organização                         | `Conheça Farmácia`                      |

## Como Adicionar uma Nova Live/Webinar

1. Abra o ficheiro `src/content/lives-catalog.json`
2. Adicione um novo objeto ao array `events`
3. Preencha todos os campos obrigatórios
4. Certifique-se de que o `slug` é único
5. Teste acedendo a `lives.html?id=<seu-slug>`

## Exemplo de Entrada Completa

```json
{
  "slug": "011-live-nutricao-farmacologia",
  "titulo": "Live: Nutrição e Farmacologia — Interações Alimentares",
  "data": "2026-06-15",
  "hora": "20:00",
  "plataforma": "YouTube Live",
  "link_acesso": "https://youtube.com/live/nutricao-farmacologia",
  "id_reuniao": "",
  "senha": "",
  "materiais_apoio": [
    "https://exemplo.com/material-nutricao.pdf",
    "https://exemplo.com/guia-interacoes.pdf"
  ],
  "categoria": "live",
  "categoriaLabel": "Live",
  "imagem": "/content/articles/live-nutricao.png",
  "resumo": "Discussão sobre interações entre alimentos e medicamentos, com foco em práticos clínicos.",
  "anfitriao": {
    "nome": "Ana Costa",
    "cargo": "Nutricionista · Palestrante",
    "organizacao": "Conheça Farmácia"
  }
}
```

## Diferenças Entre Lives e Webinars

| Característica | Live                             | Webinar                           |
| -------------- | -------------------------------- | --------------------------------- |
| Duração        | Curta (15-45 min)                | Longa (60-90 min)                 |
| Interação      | Alta (comentários em tempo real) | Moderada (perguntas estruturadas) |
| Gravação       | Opcional                         | Sempre gravado                    |
| Materiais      | Raro                             | Comum                             |
| Plataforma     | YouTube, Facebook                | Zoom, Teams                       |

## URLs de Acesso

- **Listar todas as lives**: `lives-list.html` (página completa com filtros)
- **Detalhe de uma live**: `lives.html?id=<slug>`
- **Exemplo**: `lives.html?id=004-live-covid-tratamento`

## Notas Importantes

1. **Sem inscrições**: Lives e webinars não usam o sistema de inscrições do Supabase
2. **Acesso direto**: O botão "Aceder Agora" leva diretamente à plataforma
3. **Sem capacidade máxima**: Não há limite de vagas para lives online
4. **ID e senha**: Preencha apenas se a plataforma exigir (ex: Zoom)
5. **Materiais de apoio**: Opcional, mas recomendado para webinars
6. **Página de listagem**: Use `lives-list.html` para ver todas as lives com filtros de data e categoria

## Eventos vs Lives

| Recurso    | Eventos (workshop/palestra/congresso) | Lives/Webinars       |
| ---------- | ------------------------------------- | -------------------- |
| Arquivo    | `events-catalog.json`                 | `lives-catalog.json` |
| Listagem   | `eventos.html`                        | `lives-list.html`    |
| Detalhe    | `evento.html`                         | `lives.html`         |
| Inscrições | Sim (Supabase)                        | Não                  |
| Capacidade | Limitada                              | Ilimitada            |
| Pagamento  | Possível                              | Gratuito             |
| RLS        | Sim                                   | Não                  |

## Atualizações

Após adicionar uma nova live/webinar:

1. O catálogo é atualizado automaticamente na Home
2. A página `lives.html` carrega os dados dinamicamente
3. Não é necessário fazer build/deploy se usar Vite dev server

---

**Nota**: Para eventos que exigem inscrição, use `events-catalog.json` em vez de `lives-catalog.json`.
