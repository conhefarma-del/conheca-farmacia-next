# Header Hide on Drawer Open — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hide the sticky header with a smooth slide-up animation when the mobile drawer opens, and restore it when the drawer closes.

**Architecture:** Replace the current `translateX(-20%)` push effect on `.header` with `translateY(-100%)` to slide the header up and out of view. Add a CSS transition matching the drawer's 0.4s timing. Remove the horizontal push on the header only — the `<main>` element keeps its push animation.

**Tech Stack:** Vanilla JS, Tailwind CSS v4 (raw CSS `var()`), Vite

---

## Context

When the floating drawer opens on mobile, `body.drawer-open .header` applies `transform: translateX(-20%)`. The header has `z-index: 50` (from `@apply z-50`), which is higher than the drawer's `z-index: 45`. This causes the header to appear on top of the drawer even though it shifts left. The user wants the header to slide up and disappear when the drawer opens.

## Files Modified

| File | Responsibility |
|------|---------------|
| `src/input.css` | Change header transform from push-left to slide-up; add transition |

Only one file needs changes — this is a pure CSS fix.

---

### Task 1: Replace header push with slide-up animation

**Files:**
- Modify: `src/input.css:583-591`

Current code (lines 583–591):

```css
body.drawer-open main,

body.drawer-open .header {

transform: translateX(-20%);

transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1);

}
```

- [ ] **Step 1: Update the CSS rule**

Change `body.drawer-open .header` from `translateX(-20%)` to `translateY(-100%)`, keeping the same transition timing. The `main` element keeps its horizontal push. Replace the block with:

```css
body.drawer-open main {

transform: translateX(-20%);

transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1);

}

body.drawer-open .header {

transform: translateY(-100%);

transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1);

}
```

- [ ] **Step 2: Add a default transition on `.header` so it animates on close too**

The `.header` class currently has no transition property. Without it, closing the drawer would snap the header back instantly. Add a transition rule right after the existing `.header` block (after line 112):

```css
.header {
  transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1);
}
```

This can be added as a separate rule or merged into the existing `@apply` block. Since the existing `.header` uses `@apply`, add the transition as a separate declaration block right after it:

```css
.header {
  @apply sticky top-0 z-50 bg-brand-bg shadow-sm;
}

.header {
  transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1);
}
```

- [ ] **Step 3: Run the build**

Run: `npm run build`

Expected: Build succeeds with no errors.

- [ ] **Step 4: Visual test on mobile**

Run: `npm run dev`

1. Open browser at `http://localhost:5173`
2. Resize to mobile width (<768px) or use DevTools mobile emulation
3. Click the hamburger button
4. **Expected:** Header slides up and disappears smoothly; drawer opens from the right; main content shifts left
5. Click the close button or overlay
6. **Expected:** Header slides back down into view; drawer closes; main content shifts back

- [ ] **Step 5: Commit**

```bash
git add src/input.css
git commit -m "fix: header slides up when mobile drawer opens instead of overlapping"
```
