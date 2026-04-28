# roadbook-ui Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap `packages/roadbook-ui` with Vite + React + Tailwind + shadcn/ui + Storybook, implement design tokens and Phase 1 foundation components (AmbientBg, GlassCard, Button, Badge, TimeBadge, Icon, Skeleton).

**Architecture:** New pnpm workspace package. shadcn/ui components are copied in and re-themed. Tailwind config extends with Frosted Warmth tokens from CSS custom properties. Storybook 8 serves as dev environment and docs.

**Tech Stack:** Vite 6, React 18, TypeScript, Tailwind CSS 4, shadcn/ui, Storybook 8, pnpm workspace

---

## File Map

```
packages/roadbook-ui/
├── package.json
├── tsconfig.json
├── tsconfig.app.json
├── vite.config.ts
├── tailwind.config.ts
├── postcss.config.js
├── components.json
├── src/
│   ├── tokens/frost.css
│   ├── globals.css
│   ├── lib/utils.ts
│   ├── components/
│   │   ├── ui/button.tsx
│   │   ├── ui/badge.tsx
│   │   ├── ambient-bg.tsx
│   │   ├── glass-card.tsx
│   │   ├── time-badge.tsx
│   │   ├── icon.tsx
│   │   ├── icons.ts           (SVG path data)
│   │   └── skeleton.tsx
│   └── index.ts
├── stories/
│   ├── foundation/Colors.stories.tsx
│   ├── foundation/Typography.stories.tsx
│   ├── base/AmbientBg.stories.tsx
│   ├── base/GlassCard.stories.tsx
│   ├── base/Button.stories.tsx
│   ├── base/Badge.stories.tsx
│   ├── base/TimeBadge.stories.tsx
│   ├── base/Icon.stories.tsx
│   └── base/Skeleton.stories.tsx
└── .storybook/
    ├── main.ts
    └── preview.tsx
```

---

### Task 1: Scaffold package and dev tooling

**Files:**
- Create: `packages/roadbook-ui/package.json`
- Create: `packages/roadbook-ui/tsconfig.json`
- Create: `packages/roadbook-ui/tsconfig.app.json`
- Create: `packages/roadbook-ui/vite.config.ts`
- Create: `packages/roadbook-ui/postcss.config.js`
- Create: `packages/roadbook-ui/tailwind.config.ts`
- Create: `packages/roadbook-ui/components.json`
- Create: `packages/roadbook-ui/src/lib/utils.ts`
- Create: `packages/roadbook-ui/src/index.ts`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "@roadbook/ui",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "main": "src/index.ts",
  "scripts": {
    "dev": "storybook dev -p 6006",
    "build": "vite build",
    "build-storybook": "storybook build",
    "lint": "eslint src/"
  },
  "dependencies": {
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "tailwind-merge": "^2.6.0"
  },
  "devDependencies": {
    "@storybook/addon-essentials": "^8.6.0",
    "@storybook/react": "^8.6.0",
    "@storybook/react-vite": "^8.6.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.0",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.5.0",
    "storybook": "^8.6.0",
    "tailwindcss": "^3.4.17",
    "typescript": "^5.7.0",
    "vite": "^6.0.0"
  }
}
```

- [ ] **Step 2: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "dist",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*", "stories/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

- [ ] **Step 3: Create vite.config.ts**

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
    },
  },
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      formats: ['es'],
      fileName: 'index',
    },
    rollupOptions: {
      external: ['react', 'react-dom'],
    },
  },
})
```

- [ ] **Step 4: Create postcss.config.js**

```js
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

- [ ] **Step 5: Create tailwind.config.ts**

```ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{ts,tsx}', './stories/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        canvas: 'var(--canvas)',
        frost: {
          DEFAULT: 'var(--frost)',
          strong: 'var(--frost-strong)',
          border: 'var(--frost-border)',
        },
        coral: {
          DEFAULT: 'var(--coral)',
          glow: 'var(--coral-glow)',
          tint: 'var(--coral-tint)',
        },
        dark: {
          DEFAULT: 'var(--dark)',
          hover: 'var(--dark-hover)',
        },
        ink: {
          DEFAULT: 'var(--ink)',
          secondary: 'var(--ink-secondary)',
          tertiary: 'var(--ink-tertiary)',
        },
        lavender: {
          DEFAULT: 'var(--lavender)',
          tint: 'var(--lavender-tint)',
          text: 'var(--lavender-text)',
        },
        nightsky: {
          DEFAULT: 'var(--nightsky)',
          light: 'var(--nightsky-light)',
        },
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
        shimmer: {
          '0%': { backgroundPosition: '200% 0' },
          '100%': { backgroundPosition: '-200% 0' },
        },
        drift: {
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
  plugins: [],
}

export default config
```

- [ ] **Step 6: Create components.json (shadcn/ui config)**

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "src/globals.css",
    "baseColor": "neutral",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui"
  }
}
```

- [ ] **Step 7: Create src/lib/utils.ts**

```ts
import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

- [ ] **Step 8: Create src/index.ts (empty shell)**

```ts
// Components
export { AmbientBg } from './components/ambient-bg'
export { GlassCard } from './components/glass-card'
export { Button } from './components/ui/button'
export { Badge } from './components/ui/badge'
export { TimeBadge } from './components/time-badge'
export { Icon } from './components/icon'
export { Skeleton } from './components/skeleton'

