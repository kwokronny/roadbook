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
