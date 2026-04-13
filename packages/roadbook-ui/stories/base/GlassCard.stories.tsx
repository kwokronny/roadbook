import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
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
  render: () => (
    <GlassCard variant="frost" className="p-card-pad max-w-xs">
      <div className="text-[16px] font-medium text-ink">东京自由行</div>
      <div className="text-[11px] text-ink-tertiary mt-1">04/10 — 04/17 · 7天</div>
    </GlassCard>
  ),
}

export const Strong: Story = {
  render: () => (
    <GlassCard variant="strong" className="p-card-pad max-w-xs">
      <div className="text-[17px] font-medium text-ink">Bottom Sheet Content</div>
      <div className="text-[13px] text-ink-secondary mt-2">Frost strong surface for sheets.</div>
    </GlassCard>
  ),
}

export const Dark: Story = {
  render: () => (
    <GlassCard variant="dark" className="p-card-pad max-w-xs">
      <div className="text-[16px] font-medium text-white">新宿格拉斯丽酒店</div>
      <div className="text-[11px] text-white/60 mt-1">东京都新宿区歌舞伎町</div>
    </GlassCard>
  ),
}

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-col gap-4 max-w-xs">
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
