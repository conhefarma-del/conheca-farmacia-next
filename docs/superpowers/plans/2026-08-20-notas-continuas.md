# Sistema de Anotações Contínuas — Plano de Implementação (2026-08-20, v1)

> Feature que permite ao utilizador criar e gerir anotações contínuas por item guardado.
> Acedido via botão "Notas" ao lado do SaveButton em qualquer página com guardar,
> com visualização completa na página dedicada `/anotacoes`.

## Decisões do utilizador (2026-08-20)

| # | Pergunta | Opção escolhida |
|---|----------|-----------------|
| 1 | Tipo de nota | **Uma contínua por item** (não múltiplas notas separadas) |
| 2 | Estado inicial do drawer | **Sempre encolhido** (só header + seta) |
| 3 | Guardar | **Auto-save** (debounce 1-2s) |
| 4 | Desktop | **Sidebar à direita** (não bottom sheet) |
| 5 | Visibilidade | **Aparece em `/anotacoes`** |
| 6 | Acesso | **Menu do utilizador**: Notas + Guardados (abaixo de Perfil) |
| 7 | Autenticação | **Sim**, redirect `/entrar` |
| 8 | Apresentação | **Título do item + preview 2-3 linhas** |
| 9 | Clique numa nota | **Expande in-place** + link para página do item |
| 10 | Pesquisa | **Por nome do item + conteúdo da nota** |
| 11 | Edição | **Inline** (clica e edita) |
| 12 | Eliminar | **Botão confirmação + swipe mobile** |
| 13 | Filtros | **Tabs por tipo de item** |
| 14 | Ordenação | **Mais recente primeiro** |
| 15 | Paginação | **"Carregar mais"** |
| 16 | Stats | **Só total de notas** |
| 17 | Última atualização | **Por nota** |
| 18 | Mobile | **Bottom sheet** (draggable) |
| 19 | Desktop sidebar | **Só quando ativada pelo botão** |

---

## 1. Visão Geral

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        COMO O UTILIZADOR INTERAGE                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Botão "Notas" ao lado de "Guardar" em qualquer página de conteúdo       │
│     ↓                                                                       │
│  2. Desktop: sidebar abre à direita | Mobile: bottom sheet sobe             │
│     ↓                                                                       │
│  3. Estado inicial: encolhido (só "Notas de [item]" + seta)                 │
│     ↓                                                                       │
│  4. Clica seta / arrasta para cima → expande                                │
│     ↓                                                                       │
│  5. Escreve nota contínua → auto-save                                       │
│     ↓                                                                       │
│  6. Nota aparece em /anotacoes com link de volta ao item                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Schema — Alterações

### 2.1 Tabela `saved_item_notes` — alterações

A tabela atual obriga `saved_item_id NOT NULL`. Para suportar nota contínua (uma só por item), precisamos de:

```sql
-- 1. Garantir unicidade: uma nota por (user_id, saved_item_id)
ALTER TABLE public.saved_item_notes
  ADD CONSTRAINT unique_note_per_item
  UNIQUE (user_id, saved_item_id);

-- 2. Index para pesquisa por conteúdo
CREATE INDEX idx_saved_notes_content ON public.saved_item_notes
  USING gin(to_tsvector('portuguese', content));
```

**NOTA:** O schema atual já suporta nota contínua — basta usar `upsert` em vez de `insert`. A constraint `UNIQUE` garante que não existem múltiplas notas por item.

### 2.2 View: `user_notes_with_item`

Vista para a página `/anotacoes` que junta notas com informações do item:

```sql
CREATE OR REPLACE VIEW public.user_notes_with_item AS
SELECT
  n.id,
  n.user_id,
  n.content,
  n.created_at,
  n.updated_at,
  si.id AS saved_item_id,
  si.item_type,
  si.item_slug,
  si.item_name,
  si.item_subtitle,
  -- Link direto para a página do item
  CASE si.item_type
    WHEN 'drug' THEN '/' || 'pt' || '/medicamentos/' || si.item_slug
    WHEN 'interaction' THEN '/' || 'pt' || '/interacoes'
    WHEN 'drug_class' THEN '/' || 'pt' || '/classes/' || si.item_slug
    WHEN 'molecular_target' THEN '/' || 'pt' || '/alvos/' || si.item_slug
    WHEN 'article' THEN '/' || 'pt' || '/artigos/' || si.item_slug
    ELSE '#'
  END AS item_url
FROM public.saved_item_notes n
JOIN public.saved_items si ON si.id = n.saved_item_id;
```