// Utils
export { cn } from './lib/utils'
```

> Note: This will not compile yet — components don't exist. That's expected.

- [ ] **Step 9: Install dependencies**

Run:
```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook && pnpm install
```

Expected: dependencies installed, no errors. `packages/roadbook-ui/node_modules` created.

- [ ] **Step 10: Commit**

```bash
git add packages/roadbook-ui/package.json packages/roadbook-ui/tsconfig.json packages/roadbook-ui/vite.config.ts packages/roadbook-ui/postcss.config.js packages/roadbook-ui/tailwind.config.ts packages/roadbook-ui/components.json packages/roadbook-ui/src/lib/utils.ts packages/roadbook-ui/src/index.ts pnpm-lock.yaml
git commit -m "feat(roadbook-ui): scaffold package with Vite + React + Tailwind + shadcn/ui config"
```

---

### Task 2: Design tokens CSS + globals

**Files:**
- Create: `packages/roadbook-ui/src/tokens/frost.css`
- Create: `packages/roadbook-ui/src/globals.css`

- [ ] **Step 1: Create src/tokens/frost.css**

```css
:root {
  /* Canvas & Surface */
  --canvas: #F2EDE8;
  --frost: rgba(255, 255, 255, 0.52);
  --frost-strong: rgba(255, 255, 255, 0.72);
  --frost-border: rgba(255, 255, 255, 0.65);

  /* Brand Accent */
  --coral: #FF6B3D;
  --coral-glow: rgba(255, 107, 61, 0.35);
  --coral-tint: rgba(255, 107, 61, 0.10);

  /* Dark Accents */
  --dark: rgba(28, 28, 30, 0.88);
  --dark-hover: rgba(28, 28, 30, 0.75);

  /* Ink (single-hue family from #1C1C1E) */
  --ink: rgba(28, 28, 30, 0.90);
  --ink-secondary: rgba(28, 28, 30, 0.50);
  --ink-tertiary: rgba(28, 28, 30, 0.28);

  /* Lavender (hotel/accommodation) */
  --lavender: #8C5CF6;
  --lavender-tint: rgba(140, 92, 246, 0.10);
  --lavender-text: #6D3FC0;

  /* Nightsky (hotel card dark bg) */
  --nightsky: rgba(20, 30, 48, 0.88);
  --nightsky-light: rgba(20, 30, 48, 0.65);

  /* Semantic Status */
  --destructive: #FF3B30;
  --ongoing-bg: rgba(255, 107, 61, 0.10);
  --ongoing-text: #D4410A;
  --upcoming-bg: rgba(224, 133, 0, 0.10);
  --upcoming-text: #B56800;

  /* Skeleton */
  --bone-base: rgba(28, 28, 30, 0.04);
  --bone-shimmer: rgba(255, 255, 255, 0.50);
}
```

- [ ] **Step 2: Create src/globals.css**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@import './tokens/frost.css';

body {
  font-family: 'PingFang SC', system-ui, sans-serif;
  background: var(--canvas);
  color: var(--ink);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

- [ ] **Step 3: Commit**

```bash
git add packages/roadbook-ui/src/tokens/frost.css packages/roadbook-ui/src/globals.css
git commit -m "feat(roadbook-ui): add Frosted Warmth design tokens and globals"
```

---

### Task 3: Storybook setup

**Files:**
- Create: `packages/roadbook-ui/.storybook/main.ts`
- Create: `packages/roadbook-ui/.storybook/preview.tsx`
- Create: `packages/roadbook-ui/stories/foundation/Colors.stories.tsx`
- Create: `packages/roadbook-ui/stories/foundation/Typography.stories.tsx`

- [ ] **Step 1: Create .storybook/main.ts**

```ts
import type { StorybookConfig } from '@storybook/react-vite'

const config: StorybookConfig = {
  stories: ['../stories/**/*.stories.@(ts|tsx)'],
  addons: ['@storybook/addon-essentials'],
  framework: {
    name: '@storybook/react-vite',
    options: {},
  },
}

export default config
```

- [ ] **Step 2: Create .storybook/preview.tsx**

```tsx
import type { Preview } from '@storybook/react'
import React from 'react'
import '../src/globals.css'

const preview: Preview = {
  decorators: [
    (Story) => (
      <div
        style={{
          background: 'var(--canvas)',
          minHeight: '100vh',
          padding: '24px',
          position: 'relative',
        }}
      >
        {/* Ambient orbs */}
        <div style={{ position: 'fixed', inset: 0, zIndex: 0, overflow: 'hidden', pointerEvents: 'none' }}>
          <div
            style={{
              position: 'absolute', width: 350, height: 350,
              borderRadius: '50%', filter: 'blur(80px)',
              background: 'rgba(245,210,170,0.18)',
              top: '-5%', right: '-5%',
              animation: 'drift 25s ease-in-out infinite',
            }}
          />
          <div
            style={{
              position: 'absolute', width: 300, height: 300,
              borderRadius: '50%', filter: 'blur(80px)',
              background: 'rgba(255,180,140,0.12)',
              bottom: '5%', left: '-5%',
              animation: 'drift 25s ease-in-out infinite',
              animationDelay: '-10s',
            }}
          />
        </div>
        <div style={{ position: 'relative', zIndex: 1 }}>
          <Story />
        </div>
      </div>
    ),
  ],
}

