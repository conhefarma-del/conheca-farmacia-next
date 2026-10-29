# Relatório: Página de Anotações (/anotacoes)

> **Data:** 2026-08-20
> **Estado:** 🟡 Análise — aguarda decisão do utilizador

---

## 1. Estado Atual do Sistema de Notas

### 1.1 Schema (Tabela `saved_item_notes`)

```sql
CREATE TABLE public.saved_item_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  saved_item_id UUID NOT NULL REFERENCES public.saved_items(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) > 0 AND char_length(content) <= 2000),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

**Características:**
- Notas estão **sempre associadas a um item guardado** (`saved_item_id` FK → `saved_items`)
- Não existem "notas soltas" — toda anotação pertence a um item
- Limite de 2000 caracteres por nota
- RLS: utilizador só vê/edita as suas próprias notas

### 1.2 Server Actions Existentes (`lib/actions/saved.js`)

| Função | Descrição | Restrição |
|--------|-----------|-----------|
| `addNote(savedItemId, content)` | Adiciona nota a um item guardado | Requer `savedItemId` válido + item pertence ao user |
| `updateNote(noteId, content)` | Edita nota existente | Requer `noteId` + user_id |
| `deleteNote(noteId)` | Elimina nota | Requer `noteId` + user_id |
| `getNotes(savedItemId)` | Lista notas de um item | Filtra por `saved_item_id` + `user_id` |

**Problema:** Não existe `getAllNotes()` — não há forma de obter todas as notas de um utilizador de uma vez.

### 1.3 Acesso Atual às Notas

| Local | Como acede | Funcionalidade |
|-------|------------|----------------|
| `/guardados` | Clica no botão "Anotações" ao lado de cada item | Vê notas desse item + adiciona/edita/elimina |
| `/medicamento/[slug]` | ❌ Não tem acesso | Apenas SaveButton (guardar/remover) |
| `/alvos/[slug]` | ❌ Não tem acesso | Apenas SaveButton |
| `/classes/[slug]` | ❌ Não tem acesso | Apenas SaveButton |
| `/artigos/[slug]` | ❌ Não tem acesso | Apenas SaveButton |
| `/interacoes` | ❌ Não tem acesso | Apenas SaveButton |
| `/perfil` | ❌ Não tem acesso | Mostra preview de guardados (sem notas) |

---

## 2. Problemas Identificados

### 2.1 Não existem "notas soltas"
O schema atual **obriga** toda anotação a estar associada a um item guardado. Isto significa:
- Utilizador não pode criar uma nota "Estudar cap. 5" sem guardar um item primero
- Não pode fazer brainstorming ou apontamentos gerais
- Fluxo: guardar item → criar nota (2 passos obrigatórios)

### 2.2 Sem visão global de todas as notas
O utilizador só consegue ver notas **item por item** (abrir cada item em `/guardados`). Não há:
- Lista de todas as notas
- Pesquisa por conteúdo nas notas
- Filtros por tipo de item
- Ordenação por data de criação/edição

### 2.3 Sem acesso às notas a partir dos itens
Nas páginas de detalhe (medicamento, alvos, classes, artigos, interações):
- Existe `SaveButton` para guardar o item
- **Não** existe forma de ver/adicionar notas diretamente na página do item
- Utilizador é obrigado a ir a `/guardados` para gerir notas

---

## 3. Proposta: Página `/anotacoes`

### 3.1 Conceito

Página dedicada onde o utilizador pode:
1. **Ver todas as suas notas** numa lista cronológica
2. **Criar notas soltas** (sem associação a item)
3. **Ver notas associadas a itens** com link direto para o item
4. **Pesquisar** por conteúdo nas notas
5. **Filtrar** por tipo de nota (soltas vs. associadas a itens)
6. **Criar/editar/eliminar** notas diretamente na página

### 3.2 Layout Proposto

```
┌─────────────────────────────────────────────────────────────────┐
│ 📝 ANOTAÇÕES                                                     │
│ 32 anotações • 8 soltas • 24 em itens guardados                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Pesquisar anotações...                          [Nova +]     │
│                                                                 │
│ [Todas (32)] [Soltas (8)] [Medicamentos (12)] [Interações (5)] │
│ [Classes (3)] [Alvos (2)] [Artigos (2)]                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📝 Nova Anotação                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Escreve a tua anotação aqui...                              │ │
│ │                                                             │ │
│ │                          [Guarda como solta] [Guarda a um item]│ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📌 Anotações Soltas (8)                                         │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ "Estudar cap. 5 — metabolismo hepático"                    │ │
│ │ 20 ago 14:30                                    ✏️ 🗑️       │ │
│ └─────────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ "Revisar antes do exame: warfarina + AINE"                  │ │
│ │ 19 ago 09:15                                    ✏️ 🗑️       │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 💊 Anotações em Medicamentos (12)                               │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 💊 Metformina → "Tomar com alimento, evitar em TFG <45"     │ │
│ │ 18 ago 11:20                                    ✏️ 🗑️       │ │
│ └─────────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 💊 Warfarina → "Monitorizar INR semanalmente"               │ │
│ │ 17 ago 16:45                                    ✏️ 🗑️       │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🔗 Anotações em Interações (5)                                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 🔗 Metformina + AINE → "Risco acidose láctica"             │ │
│ │ 16 ago 10:30                                    ✏️ 🗑️       │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Possibilidades de Ver Notas a partir de Itens

