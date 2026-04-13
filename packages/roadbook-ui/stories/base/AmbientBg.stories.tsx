import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
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