---

## 3. Server Actions (`lib/actions/saved.js`)

### 3.1 Funções novas

| Função | Descrição |
|--------|-----------|
| `getNoteForItem(savedItemId)` | Busca a nota contínua de um item (upsert-friendly) |
| `upsertNote(savedItemId, content)` | Cria ou atualiza a nota de um item (auto-save) |
| `getAllNotes({ search?, type?, page?, limit? })` | Lista todas as notas do utilizador com filtros |
| `getNotesCount()` | Conta notas por tipo |
| `deleteNoteById(noteId)` | Elimina nota por ID |

### 3.2 Implementação de `upsertNote`

```js
export async function upsertNote(savedItemId, content) {
  const { supabase, user } = await getUser()
  if (!user) return { success: false, error: 'auth_required' }

  if (!content || !content.trim()) {
    // Content vazio → eliminar nota se existe
    const { error } = await supabase
      .from('saved_item_notes')
      .delete()
      .eq('saved_item_id', savedItemId)
      .eq('user_id', user.id)
    return { success: true, note: null }
  }

  if (content.trim().length > 5000) {
    return { success: false, error: 'content_too_long' }
  }

  // Upsert: insere ou atualiza
  const { data, error } = await supabase
    .from('saved_item_notes')
    .upsert({
      saved_item_id: savedItemId,
      user_id: user.id,
      content: content.trim(),
      updated_at: new Date().toISOString(),
    }, {
      onConflict: 'user_id,saved_item_id',
    })
    .select('id, content, created_at, updated_at')
    .single()

  if (error) return { success: false, error: error.message }
  return { success: true, note: data }
}
```

### 3.3 Implementação de `getAllNotes`

```js
export async function getAllNotes({ search, type, page = 1, limit = 20 } = {}) {
  const { supabase, user } = await getUser()
  if (!user) return { notes: [], total: 0, page: 1, pages: 0 }

  let query = supabase
    .from('saved_item_notes')
    .select(`
      id, content, created_at, updated_at,
      saved_item:saved_items!inner (
        id, item_type, item_slug, item_name, item_subtitle
      )
    `, { count: 'exact' })
    .eq('user_id', user.id)

  // Filtro por tipo
  if (type && type !== 'all') {
    query = query.eq('saved_item.item_type', type)
  }

  // Pesquisa por conteúdo + nome do item
  if (search && search.trim()) {
    const term = `%${search.trim()}%`
    query = query.or(`content.ilike.${term},saved_item.item_name.ilike.${term}`)
  }

  const offset = (page - 1) * limit
  query = query
    .order('updated_at', { ascending: false })
    .range(offset, offset + limit - 1)

  const { data, error, count } = await query
  if (error) return { notes: [], total: 0, page: 1, pages: 0 }

  return {
    notes: data || [],
    total: count || 0,
    page,
    pages: Math.ceil((count || 0) / limit),
  }
}
```

---

## 4. Componentes

### 4.1 `components/ui/NotesDrawer.jsx` (Client) — NOVO

Bottom sheet (mobile) + sidebar (desktop) para notas contínuas.

```
Props:
  - isOpen: boolean
  - onClose: () => void
  - itemName: string (nome do item)
  - itemSlug: string
  - itemType: string
  - lang: string

Estados:
  - collapsed: boolean (padrão: true)
  - content: string (nota contínua)
  - lastSaved: Date | null
  - saving: boolean

Comportamento:
  - Desktop (≥768px): sidebar à direita, largura 380px
  - Mobile (<768px): bottom sheet, altura 100% (expandido) ou 48px (encolhido)
  - Drag gesture no mobile: arrasta para cima/baixo
  - Auto-save: debounce 1.5s após última tecla
  - Sempre inicia encolhido

Layout encolhido:
┌────────────────────────────────┐
│ ▲ Notas de Metformina    124c │
└────────────────────────────────┘

Layout expandido (desktop):
┌──────────────────────────────┐
│ ▼ Notas de Metformina    124c│
├──────────────────────────────┤
│                              │
│  "Tomar com alimento..."     │
│                              │
│  Guardado automaticamente ✓  │
│                              │
├──────────────────────────────┤
│ Ver em /medicamentos/[slug] →│
└──────────────────────────────┘

Layout expandido (mobile):
┌──────────────────────────────┐
│ ▼ Notas de Metformina    124c│
├──────────────────────────────┤
│                              │
│  "Tomar com alimento..."     │
│                              │
│                              │
│                              │
├──────────────────────────────┤
│ Guardado automaticamente ✓   │
│ Ver em /medicamentos/[slug] →│
└──────────────────────────────┘
```

