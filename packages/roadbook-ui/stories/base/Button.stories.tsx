import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
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