export default preview
```

- [ ] **Step 3: Create Colors.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'

const tokenGroups = [
  {
    title: 'Canvas & Surface',
    tokens: [
      { name: '--canvas', label: 'Warm Canvas' },
      { name: '--frost', label: 'Card Frost' },
      { name: '--frost-strong', label: 'Card Frost Strong' },
      { name: '--frost-border', label: 'Card Border' },
    ],
  },
  {
    title: 'Brand Accent',
    tokens: [
      { name: '--coral', label: 'Coral Ember' },
      { name: '--coral-glow', label: 'Coral Glow' },
      { name: '--coral-tint', label: 'Coral Tint' },
    ],
  },
  {
    title: 'Dark Accents',
    tokens: [
      { name: '--dark', label: 'Dark Pill' },
      { name: '--dark-hover', label: 'Dark Pill Hover' },
    ],
  },
  {
    title: 'Ink',
    tokens: [
      { name: '--ink', label: 'Ink Primary' },
      { name: '--ink-secondary', label: 'Ink Secondary' },
      { name: '--ink-tertiary', label: 'Ink Tertiary' },
    ],
  },
  {
    title: 'Lavender',
    tokens: [
      { name: '--lavender', label: 'Lavender' },
      { name: '--lavender-tint', label: 'Lavender Tint' },
      { name: '--lavender-text', label: 'Lavender Text' },
    ],
  },
  {
    title: 'Semantic',
    tokens: [
      { name: '--destructive', label: 'Destructive' },
      { name: '--nightsky', label: 'Nightsky' },
    ],
  },
]

function ColorGrid() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 32 }}>
      {tokenGroups.map((group) => (
        <div key={group.title}>
          <h3 style={{ fontSize: 14, fontWeight: 500, marginBottom: 12, color: 'var(--ink)' }}>
            {group.title}
          </h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(120px, 1fr))', gap: 8 }}>
            {group.tokens.map((t) => (
              <div key={t.name} style={{ textAlign: 'center' }}>
                <div
                  style={{
                    width: '100%', height: 56, borderRadius: 12,
                    background: `var(${t.name})`,
                    border: '1px solid rgba(28,28,30,0.08)',
                    marginBottom: 6,
                  }}
                />
                <div style={{ fontSize: 11, fontWeight: 500, color: 'var(--ink)' }}>{t.label}</div>
                <div style={{ fontSize: 10, color: 'var(--ink-tertiary)', fontFamily: 'monospace' }}>{t.name}</div>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  )
}

const meta: Meta = {
  title: 'Foundation/Colors',
  component: ColorGrid,
}

export default meta
type Story = StoryObj

export const Palette: Story = {}
```

- [ ] **Step 4: Create Typography.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'

const styles = [
  { name: 'Display', size: 34, weight: 200, spacing: '-0.03em', color: 'var(--ink)' },
  { name: 'Title', size: 22, weight: 300, spacing: '-0.02em', color: 'var(--ink)' },
  { name: 'App Bar Title', size: 18, weight: 500, spacing: '-0.01em', color: 'var(--ink)' },
  { name: 'Headline', size: 17, weight: 500, spacing: '0', color: 'var(--ink)' },
  { name: 'Body', size: 15, weight: 400, spacing: '0', color: 'var(--ink-secondary)' },
  { name: 'Caption', size: 12, weight: 400, spacing: '0', color: 'var(--ink-tertiary)' },
  { name: 'Micro', size: 10, weight: 400, spacing: '0', color: 'var(--ink-tertiary)' },
]

function TypographyScale() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
      {styles.map((s) => (
        <div key={s.name} style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
          <div style={{ width: 120, fontSize: 11, color: 'var(--ink-tertiary)', fontFamily: 'monospace', flexShrink: 0 }}>
            {s.size}px / w{s.weight}
          </div>
          <div style={{ fontSize: s.size, fontWeight: s.weight, letterSpacing: s.spacing, color: s.color }}>
            {s.name} — 小肥路书
          </div>
        </div>
      ))}
    </div>
  )
}

const meta: Meta = {
  title: 'Foundation/Typography',
  component: TypographyScale,
}

export default meta
type Story = StoryObj

export const Scale: Story = {}
```

- [ ] **Step 5: Run Storybook to verify setup**

Run:
```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook && pnpm --filter @roadbook/ui dev
```

Expected: Storybook opens at http://localhost:6006 with Foundation/Colors and Foundation/Typography stories visible, warm canvas background with ambient orbs.

- [ ] **Step 6: Commit**

```bash
git add packages/roadbook-ui/.storybook packages/roadbook-ui/stories
git commit -m "feat(roadbook-ui): add Storybook with Colors and Typography foundation stories"
```

---

### Task 4: AmbientBg component

**Files:**
- Create: `packages/roadbook-ui/src/components/ambient-bg.tsx`
- Create: `packages/roadbook-ui/stories/base/AmbientBg.stories.tsx`

- [ ] **Step 1: Create ambient-bg.tsx**

```tsx
import React from 'react'
import { cn } from '@/lib/utils'

interface AmbientBgProps {
  className?: string
}

const orbs = [
  { color: 'rgba(245,210,170,0.18)', size: 350, top: '-5%', right: '-5%', delay: '0s' },
  { color: 'rgba(255,180,140,0.12)', size: 300, bottom: '5%', left: '-5%', delay: '-10s' },
  { color: 'rgba(245,224,176,0.13)', size: 260, bottom: '30%', right: '10%', delay: '-18s' },
]