#### Drag Gesture (Mobile)

```
Touch start → y inicial
Touch move  → calcula delta
Touch end   → snap para:
  - Colapsado se delta < 50% da tela
  - Expandido se delta ≥ 50% da tela
```

#### Auto-save Logic

```
1. Utilizador digita
2. Debounce 1.5s
3. Chama upsertNote(savedItemId, content)
4. Mostra "Guardado automaticamente ✓" durante 2s
5. Se erro → mostra "Erro ao guardar" + opção retry
```

### 4.2 `components/ui/SaveButton.jsx` — MODIFICADO

Adicionar botão "Notas" ao lado do bookmark.

```
Props novas:
  - onNotesClick: () => void (abre o NotesDrawer)
  - hasNote: boolean (mostra indicador se tem nota)

Layout:
  [📌 Guardado] [📝 Notas(•)]
                    ↑ badge se tem nota
```

### 4.3 `components/pages/NotasPageClient.jsx` — NOVO

Página dedicada `/anotacoes` com lista de todas as notas.

```
Layout:
┌─────────────────────────────────────────────────────────────────┐
│ 📝 ANOTAÇÕES                                                     │
│ 32 anotações                                                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Pesquisar anotações...                                       │
│                                                                 │
│ [Todas (32)] [Medicamentos (12)] [Interações (5)]               │
│ [Classes (3)] [Alvos (2)] [Artigos (2)]                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 💊 Metformina                                                  │
│ "Tomar com alimento para reduzir desconforto GI..."            │
│ Atualizado há 2 horas                              ✏️ 🗑️       │
├─────────────────────────────────────────────────────────────────┤
│ 🔗 Metformina + AINE                                           │
│ "Risco acidose láctica — monitorizar TFG..."                   │
│ Atualizado ontem                                  ✏️ 🗑️       │
├─────────────────────────────────────────────────────────────────┤
│ 💊 Warfarina                                                   │
│ "Monitorizar INR semanalmente. Evitar AINE..."                 │
│ Atualizado há 3 dias                              ✏️ 🗑️       │
└─────────────────────────────────────────────────────────────────┘

[Carregar mais...]
```

#### Comportamento por tipo de device:

| Device | Comportamento |
|--------|---------------|
| Desktop | Clica na nota → expande in-place (mostra nota completa + link) |
| Mobile | Clica na nota → expande in-place (mostra nota completa + link) |
| Ambos | Botão ✏️ → edita inline |
| Ambos | Botão 🗑️ → confirmação → elimina |
| Ambos | Link "Ver em [página]" → navega para o item |

---

## 5. Rotas

| Rota | Tipo | Descrição |
|------|------|-----------|
| `/{lang}/anotacoes` | Nova (Auth) | Página dedicada de anotações |
| `/{lang}/anotacoes/loading.jsx` | Novo | Skeleton de carregamento |

---

## 6. Atualização do Header — Menu do Utilizador

### 6.1 Menu dropdown atual

```
┌──────────────────────────┐
│ 👤 João Silva            │
│ joao@email.com           │
├──────────────────────────┤
│ 👤 Perfil                │
│ 💊 Medicamentos    ← ELIMINAR
├──────────────────────────┤
│ 🚪 Sair                  │
└──────────────────────────┘
```

### 6.2 Menu dropdown novo

```
┌──────────────────────────┐
│ 👤 João Silva            │
│ joao@email.com           │
├──────────────────────────┤
│ 👤 Perfil                │
│ 📝 Anotações             │
│ 📌 Guardados             │
├──────────────────────────┤
│ 🚪 Sair                  │
└──────────────────────────┘
```

**Ficheiro:** `components/layout/Header.jsx`
**Mudança:** Substituir link "Medicamentos" por "Anotações" + "Guardados"

---

## 7. Páginas com Botão de Notas

### 7.1 Páginas afetadas

| Página | Ficheiro | SaveButton atual |
|--------|----------|------------------|
| `/medicamentos/[slug]` | `medicamentoDetailClient.jsx` | ✅ Existe |
| `/alvos/[slug]` | `alvoDetailClient.jsx` | ✅ Existe |
| `/classes/[slug]` | `classDetailClient.jsx` | ✅ Existe |
| `/artigos/[slug]` | `page.js` | ✅ Existe |
| `/interacoes` | `interacoesPageClient.jsx` | ✅ Existe |

