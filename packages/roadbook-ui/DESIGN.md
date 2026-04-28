# Design System: 小肥路书 · Frosted Warmth

**Project:** Roadbook (小肥路书) — Visual itinerary planning tool
**Platform:** Mobile-first (Flutter iOS/Android), React component library

---

## 1. Visual Theme & Atmosphere

A warm, analog-feeling mobile interface that evokes a **sunlit planning table** — the kind of surface you'd spread a paper map across on a lazy afternoon. Translucent frost-glass cards float over a slowly breathing warm canvas, as if frosted vellum overlays were catching golden-hour light.

The mood is simultaneously **cozy and precise**: soft sand tones provide warmth while crisp glass edges and purposeful coral accents inject just enough energy to feel productive. Three drifting radial gradient orbs (Sand `#F5E6C8`, Honey `#F0D898`, Cream `#F5E0B0`) breathe slowly beneath the surface, giving the canvas a living, organic quality.

**Density:** Medium (5/10) — generous whitespace without feeling empty.
**Variance:** Restrained (4/10) — consistent card rhythms, no chaotic layouts.
**Motion:** Ambient + purposeful (5/10) — background orbs drift continuously; UI elements respond with spring micro-interactions on touch.

---

## 2. Color Palette & Roles

### Canvas & Glass Surfaces
- **Warm Canvas** (`#F2EDE8`) — The base tone of the entire interface. A sun-bleached linen that never feels clinical. All content floats above this.
- **Card Frost** (`rgba(255,255,255,0.52)`) — The primary glass surface. Translucent enough to reveal the warm canvas and ambient orbs beneath, creating depth without heaviness.
- **Card Frost Strong** (`rgba(255,255,255,0.72)`) — Elevated surfaces like bottom sheets and modals. More opaque for better readability over complex backgrounds.
- **Frost Border** (`rgba(255,255,255,0.65)`) — Delicate white hairline edges that catch light on glass surfaces, defining boundaries without harshness.

### Brand Energy
- **Coral Ember** (`#FF6B3D`) — The single accent that brings life. Warm orange-red used for navigation buttons, active states, and floating action buttons. Strictly limited to max 2 instances per screen to preserve impact.
- **Coral Glow** (`rgba(255,107,61,0.35)`) — Soft luminous shadow beneath coral buttons, as if the button emits warmth.
- **Coral Tint** (`rgba(255,107,61,0.10)`) — Whisper-light wash used for time badges, status tag backgrounds, and selected state fills.

### Dark Anchors
- **Dark Pill** (`rgba(28,28,30,0.88)`) — Near-black with slight translucency. Primary call-to-action buttons, back buttons, and add buttons. Provides visual weight and contrast against the warm palette.
- **Dark Pill Hover** (`rgba(28,28,30,0.75)`) — Slightly lifted on press, revealing more canvas warmth through the translucency.

### Ink Family (Single-Hue Text)
All text derives from a single ink source `#1C1C1E` at varying opacities. Never mix gray hues — this maintains the warm, unified feel.
- **Ink Primary** (`rgba(28,28,30,0.90)`) — Headlines, card titles, names. Strong but not harsh.
- **Ink Secondary** (`rgba(28,28,30,0.50)`) — Body text, descriptions. Comfortable reading weight.
- **Ink Tertiary** (`rgba(28,28,30,0.28)`) — Captions, placeholders, inactive icons. Present but unobtrusive.

### Accommodation Accent
- **Lavender** (`#8C5CF6`) — Reserved exclusively for hotel/accommodation elements. A cool counterpoint to the warm coral.
- **Lavender Tint** (`rgba(140,92,246,0.10)`) — Cover backgrounds and badge fills for hotel items.
- **Lavender Text** (`#6D3FC0`) — Deepened lavender for readable badge text on tinted backgrounds.

### Nightsky (Hotel Dark Cards)
- **Nightsky** (`rgba(20,30,48,0.88)`) — Deep blue-black background for hotel schedule cards. Creates dramatic contrast, evoking the feeling of arriving at night.
- **Nightsky Light** (`rgba(20,30,48,0.65)`) — Slightly lighter variant for hotel card lower sections (notes/photos area).