export function AmbientBg({ className }: AmbientBgProps) {
  return (
    <div className={cn('fixed inset-0 z-0 overflow-hidden pointer-events-none', className)}>
      {orbs.map((orb, i) => (
        <div
          key={i}
          className="absolute rounded-full animate-drift"
          style={{
            width: orb.size,
            height: orb.size,
            background: orb.color,
            filter: 'blur(80px)',
            top: orb.top,
            right: orb.right,
            bottom: orb.bottom,
            left: orb.left,
            animationDelay: orb.delay,
          }}
        />
      ))}
    </div>
  )
}
```

- [ ] **Step 2: Create AmbientBg.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { AmbientBg } from '@/components/ambient-bg'

const meta: Meta<typeof AmbientBg> = {
  title: 'Base/AmbientBg',
  component: AmbientBg,
}

export default meta
type Story = StoryObj<typeof AmbientBg>

export const Default: Story = {
  render: () => (
    <div style={{ position: 'relative', height: 400, borderRadius: 20, overflow: 'hidden', background: 'var(--canvas)' }}>
      <AmbientBg />
      <div style={{ position: 'relative', zIndex: 1, padding: 40, fontSize: 34, fontWeight: 200 }}>
        小肥路书
      </div>
    </div>
  ),
}
```

- [ ] **Step 3: Verify in Storybook**

Run Storybook (if not running), navigate to Base/AmbientBg. Expected: warm canvas with 3 drifting blurred orbs.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-ui/src/components/ambient-bg.tsx packages/roadbook-ui/stories/base/AmbientBg.stories.tsx
git commit -m "feat(roadbook-ui): add AmbientBg component"
```

---

### Task 5: GlassCard component

**Files:**
- Create: `packages/roadbook-ui/src/components/glass-card.tsx`
- Create: `packages/roadbook-ui/stories/base/GlassCard.stories.tsx`

- [ ] **Step 1: Create glass-card.tsx**

```tsx
import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const glassCardVariants = cva(
  'relative overflow-hidden',
  {
    variants: {
      variant: {
        frost: [
          'bg-frost border border-frost-border',
          'backdrop-blur-[40px] backdrop-saturate-[1.4]',
          'shadow-[0_8px_32px_rgba(0,0,0,0.06),0_1px_2px_rgba(0,0,0,0.03)]',
        ],
        strong: [
          'bg-frost-strong border border-white/55',
          'backdrop-blur-[50px] backdrop-saturate-[1.8]',
          'shadow-[0_-8px_32px_rgba(0,0,0,0.06)]',
        ],
        dark: [
          'bg-nightsky border border-white/[0.08]',
          'backdrop-blur-[40px] backdrop-saturate-[1.4]',
          'shadow-[0_8px_32px_rgba(0,0,0,0.10)]',
        ],
      },
      radius: {
        card: 'rounded-card',
        'card-sm': 'rounded-card-sm',
        'card-inner': 'rounded-card-inner',
      },
    },
    defaultVariants: {
      variant: 'frost',
      radius: 'card',
    },
  }
)

interface GlassCardProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof glassCardVariants> {}

export function GlassCard({ variant, radius, className, children, ...props }: GlassCardProps) {
  return (
    <div className={cn(glassCardVariants({ variant, radius }), className)} {...props}>
      {/* Specular highlight */}
      <div
        className="absolute inset-0 rounded-[inherit] pointer-events-none"
        style={{
          background: variant === 'dark'
            ? 'linear-gradient(160deg, rgba(255,255,255,0.08) 0%, transparent 40%)'
            : 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)',
        }}
      />
      <div className="relative z-[1]">{children}</div>
    </div>
  )
}
```

- [ ] **Step 2: Create GlassCard.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { GlassCard } from '@/components/glass-card'

const meta: Meta<typeof GlassCard> = {
  title: 'Base/GlassCard',
  component: GlassCard,
  argTypes: {
    variant: { control: 'select', options: ['frost', 'strong', 'dark'] },
    radius: { control: 'select', options: ['card', 'card-sm', 'card-inner'] },
  },
}

export default meta
type Story = StoryObj<typeof GlassCard>

export const Frost: Story = {
  args: { variant: 'frost' },
  render: (args) => (
    <GlassCard {...args} className="p-card-pad" style={{ maxWidth: 320 }}>
      <div className="text-[16px] font-medium text-ink">东京自由行</div>
      <div className="text-[11px] text-ink-tertiary mt-1">04/10 — 04/17 · 7天</div>
    </GlassCard>
  ),
}

export const Strong: Story = {
  args: { variant: 'strong' },
  render: (args) => (
    <GlassCard {...args} className="p-card-pad" style={{ maxWidth: 320 }}>
      <div className="text-[17px] font-medium text-ink">Bottom Sheet Content</div>
      <div className="text-[13px] text-ink-secondary mt-2">Frost strong surface for sheets.</div>
    </GlassCard>
  ),
}

export const Dark: Story = {
  args: { variant: 'dark' },
  render: (args) => (
    <GlassCard {...args} className="p-card-pad" style={{ maxWidth: 320 }}>
      <div className="text-[16px] font-medium text-white">新宿格拉斯丽酒店</div>
      <div className="text-[11px] text-white/60 mt-1">东京都新宿区歌舞伎町</div>
    </GlassCard>
  ),
}

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-col gap-4" style={{ maxWidth: 320 }}>
      <GlassCard variant="frost" className="p-card-pad">
        <div className="text-[14px] font-medium">Frost (default)</div>
      </GlassCard>
      <GlassCard variant="strong" className="p-card-pad">
        <div className="text-[14px] font-medium">Strong</div>
      </GlassCard>
      <GlassCard variant="dark" className="p-card-pad">
        <div className="text-[14px] font-medium text-white">Dark</div>
      </GlassCard>
    </div>
  ),
}
```

