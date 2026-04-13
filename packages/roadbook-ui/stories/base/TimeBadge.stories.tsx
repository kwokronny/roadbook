import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
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

export const POI: Story = { args: { variant: 'poi', time: '11:30', editable: true } }
export const Hotel: Story = { args: { variant: 'hotel', time: '入住 15:00', editable: true } }
export const Unplanned: Story = { args: { variant: 'unplanned', time: '待规划' } }

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
