# Design System: 小肥路书 · Frosted Warmth

**Date:** 2026-04-10
**Style:** Warm canvas, frost glass surfaces, dark pill accents, coral energy
**Platform:** Flutter iOS/Android mobile

---

## 1. Visual Atmosphere

A warm, analog-feeling mobile interface. Translucent frost-glass cards float over a slowly breathing warm canvas. The mood is **sunlit planning table** — sand-toned paper with frosted vellum overlays. Density 5/10, variance 4/10, motion 5/10 (ambient drift + spring micro-interactions).

---

## 2. Color Palette

### Canvas & Surface
| Token | Value | Role |
|-------|-------|------|
| **Warm Canvas** | `#F2EDE8` | App base background. Mesh orbs paint over this. |
| **Card Frost** | `rgba(255,255,255,0.52)` | Glass card surface. Translucent, backdrop-blur visible. |
| **Card Frost Strong** | `rgba(255,255,255,0.72)` | Bottom sheets, elevated surfaces. |
| **Card Border** | `rgba(255,255,255,0.65)` | White hairline on glass edges. |

### Brand Accent
| Token | Value | Role |
|-------|-------|------|
| **Coral Ember** | `#FF6B3D` | Single accent. FAB, nav buttons, active tab icon/text, status "active". Max 2 instances per screen. |
| **Coral Glow** | `rgba(255,107,61,0.35)` | Shadow on coral buttons. |
| **Coral Tint** | `rgba(255,107,61,0.10)` | Badge/tag background for active status. |

### Dark Accents
| Token | Value | Role |
|-------|-------|------|
| **Dark Pill** | `rgba(28,28,30,0.88)` | Primary CTA buttons, back button, add button. Replaces gradient CTAs. |
| **Dark Pill Hover** | `rgba(28,28,30,0.75)` | Pressed state. |

### Text (single-hue ink family)
All text from `#1C1C1E` at varying opacities. Never mix gray hues.
| Token | Value | Role |
|-------|-------|------|
| **Ink Primary** | `rgba(28,28,30,0.90)` | Headlines, card titles, names. |
| **Ink Secondary** | `rgba(28,28,30,0.50)` | Body text, descriptions. |
| **Ink Tertiary** | `rgba(28,28,30,0.28)` | Captions, placeholders, inactive icons. |

### Semantic Status
| Status | Badge BG | Badge Text | Card Tint |
|--------|----------|------------|-----------|
| Ongoing | `rgba(255,107,61,0.10)` | `#D4410A` | `rgba(255,107,61,0.04)` |
| Upcoming | `rgba(224,133,0,0.10)` | `#B56800` | `rgba(224,133,0,0.04)` |
| Planning | `rgba(28,28,30,0.06)` | Ink Secondary | none |
| Ended | `rgba(28,28,30,0.04)` | Ink Tertiary | none |

### Accent (secondary, used sparingly)
| Token | Value | Role |
|-------|-------|------|
| **Lavender** | `#8C5CF6` | Hotel/accommodation accent. |
| **Lavender Tint** | `rgba(140,92,246,0.10)` | Hotel badge/tag bg. |
| **Lavender Text** | `#6D3FC0` | Hotel badge text. |

### Tags (simplified)
City tags use **unified dark style** (not multi-color):
- BG: `rgba(28,28,30,0.05)`
- Border: `rgba(28,28,30,0.08)`
- Text: Ink Secondary

Only status and hotel tags use color.

### Banned Colors
- Pure black `#000000` — use Ink Primary
- Neon/outer glow — shadows always neutral or canvas-tinted
- Multi-color tag cycle — one accent (coral) + neutral dark tags only
- Blue-tinted text — use `#1C1C1E` ink, not `#1E243C`

---

## 3. Typography

Font: **PingFang SC** (CJK-primary, no Latin-first mixing)

| Style | Size | Weight | Letter Spacing | Color |
|-------|------|--------|----------------|-------|
| Display | 34px | w200 | -0.03em | Ink Primary |
| Title | 22px | w300 | -0.02em | Ink Primary |
| App Bar Title | 18px | w500 | -0.01em | Ink Primary |
| Headline | 17px | w500 | 0 | Ink Primary |
| Body | 15px | w400 | 0 | Ink Secondary |
| Caption | 12px | w400 | 0 | Ink Tertiary |
| Micro | 10px | w400 | 0 | Ink Tertiary |

**Banned:** w700, w800, w900. System max is w500. Display uses w200 for ultra-thin large titles.