### Semantic Status
- **Ongoing** — Coral Tint bg + deep coral text (`#D4410A`). Warm, active energy.
- **Upcoming** — Sunstone tint (`rgba(224,133,0,0.10)`) + amber text (`#B56800`). Anticipation.
- **Planning** — Neutral ink bg (`rgba(28,28,30,0.06)`) + Ink Secondary. Quiet, preparatory.
- **Ended** — Faintest ink bg (`rgba(28,28,30,0.04)`) + Ink Tertiary. Gently faded.

### Banned Colors
- Pure black `#000000` — always use Ink tokens instead
- Neon/outer glow shadows — shadows are always neutral or canvas-tinted
- Blue-tinted text `#1E243C` — use neutral ink `#1C1C1E`
- iOS system gray `#F2F2F7` — use Warm Canvas

---

## 3. Typography Rules

**Font Family:** PingFang SC — CJK-primary, no Latin-first mixing. The rounded, humanist quality of PingFang complements the warm aesthetic.

| Style | Size | Weight | Spacing | Character |
|-------|------|--------|---------|-----------|
| Display | 34px | Ultralight (w200) | -0.03em | Grand, airy page titles. The thinness creates elegance at large sizes. |
| Title | 22px | Light (w300) | -0.02em | Section headers, sheet titles. Graceful but readable. |
| App Bar | 18px | Medium (w500) | -0.01em | Navigation titles. The only place medium weight appears at this size. |
| Headline | 17px | Medium (w500) | 0 | Card titles, schedule names. Confident without being heavy. |
| Body | 15px | Regular (w400) | 0 | Descriptions, button labels. Comfortable reading size. |
| Caption | 12px | Regular (w400) | 0 | Secondary info, timestamps. Small but legible. |
| Micro | 10px | Regular (w400) | 0 | Dock labels, subtle metadata. Minimum readable size. |

**Strict weight ceiling:** w500 maximum. Never use w600, w700, w800, or w900. The design achieves hierarchy through size and opacity, not boldness. Display titles use w200 — the thinnest weight — because large type doesn't need weight to command attention.

---

## 4. Component Stylings

### Glass Surfaces
All cards share the frosted glass material:
- **Standard Card:** `backdrop-filter: blur(40px) saturate(1.4)` with Frost background, Frost Border hairline, and a subtle specular highlight (`linear-gradient(160deg, rgba(255,255,255,0.35) → transparent 40%)`) that simulates light catching a glass edge.
- **Bottom Sheet:** Stronger frost (`blur(50px) saturate(1.8)`) with higher opacity. Top-only rounded corners (24px). Drag handle: 36×4px centered pill, ink at 16%.
- **Dock (Navigation Island):** The most refined glass — `blur(50px) saturate(1.8) brightness(1.05)` with a pill shape (radius 100px). Inset from edges by 20px, floating 16px from bottom.

**Shadow language:** Always whisper-soft and diffused. Standard cards: `0 8px 32px rgba(0,0,0,0.06)`. Never heavy or high-contrast.

### Buttons
- **Dark Pill:** Near-black translucent, white text, pill shape, with trailing → arrow. The primary action.
- **Coral Action:** Warm orange, white text, with a luminous coral glow shadow beneath. For navigation and high-energy actions.
- **Glass Button:** Frost surface matching cards, ink text. Blends into the environment.
- **Ghost Button:** Transparent with a subtle 1px border. For secondary actions like "添加分类."
- **Circle Icons:** 36px circles in dark or coral. For back (‹), add (＋), navigation (▶), more (⋯).
- **Press feedback:** All buttons scale to 92% on press, then spring back with a bouncy `cubic-bezier(0.34, 1.3, 0.64, 1)` over 400ms.

### Schedule Cards (Two-Tier Structure)
Each schedule item is composed of two stacked rounded rectangles:
- **Upper tier:** The schedule info — cover emoji (48px rounded square), time badge, title (17px), address, navigation button, more menu. Full 24px top radius, 14px bottom radius.
- **Lower tier:** Notes and photos — photo thumbnails (40px squares), note text (max 2 lines, ellipsis). 14px top radius, 20px bottom radius. Subtly darker background for visual separation.
- **Hotel variant:** Both tiers use nightsky dark backgrounds. Text becomes white, borders become faint white.
- **Gap:** Zero — the two tiers sit flush against each other, creating one cohesive unit with distinct zones.