### 4.1 Opção A: Badge no SaveButton (recomendada)

**Concepto:** O `SaveButton` mostra um badge com o número de notas quando o item está guardado + tem notas.

```
┌──────────────────┐
│ 📌 Guardado (3)  │  ← Badge com contagem de notas
└──────────────────┘
```

**Implementação:**
- `SaveButton` passa a ter prop `notesCount`
- Ao clicar no badge, abre um mini-painel de notas (popup/dropdown)
- Utilizador pode ver e adicionar notas sem sair da página

**Vantagens:**
- Não ocupa espaço extra
- Descoberta natural (já está no SaveButton)
- Funciona em todas as páginas que usam SaveButton

**Desvantagens:**
- Espaço limitado para múltiplas notas
- Precisa de queries adicionais para contar notas

### 4.2 Opção B: Secção "Anotações" no final da página

**Concepto:** Adicionar uma secção "Anotações" no final de cada página de detalhe (medicamento, alvos, etc.)

```
┌─────────────────────────────────────────────────────────────────┐
│ ... resto da página ...                                         │
│                                                                 │
│ 📝 ANOTAÇÕES (3)                                                │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ "Tomar com alimento"                          ✏️ 🗑️        │ │
│ │ "Evitar na gravidez"                          ✏️ 🗑️        │ │
│ │ "Revisar interações"                          ✏️ 🗑️        │ │
│ │                                                             │ │
│ │ [Nova anotação...                            ] [Adicionar]  │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Implementação:**
- Criar componente `ItemNotesSection` reutilizável
- Adicionar ao final de `medicamentoDetailClient`, `alvoDetailClient`, etc.
- Query: `getNotes(savedItemId)` + `isItemSaved()` para saber se mostrar

**Vantagens:**
- Notas sempre visíveis na página do item
- UX familiar (similar a "comentários")
- Pode adicionar notas sem navegar

**Desvantagens:**
- Ocupa espaço na página
- Precisa de verificar se item está guardado (query adicional)
- Páginas longas ficam mais longas

### 4.3 Opção C: Tooltip/Dropdown ao hover do SaveButton

**Concepto:** Ao hover (desktop) ou long-press (mobile) no SaveButton, mostra dropdown com:
- Contagem de notas
- Preview das últimas 3 notas
- Link "Ver todas as notas"

**Vantagens:**
- Não ocupa espaço permanente
- Descoberta natural
- Não interrompe a leitura

**Desvantagens:**
- Não funciona bem em mobile (touch)
- Espaço limitado
- Complexidade de implementação

### 4.4 Opção D: Tab "Anotações" na página do item

**Concepto:** Adicionar tab "Anotações" ao lado de "Visão Geral", "Interações", etc. nas páginas de detalhe.

**Vantagens:**
- Integração natural com navegação existente
- Espaço dedicado para notas

**Desvantagens:**
- Muda a estrutura de navegação existente
- Pode confundir utilizadores
- Notas ficam "escondidas" numa tab

---

## 5. Recomendação

### Para a página `/anotacoes`:
- **Criar página dedicada** com layout limpo
- **Notas soltas** são um feature novo (requer migração: coluna `is_standalone` ou separar tabelas)
- **Filtros por tipo** de item associado
- **Pesquisa por conteúdo** nas notas

### Para acesso a partir dos itens:
- **Opção A (Badge no SaveButton)** + **Opção B (Secção no final)**
- Badge dá visibilidade imediata
- Secção no final permite gestão completa

### Ordem de implementação:
1. Adicionar `getAllNotes()` e `getNotesCount()` ao `lib/actions/saved.js`
2. Criar página `/anotacoes` com filtros e pesquisa
3. Adicionar badge ao SaveButton
4. Adicionar secção "Anotações" ao final das páginas de detalhe

---

## 6. Migração Necessária

### Opção 1: Notas soltas via coluna `is_standalone`
```sql
ALTER TABLE public.saved_item_notes
  ADD COLUMN is_standalone BOOLEAN NOT NULL DEFAULT false;

-- Notas soltas não têm saved_item_id
ALTER TABLE public.saved_item_notes
  ALTER COLUMN saved_item_id DROP NOT NULL;

-- Constraint: ou tem saved_item_id ou é standalone
ALTER TABLE public.saved_item_notes
  ADD CONSTRAINT notes_standalone_check
  CHECK ((saved_item_id IS NOT NULL) OR (is_standalone = true));
```

### Opção 2: Tabela separada `standalone_notes`
```sql
CREATE TABLE public.standalone_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) > 0 AND char_length(content) <= 2000),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

**Recomendação:** Opção 1 (coluna `is_standalone`) — mais simples, mantém tudo numa tabela.

---

## 7. Server Actions Adicionais Necessárias