- [ ] **Step 3: Verify in Storybook**

Navigate to Base/GlassCard. Expected: 3 card variants with glass blur, specular highlight, proper shadows. Dark variant has nightsky background with subtle white specular.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-ui/src/components/glass-card.tsx packages/roadbook-ui/stories/base/GlassCard.stories.tsx
git commit -m "feat(roadbook-ui): add GlassCard component with frost/strong/dark variants"
```

---

### Task 6: Button component

**Files:**
- Create: `packages/roadbook-ui/src/components/ui/button.tsx`
- Create: `packages/roadbook-ui/stories/base/Button.stories.tsx`

- [ ] **Step 1: Create button.tsx**

```tsx
import React from 'react'
import { Slot } from '@radix-ui/react-slot'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const buttonVariants = cva(
  'inline-flex items-center justify-content gap-1.5 font-normal transition-transform active:scale-[0.92] ease-spring duration-[400ms] cursor-pointer select-none',
  {
    variants: {
      variant: {
        'dark-pill': 'bg-dark text-white hover:bg-dark-hover rounded-pill text-[15px] px-5 h-11',
        coral: 'bg-coral text-white rounded-pill text-[15px] px-5 h-11 shadow-[0_2px_8px_rgba(255,107,61,0.25)]',
        glass: 'bg-frost text-ink backdrop-blur-[24px] backdrop-saturate-[1.4] border border-frost-border rounded-pill text-[15px] px-5 h-11',
        ghost: 'bg-transparent text-ink-secondary border border-[rgba(28,28,30,0.12)] rounded-pill text-[15px] px-5 h-11',
        'dark-circle': 'bg-dark text-white rounded-full w-9 h-9 p-0',
        'coral-circle': 'bg-coral text-white rounded-full w-9 h-9 p-0 shadow-[0_2px_8px_rgba(255,107,61,0.25)]',
      },
    },
    defaultVariants: {
      variant: 'dark-pill',
    },
  }
)

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

export function Button({ variant, className, asChild, ...props }: ButtonProps) {
  const Comp = asChild ? Slot : 'button'
  return <Comp className={cn(buttonVariants({ variant }), className)} {...props} />
}
```

- [ ] **Step 2: Create Button.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { Button } from '@/components/ui/button'

const meta: Meta<typeof Button> = {
  title: 'Base/Button',
  component: Button,
  argTypes: {
    variant: {
      control: 'select',
      options: ['dark-pill', 'coral', 'glass', 'ghost', 'dark-circle', 'coral-circle'],
    },
  },
}

export default meta
type Story = StoryObj<typeof Button>

export const DarkPill: Story = {
  args: { variant: 'dark-pill', children: '登录 →' },
}

export const Coral: Story = {
  args: { variant: 'coral', children: '导航前往' },
}

export const Glass: Story = {
  args: { variant: 'glass', children: 'Glass Button' },
}

export const Ghost: Story = {
  args: { variant: 'ghost', children: '添加分类' },
}

export const CircleButtons: Story = {
  render: () => (
    <div className="flex gap-3 items-center">
      <Button variant="dark-circle">‹</Button>
      <Button variant="dark-circle">＋</Button>
      <Button variant="coral-circle">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polygon points="3 11 22 2 13 21 11 13 3 11"/></svg>
      </Button>
    </div>
  ),
}

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap gap-3 items-center">
      <Button variant="dark-pill">Dark Pill →</Button>
      <Button variant="coral">Coral</Button>
      <Button variant="glass">Glass</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="dark-circle">‹</Button>
      <Button variant="coral-circle">⛩</Button>
    </div>
  ),
}
```

- [ ] **Step 3: Install @radix-ui/react-slot**

Run:
```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook && pnpm --filter @roadbook/ui add @radix-ui/react-slot
```

- [ ] **Step 4: Verify in Storybook**

Navigate to Base/Button. Expected: all 6 variants render correctly. Press interaction shows scale(0.92) spring bounce.

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-ui/src/components/ui/button.tsx packages/roadbook-ui/stories/base/Button.stories.tsx pnpm-lock.yaml
git commit -m "feat(roadbook-ui): add Button component with 6 Frosted Warmth variants"
```

---

### Task 7: Badge component

**Files:**
- Create: `packages/roadbook-ui/src/components/ui/badge.tsx`
- Create: `packages/roadbook-ui/stories/base/Badge.stories.tsx`

- [ ] **Step 1: Create badge.tsx**

```tsx
import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const badgeVariants = cva(
  'inline-flex items-center rounded-pill px-2 py-0.5 text-[10px] font-medium',
  {
    variants: {
      variant: {
        ongoing: 'bg-[var(--ongoing-bg)] text-[var(--ongoing-text)]',
        upcoming: 'bg-[var(--upcoming-bg)] text-[var(--upcoming-text)]',
        planning: 'bg-[rgba(28,28,30,0.06)] text-ink-secondary',
        ended: 'bg-[rgba(28,28,30,0.04)] text-ink-tertiary',
        city: 'bg-[rgba(28,28,30,0.05)] text-ink-secondary border border-[rgba(28,28,30,0.08)]',
        hotel: 'bg-lavender-tint text-lavender-text',
      },
    },
    defaultVariants: {
      variant: 'planning',
    },
  }
)

interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {}

export function Badge({ variant, className, ...props }: BadgeProps) {
  return <span className={cn(badgeVariants({ variant }), className)} {...props} />
}
```

- [ ] **Step 2: Create Badge.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { Badge } from '@/components/ui/badge'

const meta: Meta<typeof Badge> = {
  title: 'Base/Badge',
  component: Badge,
  argTypes: {
    variant: {
      control: 'select',
      options: ['ongoing', 'upcoming', 'planning', 'ended', 'city', 'hotel'],
    },
  },
}

export default meta
type Story = StoryObj<typeof Badge>

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap gap-2 items-center">
      <Badge variant="ongoing">旅行中</Badge>
      <Badge variant="upcoming">即将出发</Badge>
      <Badge variant="planning">规划中</Badge>
      <Badge variant="ended">已结束</Badge>
      <Badge variant="city">东京</Badge>
      <Badge variant="city">大阪</Badge>
      <Badge variant="hotel">住宿</Badge>
    </div>
  ),
}
```

- [ ] **Step 3: Verify in Storybook**

Navigate to Base/Badge. Expected: all 7 badges with correct colors and pill shape.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-ui/src/components/ui/badge.tsx packages/roadbook-ui/stories/base/Badge.stories.tsx
git commit -m "feat(roadbook-ui): add Badge component with status and city variants"
```

---

### Task 8: TimeBadge component

**Files:**
- Create: `packages/roadbook-ui/src/components/time-badge.tsx`
- Create: `packages/roadbook-ui/stories/base/TimeBadge.stories.tsx`

- [ ] **Step 1: Create time-badge.tsx**

```tsx
import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const timeBadgeVariants = cva(
  'inline-flex items-center gap-0.5 rounded-pill font-medium',
  {
    variants: {
      variant: {
        poi: 'bg-coral-tint text-[var(--ongoing-text)] text-[12px] px-2 py-0.5',
        hotel: 'bg-[rgba(140,92,246,0.15)] text-lavender-text text-[15px] px-[11px] py-1 tracking-tight',
        unplanned: 'bg-[rgba(28,28,30,0.05)] text-ink-tertiary text-[12px] px-2 py-0.5',
      },
    },
    defaultVariants: {
      variant: 'poi',
    },
  }
)

const CalendarIcon = ({ className }: { className?: string }) => (
  <svg
    width="11"
    height="11"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2.5"
    strokeLinecap="round"
    strokeLinejoin="round"
    className={cn('flex-shrink-0 opacity-70', className)}
  >
    <rect x="3" y="4" width="18" height="18" rx="2" />
    <line x1="16" y1="2" x2="16" y2="6" />
    <line x1="8" y1="2" x2="8" y2="6" />
    <line x1="3" y1="10" x2="21" y2="10" />
  </svg>
)

interface TimeBadgeProps
  extends Omit<React.HTMLAttributes<HTMLSpanElement>, 'children'>,
    VariantProps<typeof timeBadgeVariants> {
  time: string
  editable?: boolean
}

export function TimeBadge({ variant, time, editable = false, className, ...props }: TimeBadgeProps) {
  return (
    <span className={cn(timeBadgeVariants({ variant }), className)} {...props}>
      {time}
      {editable && <CalendarIcon />}
    </span>
  )
}
```

- [ ] **Step 2: Create TimeBadge.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { TimeBadge } from '@/components/time-badge'

const meta: Meta<typeof TimeBadge> = {
  title: 'Base/TimeBadge',
  component: TimeBadge,
  argTypes: {
    variant: { control: 'select', options: ['poi', 'hotel', 'unplanned'] },
    editable: { control: 'boolean' },
  },
}

export default meta
type Story = StoryObj<typeof TimeBadge>

export const POI: Story = {
  args: { variant: 'poi', time: '11:30', editable: true },
}

export const Hotel: Story = {
  args: { variant: 'hotel', time: '入住 15:00', editable: true },
}

export const Unplanned: Story = {
  args: { variant: 'unplanned', time: '待规划', editable: false },
}

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap gap-3 items-center">
      <TimeBadge variant="poi" time="01:00" editable />
      <TimeBadge variant="poi" time="11:30" editable />
      <TimeBadge variant="hotel" time="入住 02:00" editable />
      <TimeBadge variant="hotel" time="退房 11:00" editable />
      <TimeBadge variant="unplanned" time="待规划" />
    </div>
  ),
}
```

- [ ] **Step 3: Verify in Storybook**

