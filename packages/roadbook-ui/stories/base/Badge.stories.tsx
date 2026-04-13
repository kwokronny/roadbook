import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { Badge } from '@/components/ui/badge'

const meta: Meta<typeof Badge> = {
  title: 'Base/Badge',
  component: Badge,
  argTypes: {
    variant: { control: 'select', options: ['ongoing', 'upcoming', 'planning', 'ended', 'city', 'hotel'] },
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
