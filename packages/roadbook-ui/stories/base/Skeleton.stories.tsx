import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
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
    <div className="flex flex-col gap-4 max-w-xs">
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
    <GlassCard className="p-card-pad max-w-xs">
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
    <GlassCard className="p-3 max-w-xs">
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
