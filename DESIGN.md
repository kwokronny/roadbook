# Design System: 小肥路书 Roadbook

## 1. Visual Theme & Atmosphere

A warm, travel-journal-inspired mobile interface with soft material surfaces floating over a slow-breathing ambient canvas. The atmosphere is **analog warmth meets digital precision** — like a sunlit planning table with translucent vellum cards laid over a hand-painted watercolor wash. Density sits at **5/10** (balanced daily app), variance at **4/10** (consistent but not rigid), motion at **4/10** (ambient background drift, spring micro-interactions on controls).

**Platform:** iOS-native mobile (Flutter). All design decisions prioritize one-handed reachability, thumb-friendly touch targets, and platform-consistent transitions (Cupertino page transitions, no splash effects).

## 2. Color Palette & Roles

### Primary
- **Coral Ember** (#FF5B2E) — Brand accent. FAB, primary CTA fills, active bottom nav, selected calendar days. Saturated but warm, never neon. Use sparingly — max 2 instances per visible screen.

### Canvas & Surface
- **Warm Linen** (#F7F3EE) — App canvas base. The ambient mesh background paints over this.
- **Card Ivory** (rgba(255,255,255,0.90)) — Glass card surface. 90% white, 10% canvas bleed-through via backdrop blur. Clean but not sterile.
- **Sheet Frost** (rgba(255,255,255,0.72)) — Bottom sheet overlay. More translucent than cards to show depth hierarchy.

### Text Hierarchy (blue-ink family)
All text derives from a single navy-ink hue (#1E243C) at varying opacities. This keeps the palette unified — never introduce gray text from a different hue family.
- **Ink Primary** (rgba(30,36,60,0.92)) — Headlines, card titles, names. Near-black with a warm-navy cast.
- **Ink Secondary** (rgba(30,36,60,0.55)) — Body text, descriptions. Comfortable reading contrast.
- **Ink Tertiary** (rgba(30,36,60,0.35)) — Captions, timestamps, placeholders. Recedes without disappearing.

### Semantic Accents (used in tags, badges, tinted surfaces)
Each accent is used at 10% fill / 22% border / dark variant text — never at full saturation on large surfaces.
- **Lavender** (#7C55F0) → dark: #5C38CC — Hotel/accommodation contexts
- **Spearmint** (#0AAD88) → dark: #0A8A6D — Ongoing/active status, confirmed toggle
- **Sky Blue** (#2A7EF5) → dark: #1A5FC8 — Planning status, focus rings
- **Sunstone** (#E08500) → dark: #B56800 — Upcoming/attention status
- **Petal Pink** (#E8387A) → dark: #C02060 — Decorative tags, "coming soon" badges

### Structural
- **Card Border** (rgba(0,0,0,0.10)) — Subtle dark hairline on cards. 1px, not decorative.
- **Divider** (rgba(30,36,60,0.08)) — Dashed separators inside cards. Barely visible.
- **Form Fill** (rgba(30,36,60,0.05)) — Input backgrounds on white sheets. Ghost-level tint.

### Banned
- Pure black (#000000) — always use Ink Primary instead
- Neon/outer glow shadows — all shadows are neutral or tinted to canvas hue
- High-saturation full-surface fills — accents only appear in pills, badges, small icons

## 3. Typography Rules

- **Display / Large Title:** PingFang SC Light (w300), 34px, -0.85 letter-spacing. Ultra-thin for page headers. Hierarchy through weight contrast with body text, not size escalation.
- **Title 2:** PingFang SC Regular (w400), 22px, -0.33 tracking. Sheet headers, section titles.
- **Headline:** PingFang SC Medium (w500), 17px. Card titles, schedule names. The workhorse weight.
- **Body:** PingFang SC Regular (w400), 17px, Ink Secondary color. Comfortable reading, never exceeds viewport width.
- **Caption:** PingFang SC Regular (w400), 12px, Ink Tertiary. Dates, metadata, secondary info.
- **Micro:** 11px, Ink Secondary. Badges, tag labels.

**Banned weights:** w700, w800, w900. The system's maximum weight is w600 (used only in legacy calendar highlights). Light/regular/medium provides sufficient hierarchy.

**Chinese optimization:** PingFang SC as primary. System font fallback only. No mixing Latin-first fonts with CJK — the entire interface is CJK-primary.

## 4. Component Stylings

### Glass Cards
The foundational surface. Semi-translucent white over the ambient mesh canvas.
- Background: rgba(255,255,255,0.90) with backdrop blur sigma 12
- Border: 1px rgba(0,0,0,0.10) — structural, not decorative
- Shadow: dual-layer (16px/4px blur, neutral black tint)
- Corner radius: 20px
- Specular highlight: diagonal gradient overlay (top-left to center, white 50% → transparent)
- Optional tint: status color at ~4-6% opacity for contextual cards

### Glass Navigation Island
Floating pill bar, detached from screen edges.
- backdrop blur sigma 40, rgba(255,255,255,0.55)
- Border: 1px rgba(255,255,255,0.90)
- Corner radius: 100px (full pill)
- Active tab: Coral Ember icon + text, w500. Inactive: Ink Tertiary, w400.
- Position: bottom 16px, horizontal inset 20px

### Bottom Sheets (Frosted)
- backdrop blur sigma 40
- Background: rgba(255,255,255,0.72)
- Top border: 1px rgba(255,255,255,0.90) for edge highlight
- Upward shadow for depth separation
- Drag handle: 36x4px, rgba(30,36,60,0.16), centered

### Buttons
- **Primary CTA:** Coral gradient fill (#FF5B2E → #FF8C42), pill radius 100, white text w500 17px. Used for save/create actions. Max 1 per sheet.
- **Navigation pill:** Solid accent fill (coral or lavender), pill radius, white icon + text. Compact, contextual.
- **Glass circle:** 32-36px circle, rgba(255,255,255,0.55) with blur, subtle border. For appbar actions (back, more, add).
- **Ghost/tinted:** rgba(30,36,60,0.05) fill, Ink Secondary text. For secondary actions ("更多").

### Tags & Badges
- Pill shape (radius 100)
- Fill: accent at 10% opacity
- Border: accent at 22% opacity, 1px
- Text: dark variant of accent, w400-w500, 11px
- City tags cycle through the 5 accent colors by index

### Inputs (on white sheets)
- Fill: rgba(30,36,60,0.05)
- Border: rgba(30,36,60,0.08), 1px. Rounds to 14px
- Focus: Sky Blue at 45% opacity, 1.5px border
- Label: above input, Ink Secondary. Floats to Sky Blue on focus.
- No floating labels inside the field — label always visible above

### Loading
- CircularProgressIndicator in Coral Ember. Centered.
- Future improvement: skeletal shimmer matching card dimensions

### Empty States
- Centered icon (48px, Ink Tertiary) + caption text. Minimal, not illustrated.

## 5. Layout Principles

- **Single-column mobile:** All content flows vertically. No side-by-side panels in final design (day sidebar removed in favor of horizontal day bar).
- **Horizontal scroll for selectors:** Day bar, city chips — pill-shaped items in a horizontal ListView with 6px gaps.
- **Card stacking:** 20px vertical gap between schedule cards. 14px between travel list cards.
- **Page horizontal padding:** 16px constant.
- **Card internal padding:** 12-16px. Upper section (info) + dashed divider + lower section (media/notes) for two-zone cards.
- **Touch targets:** Minimum 44px height for all interactive elements.
- **Safe area respect:** Bottom nav avoids system home indicator. Sheets account for keyboard insets.

## 6. Motion & Interaction

### Ambient Canvas
- 3 radial gradient blobs drift in slow elliptical paths (20-second full loop)
- Colors: Sand (#F5E6C8, 19%), Honey (#F0D898, 16%), Cream (#F5E0B0, 13%)
- Each blob has unique frequency and phase offset — organic, not synchronized
- Performance: CustomPainter with `isComplex: true`, repaints per frame via AnimationController

### Interaction Curves
- **Spring:** Cubic(0.34, 1.56, 0.64, 1.0) — micro-interactions, button press, toggle
- **Ease Out:** Cubic(0.22, 0.0, 0.36, 1.0) — slide transitions, sheet dismiss
- **Expressive:** Cubic(0.22, 1.0, 0.36, 1.0) — emphasis animations, staggered reveals

### Durations
- Fast: 180ms — toggles, opacity changes, focus rings
- Normal: 280ms — sheet expand, tab switch, card state change
- Slow: 380ms — emphasis, page transitions

### Platform Motion
- Cupertino page transitions on both iOS and Android
- No Material splash/ripple — highlight only at 6% primary opacity
- AnimatedContainer for state transitions (day chip selection, nav tab)

## 7. Anti-Patterns (Banned)

- **No pure black** — always Ink Primary rgba(30,36,60,0.92)
- **No heavy font weights** — w700+ banned. System max is w600 for rare emphasis
- **No neon/outer glow** — shadows are always neutral, diffused, and tinted to canvas
- **No oversaturated surfaces** — accents at 10% fill max on backgrounds
- **No solid opaque cards** — every surface has at least 5-10% translucency to connect with the canvas
- **No iOS system gray backgrounds** — the warm linen canvas replaces the cold #F2F2F7
- **No floating labels inside inputs** — label sits above, always visible
- **No circular loading spinners in empty states** — use text + icon composition
- **No generic gradient text** — gradients only in button fills, never on typography
- **No competing accent colors on screen** — one dominant accent per context (coral for actions, status color for badges)
- **No sharp corners on interactive elements** — minimum 10px radius; pills (100px) preferred for standalone controls
