import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
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

export const Single: Story = { args: { name: 'navigate', size: 24 } }

export const AllIcons: Story = {
  render: () => (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(90px, 1fr))', gap: 8 }}>
      {Object.keys(iconPaths).map((name) => (
        <div key={name} style={{ padding: '12px 8px', textAlign: 'center', background: 'var(--frost)', borderRadius: 12, border: '1px solid var(--frost-border)' }}>
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