Navigate to Base/TimeBadge. Expected: POI compact coral, Hotel large lavender, Unplanned neutral. Calendar icon shows when editable.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-ui/src/components/time-badge.tsx packages/roadbook-ui/stories/base/TimeBadge.stories.tsx
git commit -m "feat(roadbook-ui): add TimeBadge component with poi/hotel/unplanned variants"
```

---

### Task 9: Icon component + SVG data

**Files:**
- Create: `packages/roadbook-ui/src/components/icons.ts`
- Create: `packages/roadbook-ui/src/components/icon.tsx`
- Create: `packages/roadbook-ui/stories/base/Icon.stories.tsx`

- [ ] **Step 1: Create icons.ts (SVG path data)**

```ts
// Each icon is an array of SVG child elements as strings
// All icons use viewBox="0 0 24 24", stroke-width 1.8, round cap/join
export const iconPaths: Record<string, string> = {
  back: '<path d="M15 18l-6-6 6-6"/>',
  plus: '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>',
  close: '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>',
  'more-h': '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>',
  'more-v': '<circle cx="12" cy="5" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="12" cy="19" r="1"/>',
  search: '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>',
  'chevron-r': '<path d="M9 18l6-6-6-6"/>',
  'chevron-d': '<path d="M6 9l6 6 6-6"/>',
  navigate: '<polygon points="3 11 22 2 13 21 11 13 3 11"/>',
  pin: '<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/>',
  clock: '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>',
  calendar: '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>',
  list: '<line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/>',
  map: '<polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/>',
  timeline: '<line x1="7" y1="5" x2="7" y2="19"/><circle cx="7" cy="5" r="2"/><circle cx="7" cy="12" r="2"/><circle cx="7" cy="19" r="2"/><line x1="12" y1="5" x2="20" y2="5"/><line x1="12" y1="12" x2="18" y2="12"/><line x1="12" y1="19" x2="20" y2="19"/>',
  edit: '<path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>',
  copy: '<rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/>',
  trash: '<polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/>',
  upload: '<path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/>',
  image: '<rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>',
  link: '<path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/>',
  check: '<polyline points="20 6 9 17 4 12"/>',
  users: '<path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/>',
  user: '<path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/>',
  settings: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9c.26.46.4.99.4 1.51V21"/>',
  luggage: '<rect x="5" y="7" width="14" height="14" rx="2"/><path d="M8 7V5a2 2 0 012-2h4a2 2 0 012 2v2"/><line x1="12" y1="11" x2="12" y2="17"/>',
  'check-circle': '<path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>',
  circle: '<circle cx="12" cy="12" r="10"/>',
  info: '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>',
  globe: '<circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/>',
  moon: '<path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"/>',
  message: '<path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>',
  key: '<path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/>',
  folder: '<path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/>',
  camera: '<path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/><circle cx="12" cy="13" r="4"/>',
}
```

- [ ] **Step 2: Create icon.tsx**

```tsx
import React from 'react'
import { cn } from '@/lib/utils'
import { iconPaths } from './icons'

interface IconProps extends React.SVGAttributes<SVGSVGElement> {
  name: string
  size?: number
}

export function Icon({ name, size = 24, className, ...props }: IconProps) {
  const path = iconPaths[name]
  if (!path) return null

  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={cn('inline-block', className)}
      dangerouslySetInnerHTML={{ __html: path }}
      {...props}
    />
  )
}
```

- [ ] **Step 3: Create Icon.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { Icon } from '@/components/icon'
import { iconPaths } from '@/components/icons'

const meta: Meta<typeof Icon> = {
  title: 'Base/Icon',
  component: Icon,
  argTypes: {
    name: { control: 'select', options: Object.keys(iconPaths) },
    size: { control: { type: 'range', min: 16, max: 32, step: 2 } },
  },
}

export default meta
type Story = StoryObj<typeof Icon>

export const Single: Story = {
  args: { name: 'navigate', size: 24 },
}

export const AllIcons: Story = {
  render: () => (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(90px, 1fr))', gap: 8 }}>
      {Object.keys(iconPaths).map((name) => (
        <div
          key={name}
          style={{
            padding: '12px 8px',
            textAlign: 'center',
            background: 'var(--frost)',
            borderRadius: 12,
            border: '1px solid var(--frost-border)',
          }}
        >
          <Icon name={name} size={24} />
          <div style={{ fontSize: 10, color: 'var(--ink-secondary)', marginTop: 6 }}>{name}</div>
        </div>
      ))}
    </div>
  ),
}

export const Sizes: Story = {
  render: () => (
    <div className="flex gap-6 items-end">
      {[16, 18, 20, 24, 28].map((s) => (
        <div key={s} className="flex flex-col items-center gap-2">
          <Icon name="search" size={s} />
          <span className="text-[10px] text-ink-tertiary">{s}px</span>
        </div>
      ))}
    </div>
  ),
}
```

- [ ] **Step 4: Verify in Storybook**

Navigate to Base/Icon. Expected: AllIcons grid shows all ~30 icons on glass cards. Sizes story shows 5 sizes.

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-ui/src/components/icons.ts packages/roadbook-ui/src/components/icon.tsx packages/roadbook-ui/stories/base/Icon.stories.tsx
git commit -m "feat(roadbook-ui): add Icon component with full SVG icon set"
```

---

### Task 10: Skeleton component

**Files:**
- Create: `packages/roadbook-ui/src/components/skeleton.tsx`
- Create: `packages/roadbook-ui/stories/base/Skeleton.stories.tsx`

- [ ] **Step 1: Create skeleton.tsx**

```tsx
import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const skeletonVariants = cva(
  'animate-shimmer bg-[length:200%_100%]',
  {
    variants: {
      variant: {
        text: 'h-3 rounded-[6px]',
        avatar: 'rounded-full',
        image: 'rounded-card-inner',
        tag: 'rounded-pill h-5',
      },
    },
    defaultVariants: {
      variant: 'text',
    },
  }
)