### 7.2 Mudança em cada página

Adicionar estado `notesOpen` + `NotesDrawer`:

```jsx
// Em cada página que tem SaveButton:
const [notesOpen, setNotesOpen] = useState(false)

// No JSX:
<SaveButton
  {...props}
  onNotesClick={() => setNotesOpen(true)}
  hasNote={/* query isItemSaved + hasNote */}
/>

<NotesDrawer
  isOpen={notesOpen}
  onClose={() => setNotesOpen(false)}
  itemName={item.name}
  itemSlug={item.slug}
  itemType="drug"
  lang={lang}
/>
```

---

## 8. i18n Keys

### PT (`public/i18n/pt.json`)

```json
{
  "notes_drawer": {
    "title": "Notas de {name}",
    "empty": "Escreve a tua nota aqui...",
    "saved": "Guardado automaticamente",
    "saving": "A guardar...",
    "error": "Erro ao guardar",
    "retry": "Tentar novamente",
    "characters": "{n} caracteres",
    "view_item": "Ver em {page}",
    "close": "Fechar"
  },
  "notes_page": {
    "title": "Anotações",
    "subtitle": "{n} anotações",
    "search_placeholder": "Pesquisar anotações...",
    "tabs_all": "Todas",
    "tab_drug": "Medicamentos",
    "tab_interaction": "Interações",
    "tab_drug_class": "Classes",
    "tab_molecular_target": "Alvos",
    "tab_article": "Artigos",
    "empty": "Ainda não tens anotações",
    "empty_hint": "Cria anotações nos medicamentos, interações e mais",
    "updated_ago": "Atualizado {time}",
    "view_item": "Ver em {page}",
    "confirm_delete": "Eliminar esta anotação?",
    "login_required": "Precisas de conta para ver as tuas anotações",
    "load_more": "Carregar mais..."
  }
}
```

### EN (`public/i18n/en.json`)

```json
{
  "notes_drawer": {
    "title": "Notes for {name}",
    "empty": "Write your note here...",
    "saved": "Saved automatically",
    "saving": "Saving...",
    "error": "Error saving",
    "retry": "Try again",
    "characters": "{n} characters",
    "view_item": "View on {page}",
    "close": "Close"
  },
  "notes_page": {
    "title": "Notes",
    "subtitle": "{n} notes",
    "search_placeholder": "Search notes...",
    "tabs_all": "All",
    "tab_drug": "Medications",
    "tab_interaction": "Interactions",
    "tab_drug_class": "Classes",
    "tab_molecular_target": "Targets",
    "tab_article": "Articles",
    "empty": "You don't have any notes yet",
    "empty_hint": "Create notes on medications, interactions and more",
    "updated_ago": "Updated {time}",
    "view_item": "View on {page}",
    "confirm_delete": "Delete this note?",
    "login_required": "You need an account to view your notes",
    "load_more": "Load more..."
  }
}
```

---

## 9. CSS — Estilos Novos

### 9.1 NotesDrawer (Desktop Sidebar)

```css
/* Desktop sidebar */
.notes-drawer-desktop {
  position: fixed;
  top: 0;
  right: 0;
  width: 380px;
  height: 100vh;
  background: var(--color-brand-bg);
  border-left: 1px solid var(--color-brand-divider);
  z-index: 50;
  transform: translateX(100%);
  transition: transform 0.3s ease;
  display: flex;
  flex-direction: column;
}

.notes-drawer-desktop.is-open {
  transform: translateX(0);
}

/* Backdrop */
.notes-drawer-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.3);
  z-index: 49;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s;
}

.notes-drawer-backdrop.is-open {
  opacity: 1;
  pointer-events: auto;
}
```

### 9.2 NotesDrawer (Mobile Bottom Sheet)

```css
/* Mobile bottom sheet */
.notes-drawer-mobile {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: var(--color-brand-bg);
  border-top: 1px solid var(--color-brand-divider);
  border-radius: 16px 16px 0 0;
  z-index: 50;
  transition: height 0.3s ease;
  display: flex;
  flex-direction: column;
}

/* Estado encolhido */
.notes-drawer-mobile.is-collapsed {
  height: 48px;
  overflow: hidden;
}

/* Estado expandido */
.notes-drawer-mobile.is-expanded {
  height: 85vh;
}

/* Handle para arrastar */
.notes-drawer-handle {
  width: 36px;
  height: 4px;
  background: var(--color-brand-divider);
  border-radius: 2px;
  margin: 8px auto;
  cursor: grab;
}
```

