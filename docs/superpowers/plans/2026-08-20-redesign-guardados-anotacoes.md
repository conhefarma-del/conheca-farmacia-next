# Plano: Redesign /guardados e /anotacoes

**Data:** 2026-08-20
**Estado:** Perguntas respondidas, pronto para implementar

---

## Decisões do Utilizador

| # | Pergunta | Resposta |
|---|----------|----------|
| **1** | Layout dos cards | Grid em desktop, lista em mobile |
| **2** | Conteúdo do card | Ícone + nome + subtitulo + data de guarda/nota |
| **3** | Preview da nota | Sim, colapsável (2-3 linhas) |
| **4** | Ação ao clicar no card | Nome → navega; Ícone notas → abre drawer |
| **5** | Tipo de drawer | Igual às outras páginas (sidebar desktop, bottom sheet mobile) |
| **6** | Eliminar | Botão no drawer |
| **7** | Botão guardar/unsave no card | Não (só no drawer) |
| **8** | Link para página do item | Sim, ao clicar no card |
| **9** | Notas soltas | Sim, podem existir |
| **10** | Criar notas soltas | Botão "Criar nota" no topo da página |

---

## Alterações

### 1. Schema — Notas soltas

```sql
-- Tornar saved_item_id nullable para notas soltas
ALTER TABLE saved_item_notes ALTER COLUMN saved_item_id DROP NOT NULL;
```

### 2. Server Actions — Atualizar

- `upsertNote`: aceitar `saved_item_id = null` para notas soltas
- `getAllNotes`: mostrar notas soltas (saved_item_id IS NULL)
- `getNotesCount`: incluir notas soltas
- `upsertStandaloneNote`: criar nota sem item associado
- `deleteNoteById`: funcionar para notas soltas também

### 3. /guardados — Redesign

**Cards:**
- Desktop: grid 2-3 colunas
- Mobile: lista vertical
- Conteúdo: ícone + nome + subtítulo + data + preview nota colapsável

**Drawer:**
- Ao clicar no ícone de notas → abre NotesDrawer
- Drawer: sidebar desktop, bottom sheet mobile

**Ações:**
- Clicar no nome → navega para o item
- Clicar no ícone notas → abre drawer
- Eliminar: via drawer

### 4. /anotacoes — Redesign

**Cards:**
- Desktop: grid 2-3 colunas
- Mobile: lista vertical
- Conteúdo: ícone + nome + subtítulo + data + preview nota colapsável

**Botão "Criar nota":**
- No topo da página
- Abre modal/drawer para criar nota solta
- Nota solta: sem item associado

**Drawer:**
- Ao clicar no card → abre NotesDrawer
- Drawer: sidebar desktop, bottom sheet mobile

**Filtros:**
- Tabs: Todas | Medicamentos | Interações | Classes | Alvos | Artigos | Soltas

### 5. NotesDrawer — Atualizar

- Aceitar `saved_item_id = null` para notas soltas
- Mostrar "Nota solta" no título quando não tem item

---

## Ordem de Implementação

```
1. Migração: tornar saved_item_id nullable
2. Server actions: upsertNote + getAllNotes + getNotesCount + upsertStandaloneNote
3. /guardados: redesign cards + grid + drawer
4. /anotacoes: redesign cards + grid + drawer + criar nota solta
5. i18n: novas chaves PT/EN
6. CSS: estilos dos cards grid + preview
```

---

## CSS Referência

```css
/* Cards grid (desktop) */
.saved-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

/* Cards mobile (lista) */
@media (max-width: 640px) {
  .saved-grid {
    grid-template-columns: 1fr;
  }
}

/* Card */
.saved-card {
  background: var(--color-brand-card);
  border: 1px solid var(--color-brand-divider);
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: box-shadow 0.15s;
}

.saved-card:hover {
  box-shadow: 0 2px 8px rgba(0, 42, 50, 0.06);
}

/* Preview da nota (colapsável) */
.saved-card-note-preview {
  font-size: 12px;
  color: var(--color-brand-deep);
  opacity: 0.6;
  margin-top: 8px;
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.2s;
}

.saved-card:hover .saved-card-note-preview,
.saved-card.is-expanded .saved-card-note-preview {
  max-height: 60px;
}
```