---

## 4. Glass Surfaces

### Card / Schedule Item
```
backdrop-filter: blur(40px) saturate(1.4)
background: rgba(255,255,255,0.52)
border: 1px solid rgba(255,255,255,0.65)
border-radius: 24px
shadow: 0 8px 32px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.03)
specular: linear-gradient(160deg, rgba(255,255,255,0.40) → transparent 40%)
```

### Bottom Sheet (Frosted)
```
backdrop-filter: blur(50px) saturate(1.8)
background: rgba(255,255,255,0.72)
border-top: 1px solid rgba(255,255,255,0.55)
shadow: 0 -8px 32px rgba(0,0,0,0.06)
border-radius: top 24px
drag-handle: 36×4px, rgba(28,28,30,0.16), centered
```

### Navigation Dock (Floating Island)
```
backdrop-filter: blur(50px) saturate(1.8) brightness(1.05)
background: rgba(255,255,255,0.30)
border: 1px solid rgba(255,255,255,0.50)
border-radius: 100px (pill)
shadow: 0 8px 32px rgba(0,0,0,0.06), inset 0 1px 0 rgba(255,255,255,0.55)
specular-line: top center, white gradient fadeout
position: bottom 20px, left/right 20px
```

### Glass Indicator (Dock sliding pill)
```
background: rgba(255,255,255,0.45)
border: 1px solid rgba(255,255,255,0.60)
border-radius: 100px
shadow: 0 2px 12px rgba(0,0,0,0.05), inset 0 1px 0 rgba(255,255,255,0.80)
specular: linear-gradient(160deg, rgba(255,255,255,0.50) → transparent 45%)
z-index: above icons (covers them with translucency)
pointer-events: none (clicks pass through)
```

### Input (on white sheets)
```
background: rgba(255,255,255,0.45)
border: 1px solid rgba(255,255,255,0.60)
border-radius: 16px
focus: border rgba(255,107,61,0.40), background rgba(255,255,255,0.60)
```

### Input (on glass/mesh background)
```
background: rgba(28,28,30,0.05)
border: 1px solid rgba(28,28,30,0.08)
border-radius: 14px
focus: border rgba(255,107,61,0.40)
```

---

## 5. Components

### Buttons
| Type | Background | Text | Shape |
|------|-----------|------|-------|
| **Primary CTA** | Dark Pill `rgba(28,28,30,0.88)` | White, 15px w400 | Pill 100px, with → arrow |
| **Coral Action** | Coral `#FF6B3D` | White, 15px w400 | Pill 100px |
| **Glass** | Card Frost | Ink Primary, 15px w400 | Pill 100px |
| **Ghost** | Transparent | Ink Secondary, 15px w400 | Pill 100px, 1px border rgba(28,28,30,0.12) |
| **Glass Circle** | Dark Pill | White icon | Circle 36px. For back, add, more. |
| **Coral Circle** | Coral | White icon | Circle 36px. For navigation. |

Press feedback: `scale(0.92)` spring bounce.

### Tags & Badges
- Pill shape (radius 100px)
- Status tags: Coral Tint bg + dark coral text (ongoing), Sunstone tint (upcoming), neutral (planning/ended)
- City tags: unified dark style — `rgba(28,28,30,0.05)` bg, `rgba(28,28,30,0.08)` border, Ink Secondary text
- Hotel tags: Lavender Tint bg + Lavender Text

### Cards (Travel List)
- Glass card with status tint overlay
- Layout: Title + status badge (top), date + days (below), city tags, dashed divider, avatars + more menu

### Schedule Cards (Detail)
- Glass card, hotel cards get lavender tint
- Cover: 52×52px, rounded 14px, tinted bg + emoji
- Time: tinted pill badge (coral for timed, lavender for hotel, neutral for unplanned)
- Nav button: Coral circle 36px, top-right corner
- Lower section (if notes/photos): dashed divider, subtle tinted bg area
- More button: pill "更多" below address

### Floating Action Button
- Coral `#FF6B3D`, circle, white icon
- Shadow: `0 4px 16px rgba(255,107,61,0.30)`

### Day Bar (horizontal, top of detail)
- Horizontal scroll, pill chips
- Each: "Day N" + small weekday text (two lines)
- Selected: glass indicator slides to position (see dock interaction)
- Text: Coral when selected, Ink Tertiary when not

---

## 6. Ambient Background

Warm canvas with 3 drifting radial gradient orbs:

| Orb | Color | Opacity | Position |
|-----|-------|---------|----------|
| Sand | `#F5E6C8` | 19% | Top-left, drifts |
| Honey | `#F0D898` | 16% | Top-right, drifts |
| Cream | `#F5E0B0` | 13% | Bottom-center, drifts |

Base: `#F2EDE8`
Animation: 20-second loop, each orb has unique frequency/phase.
Motion: `cos(t * freq + phase) * amplitude` — small elliptical paths.

---

## 7. Dock Interaction (Sliding Glass)

The bottom navigation uses a **sliding glass indicator**:

1. **Glass pill** sits above icons (z-index above, pointer-events none)
2. On tab switch: pill **slides** to new position with spring curve
3. During slide: pill background becomes more translucent + adds **backdrop-filter blur(16px)** (motion blur effect)
4. After arriving: blur clears, background restores to 45% white
5. **Dock body bounces**: squash & stretch animation (scale X/Y oscillation)
6. **Icons/text**: selected tab turns Coral simultaneously; previous tab turns Ink Tertiary
7. All tabs always show icon + label (no hide/expand)

Curves:
- Slide: `Cubic(0.34, 1.3, 0.64, 1)` — 600ms
- Dock bounce: `Cubic(0.34, 1.2, 0.64, 1)` — 650ms
- Color change: 300ms ease
- Blur transition: 300ms ease, clears after 500ms

---

## 8. Motion & Animation

### Curves
| Name | Cubic | Duration | Use |
|------|-------|----------|-----|
| Spring | `(0.34, 1.3, 0.64, 1)` | 500-600ms | Dock slide, card appear |
| Ease Out | `(0.22, 0.0, 0.36, 1)` | 280ms | Sheet dismiss, tab switch |
| Expressive | `(0.22, 1.0, 0.36, 1)` | 380ms | Emphasis, staggered reveals |

### Micro-interactions
- Button press: `scale(0.92)` → `scale(1.0)` spring
- Tab press: `scale(0.88)` → `scale(1.0)` spring
- Card appear: staggered cascade (future enhancement)

### Ambient
- Background orbs: continuous 20s loop drift
- No loading spinners in empty states — use text + icon composition

---

## 9. Spacing & Layout

| Token | Value |
|-------|-------|
| xs | 4px |
| sm | 8px |
| md | 12px |
| lg | 16px |
| xl | 24px |
| xxl | 32px |
| touch | 44px (min tap target) |
| page-h | 20px (horizontal page padding) |
| card-padding | 16px |
| card-gap | 14px (travel list), 20px (schedule list) |
| card-radius | 24px |
| card-radius-sm | 16px |
| pill | 100px |
| sheet-radius | 24px |
| dock-inset | 20px (from edges) |
| dock-height | 58px |

---

## 10. Screens & Sheets

### Pages
1. **Travel List** — Display title "旅程", glass search bar, glass travel cards with status tint, floating dock
2. **Travel Detail** — App bar (dark pill back + title + glass toggle + dark pill more), Day bar (horizontal), schedule glass cards, coral nav circles
3. **Discover** — Display title "发现", search + city chips, public travel cards
4. **Profile** — Display title "我的", glass user card, glass menu groups
5. **Sign In / Sign Up** — Frosted glass form card over mesh

### Bottom Sheets (all frosted glass)
1. **Travel Form** — Create/edit travel. iOS left-right grouped form. White form card on frost sheet.
2. **Schedule Edit** — Name, screenshots, notes fields
3. **Quick Time** — Day scroll row + hour grid for time picking
4. **City Picker** — Pinyin-grouped alphabetical list, search, multi-select
5. **Collaborator** — Invite link + collaborator list with role management
6. **Collect Import** — URL input + progress list

### Dialogs
1. **Calendar Picker** — Custom date range picker with frost background
2. **Confirm Delete** — Standard alert dialog
3. **Batch Move** — Day selection simple dialog

---

## 11. Anti-Patterns (Banned)

- Pure black `#000000`
- Font weight w600+ (max w500)
- Multi-color tag cycles (unified dark tags)
- Blue-tinted text hue (`#1E243C`) — use neutral ink `#1C1C1E`
- Gradient text on typography
- Neon/outer glow shadows
- iOS system gray `#F2F2F7` as background (use warm canvas)
- Circular loading spinners in empty states
- Competing accent colors on same screen (coral only)
- Solid opaque cards (always some translucency)
- White `rgba(255,255,255,0.90)` borders on dark backgrounds (use subtle borders)