| Função | Descrição |
|--------|-----------|
| `getAllNotes({ search?, type?, page?, limit? })` | Lista todas as notas do utilizador com filtros |
| `getNotesCount()` | Conta notas por tipo (soltas + por tipo de item) |
| `addStandaloneNote(content)` | Cria nota solta (sem item associado) |
| `searchNotes(query)` | Pesquisa por conteúdo nas notas |

---

## 8. i18n Keys Necessárias

### PT
```json
{
  "notes_page": {
    "title": "Anotações",
    "subtitle": "{n} anotações • {s} soltas • {a} em itens guardados",
    "search_placeholder": "Pesquisar anotações...",
    "new_note": "Nova Anotação",
    "new_standalone": "Guarda como solta",
    "new_associated": "Guarda a um item",
    "standalone_title": "Anotações Soltas",
    "associated_title": "Anotações em {type}",
    "empty": "Ainda não tens anotações",
    "empty_hint": "Cria a tua primeira anotação acima",
    "tabs": {
      "all": "Todas",
      "standalone": "Soltas",
      "drug": "Medicamentos",
      "interaction": "Interações",
      "drug_class": "Classes",
      "molecular_target": "Alvos",
      "article": "Artigos"
    }
  }
}
```

### EN
```json
{
  "notes_page": {
    "title": "Notes",
    "subtitle": "{n} notes • {s} standalone • {a} in saved items",
    "search_placeholder": "Search notes...",
    "new_note": "New Note",
    "new_standalone": "Save as standalone",
    "new_associated": "Save to an item",
    "standalone_title": "Standalone Notes",
    "associated_title": "Notes in {type}",
    "empty": "You don't have any notes yet",
    "empty_hint": "Create your first note above",
    "tabs": {
      "all": "All",
      "standalone": "Standalone",
      "drug": "Medications",
      "interaction": "Interactions",
      "drug_class": "Classes",
      "molecular_target": "Targets",
      "article": "Articles"
    }
  }
}
```

---

## 9. Roadmap de Implementação

| Fase | O que | Tempo est. | Dependências |
|------|-------|------------|--------------|
| **1** | Migração: `is_standalone` + `saved_item_id` nullable | 0.5h | — |
| **2** | Server actions: `getAllNotes`, `getNotesCount`, `addStandaloneNote`, `searchNotes` | 2h | Fase 1 |
| **3** | Página `/anotacoes` (layout + filtros + pesquisa + lista) | 3h | Fase 2 |
| **4** | Badge no SaveButton (contagem + dropdown) | 1.5h | Fase 2 |
| **5** | Secção "Anotações" no final das páginas de detalhe | 2h | Fase 2 |
| **6** | i18n + loading skeletons + polish | 1h | Todas |
| **Total** | | **~10h** | |

---

## 10. Ficheiros Afetados

| Ficheiro | Ação |
|----------|------|
| `supabase/migrations/XXX_notes_standalone.sql` | Novo (migração) |
| `lib/actions/saved.js` | Modificar (adicionar 4 funções) |
| `app/[lang]/(public)/anotacoes/page.js` | Novo |
| `app/[lang]/(public)/anotacoes/NotasPageClient.jsx` | Novo |
| `components/ui/SaveButton.jsx` | Modificar (adicionar badge + dropdown) |
| `components/pages/ItemNotesSection.jsx` | Novo (componente reutilizável) |
| `app/[lang]/(public)/medicamento/[slug]/medicamentoDetailClient.jsx` | Modificar (adicionar secção) |
| `app/[lang]/(public)/alvos/[slug]/alvoDetailClient.jsx` | Modificar (adicionar secção) |
| `app/[lang]/(public)/classes/[slug]/classDetailClient.jsx` | Modificar (adicionar secção) |
| `app/[lang]/(public)/artigos/[slug]/page.js` | Modificar (adicionar secção) |
| `app/[lang]/(public)/interacoes/interacoesPageClient.jsx` | Modificar (adicionar secção) |
| `public/i18n/pt.json` | Modificar (adicionar chaves) |
| `public/i18n/en.json` | Modificar (adicionar chaves) |
| `styles/globals.css` | Modificar (estilos novos) |
| Menu principal / Header | Modificar (adicionar item "Anotações") |
| `app/sitemap.js` | Modificar (adicionar `/anotacoes`) |

---

## 11. Perguntas para Decidir

| # | Pergunta | Opções |
|---|----------|--------|
| 1 | Notas soltas são necessárias? | A) Sim (migração `is_standalone`) / B) Não (manter tudo associado a itens) |
| 2 | Onde aceder às notas a partir dos itens? | A) Badge no SaveButton / B) Secção no final / C) Ambas / D) Nenhuma (só em /anotacoes) |
| 3 | A página `/anotacoes` substitui a secção de notas em `/guardados`? | A) Sim (notas só em /anotacoes) / B) Não (ambas coexistem) |
| 4 | Notas soltas têm limite de 2000 chars como as associadas? | A) Sim / B) Não (maior, ex: 5000) |
| 5 | Pesquisa nas notas é full-text ou só por conteúdo? | A) Full-text (PostgreSQL tsvector) / B) Simples (ILIKE) |
