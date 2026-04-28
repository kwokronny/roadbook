# Design Spec: Luggage Screen HTML Mockup

**Date:** 2026-04-11
**Scope:** Add luggage checklist mockups to `packages/design-system/all-screens.html`
**Based on:** Existing Flutter implementation in `packages/roadbook-flutter/lib/features/luggage/`

---

## Overview

Add 3 phone frames to the all-screens.html mockup representing the luggage checklist feature. All frames follow the Frosted Warmth design system and mirror the existing Flutter implementation.

## Frames

### Frame 1: Luggage Screen (Main)

**Layout (top to bottom):**

1. **AppBar** — dark circle back button `‹`, title "行李清单" (18px w500), right-aligned coral text "导入模板" (14px)
2. **Progress section** — "3 / 12 已打包" caption text + 6px tall progress bar (coral fill on neutral track, ~25% filled)
3. **Category cards** — glass cards (`.g`) stacked vertically, 20px horizontal margin, 4px vertical gap:
   - **证件** (expanded) — header: `📋 证件` + `2/4` counter + expand arrow `▾`. Divider. 4 item rows with circular checkboxes (2 checked coral, 2 unchecked). "＋ 添加物品" row in coral.
   - **衣物** (expanded) — header: `📦 衣物` + `1/3` + `▾`. 3 items (1 checked). Add row.
   - **电子** (collapsed) — header only: `📦 电子` + `0/3` + `▸` (arrow rotated -90deg)
4. **Add category button** — ghost pill button centered: `＋ 添加分类`, 44px height, 1px border `rgba(28,28,30,0.12)`

**No dock** — this is a pushed page from Travel Detail.

**Item row spec (44px height):**
- Checkbox: 22px circle. Unchecked: transparent bg, 1.5px border `rgba(28,28,30,0.12)`. Checked: coral bg, white checkmark.
- Text: 15px. Checked items get `text-decoration: line-through` + ink2 color.

### Frame 2: Template Sheet

**Overlays on dimmed background.** Frosted glass bottom sheet (`.gs`).

1. **Drag handle** — 36x4px, centered
2. **Title** — "选择出行季节" (17px w500)
3. **Subtitle** — "点击即导入对应季节的打包建议" (12px caption)
4. **2x2 grid** — 4 season cards:
   - `🌸 春季 / 3–5月`
   - `☀️ 夏季 / 6–8月`
   - `🍂 秋季 / 9–11月`
   - `❄️ 冬季 / 12–2月`
   - Each card: canvas bg, content-card radius (12px), 1px border, emoji + label + months

### Frame 3: Add Item Sheet

**80% height frosted sheet** overlaying dimmed background.

1. **Drag handle**
2. **Title bar** — "添加物品" (17px w500) left, "已选 3" (14px coral) right
3. **Search bar** — pill shape, "🔍 搜索或输入物品名…" placeholder
4. **Divider**
5. **Preset list** (scrollable area):
   - Group header "证件常用" (12px caption w500)
   - Selectable rows with circular checkboxes:
     - `护照` — grayed out (already exists): bg circle, ink3 text, 1.5px ink3 border
     - `机票打印件` — unselected: empty circle
     - `旅行保险单` — selected: coral circle + checkmark
     - `驾照` — unselected
   - Group header "通用常用"
   - `充电宝` — selected
   - `雨伞` — selected
   - `耳机` — unselected
   - `⊕ 输入自定义物品…` (coral icon + text)
6. **Bottom CTA** — coral button full-width: "添加 3 项到「证件」→"

## Placement

Insert after the existing Collect Import sheet section (line ~789) and before the Sign In section, under a new row label "Luggage".

## CSS

Reuse all existing CSS classes (`.g`, `.gs`, `.bar`, `.dark-c`, `.handle`, `.sh-head`, `.sh-title`, `.cta`, etc.). Add minimal inline styles only for luggage-specific elements (checkbox circles, progress bar, category headers).