interface SkeletonProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof skeletonVariants> {}

export function Skeleton({ variant, className, style, ...props }: SkeletonProps) {
  return (
    <div
      className={cn(skeletonVariants({ variant }), className)}
      style={{
        background: 'linear-gradient(120deg, var(--bone-base) 25%, var(--bone-shimmer) 50%, var(--bone-base) 75%)',
        backgroundSize: '200% 100%',
        ...style,
      }}
      {...props}
    />
  )
}
```

- [ ] **Step 2: Create Skeleton.stories.tsx**

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { Skeleton } from '@/components/skeleton'
import { GlassCard } from '@/components/glass-card'

const meta: Meta<typeof Skeleton> = {
  title: 'Base/Skeleton',
  component: Skeleton,
  argTypes: {
    variant: { control: 'select', options: ['text', 'avatar', 'image', 'tag'] },
  },
}

export default meta
type Story = StoryObj<typeof Skeleton>

export const Variants: Story = {
  render: () => (
    <div className="flex flex-col gap-4" style={{ maxWidth: 320 }}>
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">text</span>
        <Skeleton variant="text" className="w-[140px]" />
        <Skeleton variant="text" className="w-[100px]" />
      </div>
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">avatar</span>
        <Skeleton variant="avatar" className="w-11 h-11" />
      </div>
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">image</span>
        <Skeleton variant="image" className="w-[52px] h-[52px]" />
      </div>
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">tag</span>
        <Skeleton variant="tag" className="w-[48px]" />
      </div>
    </div>
  ),
}

export const TravelCardSkeleton: Story = {
  render: () => (
    <GlassCard className="p-card-pad" style={{ maxWidth: 320 }}>
      <div className="flex justify-between items-start mb-2">
        <Skeleton variant="text" className="w-[140px] h-4" />
        <Skeleton variant="tag" className="w-[52px]" />
      </div>
      <Skeleton variant="text" className="w-[100px] h-3 mb-3" />
      <div className="flex gap-1 mb-3">
        <Skeleton variant="tag" className="w-[48px]" />
        <Skeleton variant="tag" className="w-[48px]" />
      </div>
      <div className="border-t border-dashed border-[rgba(28,28,30,0.08)] pt-2">
        <div className="flex gap-1">
          <Skeleton variant="avatar" className="w-5 h-5" />
          <Skeleton variant="avatar" className="w-5 h-5" />
          <Skeleton variant="avatar" className="w-5 h-5" />
        </div>
      </div>
    </GlassCard>
  ),
}

export const ScheduleCardSkeleton: Story = {
  render: () => (
    <GlassCard className="p-3" style={{ maxWidth: 320 }}>
      <div className="flex gap-2.5">
        <Skeleton variant="image" className="w-12 h-12" />
        <div className="flex-1 flex flex-col gap-1.5">
          <Skeleton variant="tag" className="w-[40px]" />
          <Skeleton variant="text" className="w-[120px] h-4" />
          <Skeleton variant="text" className="w-[80px] h-3" />
        </div>
      </div>
    </GlassCard>
  ),
}
```

- [ ] **Step 3: Verify in Storybook**

Navigate to Base/Skeleton. Expected: warm-toned shimmer animation on all variants. TravelCard and ScheduleCard skeletons show realistic placeholder layouts inside glass cards.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-ui/src/components/skeleton.tsx packages/roadbook-ui/stories/base/Skeleton.stories.tsx
git commit -m "feat(roadbook-ui): add Skeleton component with warm shimmer animation"
```

---

### Task 11: Fix index.ts exports + final verification

**Files:**
- Modify: `packages/roadbook-ui/src/index.ts`

- [ ] **Step 1: Update index.ts with all exports**

```ts
// Foundation
export { AmbientBg } from './components/ambient-bg'
export { GlassCard } from './components/glass-card'

// Base UI
export { Button } from './components/ui/button'
export { Badge } from './components/ui/badge'

// Custom components
export { TimeBadge } from './components/time-badge'
export { Icon } from './components/icon'
export { iconPaths } from './components/icons'
export { Skeleton } from './components/skeleton'

// Utils
export { cn } from './lib/utils'
```

- [ ] **Step 2: Verify full Storybook**

Run:
```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook && pnpm --filter @roadbook/ui dev
```

Expected: All stories load without errors:
- Foundation/Colors, Foundation/Typography
- Base/AmbientBg, Base/GlassCard, Base/Button, Base/Badge, Base/TimeBadge, Base/Icon, Base/Skeleton

- [ ] **Step 3: Verify build**

Run:
```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook && pnpm --filter @roadbook/ui build
```

Expected: Vite builds without errors, output in `packages/roadbook-ui/dist/`.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-ui/src/index.ts
git commit -m "feat(roadbook-ui): finalize Phase 1 exports and verify build"
```

---

### Task 12: Add dev script to root package.json

**Files:**
- Modify: `packages/roadbook/package.json` (root)

- [ ] **Step 1: Add dev-ui script**

Add to root `package.json` scripts:

```json
"dev-ui": "pnpm -F @roadbook/ui dev"
```

- [ ] **Step 2: Commit**

```bash
git add package.json
git commit -m "chore: add dev-ui script to root package.json"
```
