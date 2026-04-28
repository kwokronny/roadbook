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
