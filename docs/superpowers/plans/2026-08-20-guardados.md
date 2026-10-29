# Sistema de Guardados (Bookmarks + Anotações)

> **Data:** 2026-08-20
> **Estado:** 🟡 Aprovado — aguarda implementação
> **Dependências:** Nenhuma (feature independente)
> **Complexidade estimada:** ~14h (8 fases)

---

## 1. Visão Geral

O utilizador pode guardar conteúdos do site (medicamentos, interações, classes, alvos, artigos) e adicionar anotações pessoais a cada item guardado. A secção "Ferramentas" no perfil é substituída por "Guardados" com tabs por tipo e pesquisa.

---

## 2. Decisões de Produto

| Decisão | Escolha |
|---------|---------|
| **Conteúdo guardável** | Medicamentos, Interações, Classes, Alvos, Artigos (5 tipos) |
| **Botão guardar** | Em cada página de conteúdo + secção no perfil |
| **Organização no perfil** | Tabs por tipo + barra de pesquisa |
| **Anotações** | Múltiplas por item, com timestamp |
| **Sem conta** | Redirect para `/entrar` → volta à página após login |

---

## 3. Schema (Migração SQL)

### 3.1 Tabela `saved_items`

```sql
CREATE TABLE public.saved_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL CHECK (item_type IN ('drug', 'interaction', 'drug_class', 'molecular_target', 'article')),
  item_id UUID NOT NULL,           -- FK para a tabela correspondente
  item_slug TEXT NOT NULL,         -- slug para link rápido
  item_name TEXT NOT NULL,         -- nome display (denormalized para performance)
  item_subtitle TEXT,              -- ex: classe do medicamento, tipo de interação
  item_image_url TEXT,             -- thumbnail se disponível
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, item_type, item_id)
);

CREATE INDEX idx_saved_items_user ON public.saved_items(user_id);
CREATE INDEX idx_saved_items_type ON public.saved_items(user_id, item_type);
```

### 3.2 Tabela `saved_item_notes`

```sql
CREATE TABLE public.saved_item_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  saved_item_id UUID NOT NULL REFERENCES public.saved_items(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) > 0 AND char_length(content) <= 2000),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_saved_notes_item ON public.saved_item_notes(saved_item_id);
```

### 3.3 RLS Policies

```sql
-- saved_items
ALTER TABLE public.saved_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own saved items"
  ON public.saved_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own saved items"
  ON public.saved_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users delete own saved items"
  ON public.saved_items FOR DELETE
  USING (auth.uid() = user_id);

-- saved_item_notes
ALTER TABLE public.saved_item_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own notes"
  ON public.saved_item_notes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own notes"
  ON public.saved_item_notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own notes"
  ON public.saved_item_notes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users delete own notes"
  ON public.saved_item_notes FOR DELETE
  USING (auth.uid() = user_id);
```

---

## 4. Server Actions (`lib/actions/saved.js`)

| Função | Descrição |
|--------|-----------|
| `toggleSaveItem(type, id, slug, name, subtitle, imageUrl)` | Guardar/remover item (toggle). Retorna `{ saved: boolean, count: number }` |
| `isItemSaved(type, id)` | Verificar se item está guardado (para estado do botão) |
| `getSavedItems(type?, search?, page?, limit?)` | Listar guardados com filtro por tipo e pesquisa. Retorna paginado |
| `getSavedCounts()` | Contar guardados por tipo (para badges nas tabs) |
| `addNote(savedItemId, content)` | Adicionar anotação |
| `updateNote(noteId, content)` | Editar anotação |
| `deleteNote(noteId)` | Eliminar anotação |
| `getNotes(savedItemId)` | Buscar anotações de um item guardado |

### 4.1 Lógica de `toggleSaveItem`

```
1. Verificar auth.uid() — se não autenticado, throw com código 'auth_required'
2. Verificar se já existe (user_id, item_type, item_id)
3. Se existe → DELETE → retorna { saved: false }
4. Se não existe → INSERT → retorna { saved: true }
5. Em ambos os casos, retornar count atualizado
```

---

## 5. Componentes

### 5.1 `components/ui/SaveButton.jsx` (Client)

Botão de bookmark que aparece em cada página de conteúdo.

```
Props: { itemType, itemId, itemSlug, itemName, itemSubtitle, itemImageUrl, size? }

Estados:
- não logado → click → redirect /entrar
- logado + não guardado → ícone bookmark outline → click → toggleSave
- logado + guardado → ícone bookmark filled (verde) → click → toggleSave
- loading → spinner pequeno

Variantes de tamanho:
- size="sm" (16px) — inline no conteúdo
- size="md" (20px) — padrão
- size="lg" (24px) — hero/destaque
```

### 5.2 `components/pages/SavedPageClient.jsx` (Client)

Substitui a secção "Ferramentas" no perfil. Nova página dedicada `/guardados`.

```
Layout:
┌──────────────────────────────────────┐
│ 📌 Guardados              🔍 [pesq] │
│                                      │
│ [Medicamentos (12)] [Interações (5)] │
│ [Classes (3)] [Alvos (8)] [Artigos]  │
│                                      │
│ ┌─────────────────────────────────┐  │
│ │ 💊 Ibuprofeno                  │  │
│ │ AINE · Analgésicos             │  │
│ │ 📝 2 anotações                 │  │
│ │                    [🗑️] [↗️]   │  │
│ └─────────────────────────────────┘  │
│ ┌─────────────────────────────────┐  │
│ │ 💊 Paracetamol                 │  │
│ │ Analgésico · Antipirético      │  │
│ │ 📝 0 anotações                 │  │
│ │                    [🗑️] [↗️]   │  │
│ └─────────────────────────────────┘  │
│                                      │
│ ← 1 2 3 →                           │
└──────────────────────────────────────┘
```