### Time Badges
Compact pill badges next to schedule covers:
- **POI:** Coral tint background, 12px, tight padding. Quick to scan.
- **Hotel:** Lavender background, 15px, roomier padding. "入住/退房" prefix makes it unmistakable.
- **Unplanned:** Neutral ink background, 12px. Deliberately understated.
- **Edit icon:** A tiny calendar icon (11px) appears to the right when editable, at 70% opacity to stay unobtrusive.

### Tags & Badges
- All pill-shaped (radius 100px)
- Status badges: small, color-coded by status
- City tags: unified dark style — never multi-colored. `rgba(28,28,30,0.05)` bg with `rgba(28,28,30,0.08)` border.

### Skeleton Screens
Warm-toned shimmer on glass cards:
- Bone base: `rgba(28,28,30,0.04)` — barely visible on warm canvas
- Shimmer highlight: `rgba(255,255,255,0.50)` sweeping at 120° angle
- 1.6s animation loop, staggered 100ms between cards
- Shape-matched to real layout (same padding, radius, position)
- Never cold gray. Never circular spinners.

---

## 5. Layout Principles

### Spacing System
| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight internal gaps |
| sm | 8px | Icon-text spacing |
| md | 12px | Within-card sections |
| lg | 16px | Card internal padding |
| xl | 24px | Between major sections |
| xxl | 32px | Page top breathing room |
| page-h | 20px | Horizontal page margins (sacred — never violated) |

### Card Rhythm
- Travel list cards: 14px gap between cards
- Schedule cards: 14px gap, 0px between upper/lower tiers
- Card padding: 16px (12px for compact schedule cards)
- Card radius: 24px standard, 16px for smaller cards, 14px for inner/lower sections

### Touch Targets
Minimum 44px for all interactive elements. This is non-negotiable — the app is designed for thumbs on phones.

### Dock Positioning
The floating navigation island sits 20px from left/right edges, 16px from bottom. Height 52px. Always present on main pages, never on pushed detail screens.

### Whitespace Philosophy
Generous but purposeful. The warm canvas is a feature, not wasted space — it lets the ambient orbs show through and gives the frosted cards room to breathe. Dense packing would kill the sunlit-table metaphor.

---

## 6. Motion & Animation

### Curves
- **Spring** `cubic-bezier(0.34, 1.3, 0.64, 1)` — 500-600ms. The signature feel. Slight overshoot creates organic, physical response. Used for dock slide, card appear, button release.
- **Ease Out** `cubic-bezier(0.22, 0.0, 0.36, 1)` — 280ms. Quick deceleration for dismissals and tab switches.
- **Expressive** `cubic-bezier(0.22, 1.0, 0.36, 1)` — 380ms. Stronger overshoot for emphasis. Sheet entrances, staggered reveals.

### Interaction Patterns
- **Button press:** Scale down to 92%, spring back on release
- **Tab icon press:** Scale down to 88%, spring back over 500ms
- **Card long press:** Gentle scale to 97%, ease out 200ms
- **Sheet enter:** Slide up from bottom with expressive curve
- **Dialog enter:** Scale from 92% + fade in with spring
- **Popover:** Scale from 85% + blur(4px→0) with spring overshoot to 106% then settle

### Ambient
- Background orbs: continuous 20s drift loop, each with unique phase
- No loading spinners — skeleton shimmer only
- Transitions between pages use iOS-style slide with parallax

---

## 7. Anti-Patterns (Strictly Banned)

- Pure black `#000000` anywhere
- Font weight above w500
- Multi-color tag cycles (coral + neutral only)
- Blue-tinted text hues
- Gradient text on typography
- Neon or outer glow shadows
- iOS system gray as background
- Circular loading spinners
- Competing accent colors on the same screen
- Solid opaque cards (always some translucency)
- White borders at 90% opacity on dark backgrounds
