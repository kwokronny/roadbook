# Design Spec: roadbook-ui — Frosted Warmth React Component Library

**Date:** 2026-04-12
**Package:** `packages/roadbook-ui`
**Stack:** Vite + React 18 + TypeScript + Tailwind CSS 4 + shadcn/ui + Storybook 8
**Design System:** Frosted Warmth (see `packages/design-system/SPEC.md`)

---

## 1. Goal

Build a reusable React component library that implements the Frosted Warmth design system. Components are customized on top of shadcn/ui where applicable, with custom components for glass surfaces, animations, and business-specific UI. Each component has a Storybook story for interactive preview.

---

## 2. Project Structure

```
packages/roadbook-ui/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.ts        # Frosted Warmth tokens as Tailwind theme
├── components.json            # shadcn/ui config
├── src/
│   ├── tokens/
│   │   └── frost.css          # CSS custom properties (canvas, frost, coral, ink...)
│   ├── components/
│   │   ├── ui/                # shadcn/ui base (themed)
│   │   │   ├── button.tsx
│   │   │   ├── badge.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── sheet.tsx
│   │   │   ├── popover.tsx
│   │   │   └── toast.tsx
│   │   ├── ambient-bg.tsx
│   │   ├── glass-card.tsx
│   │   ├── time-badge.tsx
│   │   ├── icon.tsx
│   │   ├── skeleton.tsx
│   │   ├── pill-toggle.tsx
│   │   ├── day-bar.tsx
│   │   ├── nav-dock.tsx
│   │   ├── nav-button.tsx
│   │   ├── travel-card.tsx
│   │   ├── schedule-card.tsx
│   │   ├── luggage-category.tsx
│   │   ├── search-result-item.tsx
│   │   └── map-info-bar.tsx
│   ├── lib/
│   │   └── utils.ts           # cn(), animation helpers
│   └── index.ts               # public exports
├── stories/
│   ├── foundation/
│   │   ├── Colors.stories.tsx
│   │   ├── Typography.stories.tsx
│   │   └── Icons.stories.tsx
│   ├── base/
│   │   ├── Button.stories.tsx
│   │   ├── Badge.stories.tsx
│   │   ├── GlassCard.stories.tsx
│   │   ├── TimeBadge.stories.tsx
│   │   └── Skeleton.stories.tsx
│   ├── composite/
│   │   ├── PillToggle.stories.tsx
│   │   ├── DayBar.stories.tsx
│   │   ├── NavDock.stories.tsx
│   │   ├── Sheet.stories.tsx
│   │   ├── Dialog.stories.tsx
│   │   └── Popover.stories.tsx
│   └── business/
│       ├── TravelCard.stories.tsx
│       ├── ScheduleCard.stories.tsx
│       ├── LuggageCategory.stories.tsx
│       ├── SearchResultItem.stories.tsx
│       └── MapInfoBar.stories.tsx
└── .storybook/
    ├── main.ts
    └── preview.ts             # load frost.css + ambient bg decorator
```

---

## 3. Design Tokens

### 3.1 CSS Custom Properties (`src/tokens/frost.css`)

```css
:root {
  /* Canvas & Surface */
  --canvas: #F2EDE8;
  --frost: rgba(255,255,255,0.52);
  --frost-strong: rgba(255,255,255,0.72);
  --frost-border: rgba(255,255,255,0.65);

  /* Brand Accent */
  --coral: #FF6B3D;
  --coral-glow: rgba(255,107,61,0.35);
  --coral-tint: rgba(255,107,61,0.10);

  /* Dark Accents */
  --dark: rgba(28,28,30,0.88);
  --dark-hover: rgba(28,28,30,0.75);

  /* Ink (single-hue family) */
  --ink: rgba(28,28,30,0.90);
  --ink-secondary: rgba(28,28,30,0.50);
  --ink-tertiary: rgba(28,28,30,0.28);

  /* Lavender (hotel/accommodation) */
  --lavender: #8C5CF6;
  --lavender-tint: rgba(140,92,246,0.10);
  --lavender-text: #6D3FC0;

  /* Nightsky (hotel card dark bg) */
  --nightsky: rgba(20,30,48,0.88);
  --nightsky-light: rgba(20,30,48,0.65);

  /* Semantic */
  --destructive: #FF3B30;
  --ongoing-bg: rgba(255,107,61,0.10);
  --ongoing-text: #D4410A;
  --upcoming-bg: rgba(224,133,0,0.10);
  --upcoming-text: #B56800;
}
```

### 3.2 Tailwind Config (`tailwind.config.ts`)

Maps CSS variables to Tailwind utility classes:

