import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { TimeBadge } from '@/components/time-badge'
import { Icon } from '@/components/icon'

/* ── Checkbox ── */
function Checkbox({ checked }: { checked: boolean }) {
  return (
    <div
      className={`w-5 h-5 rounded-md flex items-center justify-center flex-shrink-0 ${
        checked
          ? 'bg-coral text-white shadow-[0_2px_6px_rgba(255,107,61,0.25)]'
          : 'bg-[rgba(28,28,30,0.06)] border border-[rgba(28,28,30,0.10)]'
      }`}
    >
      {checked && <Icon name="check" size={12} />}
    </div>
  )
}

/* ── Schedule Cover ── */
function ScheduleCover({ emoji, type }: { emoji: string; type: 'poi' | 'hotel' | 'neutral' }) {
  const bgMap = {
    poi: 'bg-[rgba(255,107,61,0.08)] border border-[rgba(255,107,61,0.12)]',
    hotel: 'bg-lavender-tint border border-[rgba(140,92,246,0.15)]',
    neutral: 'bg-[rgba(28,28,30,0.04)] border border-[rgba(28,28,30,0.06)]',
  }
  return (
    <div className={`w-12 h-12 rounded-[12px] flex items-center justify-center text-[22px] flex-shrink-0 ${bgMap[type]}`}>
      {emoji}
    </div>
  )
}

/* ── Selectable Schedule Card ── */
interface SelectableCardProps {
  emoji: string
  coverType: 'poi' | 'hotel' | 'neutral'
  timeBadgeVariant: 'poi' | 'hotel' | 'unplanned'
  time: string
  name: string
  address: string
  checked: boolean
  variant?: 'frost' | 'dark'
}

function SelectableCard({ emoji, coverType, timeBadgeVariant, time, name, address, checked, variant = 'frost' }: SelectableCardProps) {
  const isDark = variant === 'dark'
  return (
    <GlassCard variant={variant} className="mx-4 mb-2.5 p-3">
      <div className="flex gap-2.5 items-start">
        {/* Checkbox */}
        <div className="flex items-center pt-3">
          <Checkbox checked={checked} />
        </div>
        {/* Cover */}
        <ScheduleCover emoji={emoji} type={coverType} />
        {/* Content */}
        <div className="flex-1 min-w-0">
          <TimeBadge variant={timeBadgeVariant} time={time} />
          <div className={`text-[17px] font-medium mb-0.5 line-clamp-2 mt-1 ${isDark ? 'text-white' : 'text-ink'}`}>
            {name}
          </div>
          <div className={`text-[11px] truncate ${isDark ? 'text-[rgba(255,255,255,0.60)]' : 'text-ink-tertiary'}`}>
            {address}
          </div>
        </div>
      </div>
    </GlassCard>
  )
}

/* ── Screen ── */
function MultiSelectScreen() {
  return (
    <PhoneFrame>
      {/* Orbs */}
      <div className="absolute w-[260px] h-[260px] rounded-full blur-[50px] bg-[rgba(255,107,61,0.10)] top-[25%] -right-[18%]" />
      <div className="absolute w-[180px] h-[180px] rounded-full blur-[50px] bg-[rgba(245,210,170,0.12)] -top-[5%] -left-[8%]" />

      {/* App bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
        {/* Back */}
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[14px] flex-shrink-0">
          &#x2039;
        </div>
        {/* Title */}
        <div className="flex-1 min-w-0">
          <div className="text-[16px] font-medium text-ink">东京自由行</div>
          <div className="text-[11px] text-ink-tertiary">东京 &middot; 大阪</div>
        </div>
        {/* Pill toggle – list active */}
        <div className="flex bg-frost backdrop-blur-[24px] border border-frost-border rounded-pill p-[3px]">
          <div className="py-[5px] px-2.5 rounded-pill bg-dark text-white text-[13px] flex items-center">
            <Icon name="list" size={16} className="text-white" />
          </div>
          <div className="py-[5px] px-2.5 rounded-pill text-[13px] text-ink-tertiary flex items-center">
            <Icon name="map" size={16} />
          </div>
        </div>
        {/* More */}
        <div className="w-8 h-8 rounded-full bg-dark flex items-center justify-center flex-shrink-0">
          <Icon name="more-v" size={16} className="text-white" />
        </div>
      </div>

      {/* Selection toolbar */}
      <div className="mx-4 mb-2.5 mt-1 relative z-[1]">
        <GlassCard variant="frost" radius="card-inner" className="px-3 py-2.5 flex items-center gap-2">
          {/* Checkmark + count */}
          <div className="flex items-center gap-1.5 text-coral">
            <Icon name="check-circle" size={16} />
            <span className="text-[13px] font-medium">已选 2 项</span>
          </div>
          {/* Spacer */}
          <div className="flex-1" />
          {/* Move button */}
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="folder" size={15} className="text-ink-secondary" />
          </div>
          {/* Delete button */}
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="trash" size={15} className="text-ink-secondary" />
          </div>
          {/* Close button */}
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="close" size={15} className="text-ink-secondary" />
          </div>
        </GlassCard>
      </div>

      {/* Schedule cards with checkboxes */}
      <SelectableCard
        emoji="🏨"
        coverType="hotel"
        timeBadgeVariant="hotel"
        time="入住 15:00"
        name="新宿格拉斯丽酒店"
        address="东京都新宿区歌舞伎町"
        checked={true}
        variant="dark"
      />
      <SelectableCard
        emoji="🍜"
        coverType="poi"
        timeBadgeVariant="poi"
        time="11:30"
        name="一兰拉面"
        address="东京都新宿区新宿3-34-11"
        checked={true}
      />
      <SelectableCard
        emoji="⛩"
        coverType="poi"
        timeBadgeVariant="poi"
        time="14:00"
        name="明治神宫"
        address="东京都涩谷区代代木神园町"
        checked={false}
      />
      <SelectableCard
        emoji="🛍"
        coverType="neutral"
        timeBadgeVariant="unplanned"
        time="待规划"
        name="涩谷 Scramble Square"
        address="东京都涩谷区"
        checked={false}
      />
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/MultiSelect',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <MultiSelectScreen />,
}