### 5.3 `components/ui/NotesPanel.jsx` (Client)

Painel expansível de anotações para cada item guardado.

```
Props: { savedItemId, notes[], onAdd, onUpdate, onDelete }

Layout:
┌─────────────────────────────────┐
│ 📝 Anotações               [+] │
├─────────────────────────────────┤
│ "Tomar com alimento"      ✏️ 🗑️ │
│ 20 ago 14:30                     │
├─────────────────────────────────┤
│ "Evitar na gravidez"      ✏️ 🗑️ │
│ 19 ago 09:15                     │
├─────────────────────────────────┤
│ [Nova anotação...         ] [✓] │
└─────────────────────────────────┘
```

---

## 6. Rotas

| Rota | Tipo | Descrição |
|------|------|-----------|
| `/{lang}/guardados` | Nova | Página dedicada de guardados com tabs + pesquisa |
| `/{lang}/perfil` | Modificada | Secção "Ferramentas" → "Guardados" (atalho para /guardados) |

### 6.1 Perfil — Nova secção "Guardados"

A secção "Ferramentas" é substituída por um card que mostra:
- Contagem total de guardados
- Preview dos 4 últimos guardados (ícone + nome)
- Link "Ver todos" → `/guardados`

```
┌──────────────────────────────┐
│ 📌 Guardados           28    │
│                              │
│ 💊 Ibuprofeno    💊 Para... │
│ 🔗 Ibupro+Ome... 🎯 CYP2C9 │
│                              │
│              [Ver todos →]   │
└──────────────────────────────┘
```

---

## 7. i18n Keys

### PT (`public/i18n/pt.json`)

```json
{
  "saved": {
    "title": "Guardados",
    "empty": "Ainda não guardaste nada",
    "empty_hint": "Guarda medicamentos, interações e mais para consultar rapidamente",
    "tabs": {
      "all": "Todos",
      "drug": "Medicamentos",
      "interaction": "Interações",
      "drug_class": "Classes",
      "molecular_target": "Alvos",
      "article": "Artigos"
    },
    "search_placeholder": "Pesquisar guardados...",
    "notes": {
      "title": "Anotações",
      "add_placeholder": "Nova anotação...",
      "empty": "Sem anotações",
      "add": "Adicionar",
      "edit": "Editar",
      "delete": "Eliminar",
      "max_length": "Máximo 2000 caracteres"
    },
    "save": "Guardar",
    "unsave": "Remover",
    "saved_at": "Guardado em",
    "confirm_delete": "Remover dos guardados?",
    "login_required": "Precisas de conta para guardar",
    "error": "Erro ao guardar. Tenta novamente.",
    "count_zero": "Sem guardados",
    "count_one": "{n} guardado",
    "count_other": "{n} guardados"
  }
}
```

### EN (`public/i18n/en.json`)

```json
{
  "saved": {
    "title": "Saved",
    "empty": "Nothing saved yet",
    "empty_hint": "Save drugs, interactions and more for quick access",
    "tabs": {
      "all": "All",
      "drug": "Medications",
      "interaction": "Interactions",
      "drug_class": "Classes",
      "molecular_target": "Targets",
      "article": "Articles"
    },
    "search_placeholder": "Search saved items...",
    "notes": {
      "title": "Notes",
      "add_placeholder": "New note...",
      "empty": "No notes yet",
      "add": "Add",
      "edit": "Edit",
      "delete": "Delete",
      "max_length": "Maximum 2000 characters"
    },
    "save": "Save",
    "unsave": "Remove",
    "saved_at": "Saved on",
    "confirm_delete": "Remove from saved?",
    "login_required": "You need an account to save items",
    "error": "Error saving. Try again.",
    "count_zero": "No saved items",
    "count_one": "{n} saved",
    "count_other": "{n} saved"
  }
}
```

---

## 8. Roadmap

| # | Fase | Descrição | Tempo |
|---|------|-----------|-------|
| 1 | Migração SQL | `saved_items` + `saved_item_notes` + RLS | 0.5h |
| 2 | Server Actions | 8 funções em `lib/actions/saved.js` | 2h |
| 3 | SaveButton | Componente reutilizável com estados | 1.5h |
| 4 | Integrar SaveButton | Adicionar a 5 páginas (medicamento, interação, classe, alvo, artigo) | 2h |
| 5 | Página /guardados | Tabs + pesquisa + lista + paginação | 3h |
| 6 | NotesPanel | Anotações com CRUD inline | 2h |
| 7 | Perfil update | Substituir Ferramentas por preview de Guardados | 1h |
| 8 | i18n + commit | Chaves PT/EN + code review | 1h |
| **Total** | | | **~13h** |

---

## 9. Integração por Página

| Página | Local do SaveButton | item_type | item_id |
|--------|-------------------|-----------|---------|
| `/medicamentos/[slug]` | Hero, ao lado do nome | `drug` | `drugs.id` |
| `/interacoes` (resultado) | Ao lado do par | `interaction` | `drug_interactions.id` |
| `/classes/[slug]` | Hero, ao lado do nome | `drug_class` | `drug_classes.id` |
| `/alvos/[slug]` | Hero, ao lado do nome | `molecular_target` | `molecular_targets.id` |
| `/artigos/[slug]` | Header do artigo | `article` | `articles.id` |

---

## 10. Segurança

- **RLS**: Todas as operações filtradas por `auth.uid() = user_id`
- **Rate limit**: Máximo 200 guardados por utilizador (impedido no server action)
- **Input validation**: `item_content` sanitizado com `escapeHtml()`
- **Auth check**: Todas as server actions verificam `auth.uid()` — sem autenticação → erro semântico `auth_required`
- **No PII**: Anotações são conteúdo do utilizador, não são logadas