```ts
export default {
  theme: {
    extend: {
      colors: {
        canvas: 'var(--canvas)',
        frost: { DEFAULT: 'var(--frost)', strong: 'var(--frost-strong)', border: 'var(--frost-border)' },
        coral: { DEFAULT: 'var(--coral)', glow: 'var(--coral-glow)', tint: 'var(--coral-tint)' },
        dark: { DEFAULT: 'var(--dark)', hover: 'var(--dark-hover)' },
        ink: { DEFAULT: 'var(--ink)', secondary: 'var(--ink-secondary)', tertiary: 'var(--ink-tertiary)' },
        lavender: { DEFAULT: 'var(--lavender)', tint: 'var(--lavender-tint)', text: 'var(--lavender-text)' },
        nightsky: { DEFAULT: 'var(--nightsky)', light: 'var(--nightsky-light)' },
        destructive: 'var(--destructive)',
      },
      borderRadius: {
        card: '24px',
        'card-sm': '16px',
        'card-inner': '14px',
        pill: '100px',
        sheet: '24px',
      },
      spacing: {
        'page-h': '20px',
        'card-pad': '16px',
        'dock-inset': '20px',
        touch: '44px',
      },
      fontFamily: {
        sans: ['PingFang SC', 'system-ui', 'sans-serif'],
      },
      transitionTimingFunction: {
        spring: 'cubic-bezier(0.34, 1.3, 0.64, 1)',
        'ease-expo': 'cubic-bezier(0.22, 0.0, 0.36, 1)',
        expressive: 'cubic-bezier(0.22, 1.0, 0.36, 1)',
      },
      keyframes: {
        'shimmer': {
          '0%': { backgroundPosition: '200% 0' },
          '100%': { backgroundPosition: '-200% 0' },
        },
        'drift': {
          '0%, 100%': { transform: 'translate(0,0) scale(1)' },
          '33%': { transform: 'translate(25px,-15px) scale(1.04)' },
          '66%': { transform: 'translate(-15px,12px) scale(0.96)' },
        },
      },
      animation: {
        shimmer: 'shimmer 1.6s ease-in-out infinite',
        drift: 'drift 25s ease-in-out infinite',
      },
    },
  },
}
```

---

## 4. Component Specs

### Phase 1 — Foundation