### 9.3 Nota inline em /anotacoes

```css
.nota-inline {
  padding: 12px 16px;
  border-radius: 8px;
  background: var(--color-brand-card);
  border: 1px solid var(--color-brand-divider);
  cursor: pointer;
  transition: all 0.15s;
}

.nota-inline:hover {
  border-color: var(--color-brand-accent);
}

.nota-inline.is-expanded {
  border-color: var(--color-brand-accent);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.nota-inline-content {
  font-size: 14px;
  line-height: 1.5;
  color: var(--color-brand-deep);
  white-space: pre-wrap;
}

.nota-inline-preview {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.nota-inline-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 8px;
  font-size: 12px;
  color: var(--color-brand-deep);
  opacity: 0.5;
}
```

---

## 10. Roadmap de Implementação

| Fase | O que | Tempo est. | Dependências |
|------|-------|------------|--------------|
| **1** | Migração: `UNIQUE(user_id, saved_item_id)` + index conteúdo | 0.5h | — |
| **2** | Server actions: `upsertNote`, `getAllNotes`, `getNotesCount`, `deleteNoteById` | 2h | Fase 1 |
| **3** | NotesDrawer: bottom sheet mobile + sidebar desktop + drag + auto-save | 4h | Fase 2 |
| **4** | SaveButton: adicionar botão "Notas" + indicador | 1h | Fase 3 |
| **5** | Integrar NotesDrawer em 5 páginas | 2h | Fase 3, 4 |
| **6** | Página `/anotacoes`: layout + filtros + pesquisa + inline edit | 3h | Fase 2 |
| **7** | Header: atualizar menu do utilizador | 0.5h | — |
| **8** | i18n + loading skeletons + dark mode + polish | 1.5h | Todas |
| **Total** | | **~15h** | |

---

## 11. Ficheiros Afetados

| Ficheiro | Ação |
|----------|------|
| `supabase/migrations/XXX_notes_unique_constraint.sql` | Novo |
| `lib/actions/saved.js` | Modificar (adicionar 5 funções) |
| `components/ui/NotesDrawer.jsx` | Novo |
| `components/ui/SaveButton.jsx` | Modificar (adicionar botão Notas) |
| `components/pages/NotasPageClient.jsx` | Novo |
| `app/[lang]/(public)/anotacoes/page.js` | Novo |
| `app/[lang]/(public)/anotacoes/loading.jsx` | Novo |
| `app/[lang]/(public)/medicamento/[slug]/medicamentoDetailClient.jsx` | Modificar |
| `app/[lang]/(public)/alvos/[slug]/alvoDetailClient.jsx` | Modificar |
| `app/[lang]/(public)/classes/[slug]/classDetailClient.jsx` | Modificar |
| `app/[lang]/(public)/artigos/[slug]/page.js` | Modificar |
| `app/[lang]/(public)/interacoes/interacoesPageClient.jsx` | Modificar |
| `components/layout/Header.jsx` | Modificar (menu utilizador) |
| `public/i18n/pt.json` | Modificar |
| `public/i18n/en.json` | Modificar |
| `styles/globals.css` | Modificar (estilos novos) |
| `app/sitemap.js` | Modificar |

---

## 12. Fora de âmbito (v1)

- **Export de notas** (PDF/CSV)
- **Partilha de notas** entre utilizadores
- **Tags/categorias** de notas
- **Markdown support** nas notas
- **Notas de voz** (audio-to-text)
- **Backup/sync** entre dispositivos

---

## 13. Verificação

- [ ] Botão "Notas" aparece ao lado de "Guardar" em todas as 5 páginas
- [ ] Desktop: sidebar abre à direita com drag gesture
- [ ] Mobile: bottom sheet sobe/desce com drag
- [ ] Estado inicial sempre encolhido
- [ ] Auto-save funciona (debounce 1.5s)
- [ ] Nota contínua por item (upsert)
- [ ] `/anotacoes` mostra todas as notas com filtros
- [ ] Pesquisa por nome + conteúdo funciona
- [ ] Edição inline funciona
- [ ] Eliminar com confirmação funciona
- [ ] Link "Ver em [página]" navega corretamente
- [ ] Menu do utilizador mostra "Anotações" + "Guardados"
- [ ] Dark mode funciona em todos os componentes
- [ ] i18n PT/EN em todas as chaves
- [ ] Auth: utilizador não logado é redirecionado