#### `AmbientBg`
Warm canvas background with 3 drifting radial gradient orbs.
- Props: `className?`
- Renders fixed position container with 3 animated orbs (sand #F5E6C8, honey #F0D898, cream #F5E0B0)
- Uses `animate-drift` with unique delays per orb

#### `GlassCard`
Core surface component. All cards build on this.
- Props: `variant?: 'frost' | 'strong' | 'dark'`, `radius?: 'card' | 'card-sm' | 'card-inner'`, `className?`, `children`
- `frost`: backdrop-blur(40px) saturate(1.4), white 52% bg, white 65% border, specular gradient
- `strong`: blur(50px) saturate(1.8), white 72% bg
- `dark`: nightsky bg, subtle white border 8%
- All include `::after` specular highlight

#### `Button`
Extends shadcn/ui Button with Frosted Warmth variants.
- Variants: `dark-pill`, `coral`, `glass`, `ghost`, `dark-circle`, `coral-circle`
- Press animation: `scale(0.92)` spring bounce on release
- `dark-pill`: rgba(28,28,30,0.88) bg, white text, pill shape, → arrow
- `coral`: #FF6B3D bg, white text, pill shape
- `coral-circle`: 36px circle, coral bg, white icon
- `dark-circle`: 36px circle, dark bg, white icon

#### `Badge`
Extends shadcn/ui Badge.
- Variants: `ongoing`, `upcoming`, `planning`, `ended`, `city`, `hotel`
- Pill shape (radius 100px)
- City tags: unified dark style (rgba(28,28,30,0.05) bg)

#### `TimeBadge`
Schedule time display pill.
- Props: `time: string`, `variant: 'poi' | 'hotel' | 'unplanned'`, `editable?: boolean`
- `poi`: coral tint bg, 12px, compact
- `hotel`: lavender bg, 15px, larger padding, shows "入住/退房" prefix
- `unplanned`: neutral bg, "待规划" text
- When `editable`: shows small calendar edit icon

#### `Icon`
SVG icon system wrapper.
- Props: `name: string`, `size?: number` (default 24), `className?`
- All icons: 24x24 viewBox, stroke-width 1.8, round cap/join
- Icons: back, plus, close, more-h, more-v, search, chevron-r, chevron-d, map, user, navigate, pin, clock, calendar, list, map-view, timeline, edit, copy, trash, upload, image, camera, link, check, users, settings, key, message, moon, globe, folder, info, luggage, check-circle, circle

#### `Skeleton`
Warm-toned shimmer skeleton.
- Props: `variant?: 'text' | 'avatar' | 'image' | 'tag'`, `className?`
- Base: rgba(28,28,30,0.04), shimmer highlight rgba(255,255,255,0.50)
- 120deg gradient angle, 1.6s animation, stagger support via CSS custom property `--stagger`

### Phase 2 — Composite

#### `PillToggle`
Glass segmented control with sliding dark pill indicator.
- Props: `segments: {label: string, icon?: ReactNode}[]`, `value: number`, `onChange: (i: number) => void`
- Glass track with blur(24px), inner padding 3px
- Dark pill indicator slides with spring curve, squish animation during slide
- Track press: scale(0.95) → spring back
- Color swap: selected white, unselected ink-tertiary

#### `DayBar`
Horizontal scrollable day selector.
- Props: `days: {label: string, weekday: string}[]`, `selected: number`, `onChange: (i: number) => void`
- Selected: glass pill bg, coral text
- Unselected: no bg, ink-tertiary text
- Right scroll arrow `›` when overflowing

#### `NavDock`
Bottom floating island navigation.
- Props: `tabs: {icon: ReactNode, label: string}[]`, `active: number`, `onChange: (i: number) => void`
- Glass pill container: blur(50px) saturate(1.8) brightness(1.05)
- Sliding glass indicator with spring curve 600ms
- Active tab: coral icon/text, inactive: ink-tertiary
- Dock body bounce on switch: squash & stretch

#### `Sheet`
Extends shadcn/ui Sheet as frosted bottom sheet.
- Frost strong background, blur(50px)
- Top border white 55%, top radius 24px
- Drag handle: 36×4px centered
- Enter: slide up expressive 380ms, exit: slide down ease-out 280ms

#### `Dialog`
Extends shadcn/ui Dialog with glass styling.
- Glass card container with blur + shadow
- Enter: scale(0.92→1.0) + fade, spring 350ms
- Exit: scale(1.0→0.95) + fade, ease-out 200ms

#### `Popover`
Extends shadcn/ui Popover with glass + spring animation.
- Glass panel: white 85% bg, blur(40px) saturate(1.6), radius 14px
- Enter: scale(0.85→1.06→1.0) + blur(4→0), spring 350ms
- Exit: scale(1→0.92) + blur(0→4) + fade, ease-out 200ms
- Item hover: rgba(28,28,30,0.04) bg
- Destructive items: #FF3B30 text

#### `Toast`
Extends shadcn/ui Toast.
- Slide down from top + fade in, spring 400ms
- Exit: slide up + fade, ease-out 250ms
- Auto-dismiss: 2500ms

### Phase 3 — Business

#### `TravelCard`
Travel list card.
- Props: `title`, `dateRange`, `status`, `cities[]`, `avatars[]`, `days`
- GlassCard with status tint overlay
- Status badge top-right, city tags, dashed divider, avatar row + day count

#### `ScheduleCard`
Two-tier schedule item (upper + lower).
- Props: `variant: 'poi' | 'hotel' | 'unplanned'`, `cover: {emoji, bg}`, `time`, `title`, `address`, `photos?[]`, `note?`, `onNav`, `onMore`
- Upper: GlassCard (or dark variant for hotel) — cover 48px + time badge + title 17px + address + nav button coral pill + more button top-right
- Lower (if photos/note exist): separate rounded rect, subtle bg differentiation, 14px top radius + 20px bottom radius, photos row 40px + note 2-line clamp
- Upper has 24px top radius, 14px bottom radius, margin-bottom 0
- Hotel: nightsky dark upper + nightsky-light lower

#### `LuggageCategory`
Expandable luggage category card.
- Props: `emoji`, `name`, `items[]`, `checkedIds`, `canEdit`, `onToggle`, `onAdd`, `onDelete`
- GlassCard, header 44px with expand/collapse
- Circular checkboxes: checked coral + checkmark, unchecked border
- Checked items: line-through + ink-secondary
- Add item row: coral plus icon + text

#### `SearchResultItem`
Map search result row.
- Props: `index`, `name`, `address`, `onAdd`
- Left: coral circle with number
- Center: name + address
- Right: coral-tint circle + icon button

#### `MapInfoBar`
Map bottom info card.
- Props: `emoji`, `name`, `time`, `address`, `photos?[]`, `hasNote?`, `onNav`, `onViewNote`
- Glass card, title + coral circle nav button, time · address, photo thumbnails + "查看备注 ›"

---

## 5. Phasing

| Phase | Scope | Output |
|-------|-------|--------|
| 1 | Tokens + AmbientBg + GlassCard + Button + Badge + TimeBadge + Icon + Skeleton | Core primitives, Storybook running |
| 2 | PillToggle + DayBar + NavDock + Sheet + Dialog + Popover + Toast | All interactive components |
| 3 | TravelCard + ScheduleCard + LuggageCategory + SearchResultItem + MapInfoBar | Business components |

Each phase is independently useful. Phase 1 alone gives a functional design token system and base components.

---

## 6. Dev Setup

- **pnpm workspace** member: `packages/roadbook-ui`
- **Dev**: `pnpm --filter roadbook-ui storybook` (port 6006)
- **Build**: `pnpm --filter roadbook-ui build` (Vite library mode, outputs ESM + types)
- **Lint**: inherits workspace ESLint config
- Storybook preview wraps all stories with `AmbientBg` + canvas background

---

## 7. Anti-Patterns (enforced by design)

- No pure black `#000000` — use ink tokens
- No font-weight > 500
- No cold gray skeletons — warm tone only
- No circular spinners — shimmer skeleton only
- No solid opaque cards — always some translucency
- No competing accent colors — coral only (lavender only for hotel)
