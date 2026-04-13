import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { TimeBadge } from '@/components/time-badge'
import { Icon } from '@/components/icon'

/* ── More Button ── */
function MoreButton({ dark }: { dark?: boolean }) {
  return (
    <div
      className={`absolute top-2.5 right-2.5 w-8 h-8 rounded-full flex items-center justify-center z-[2] ${
        dark
          ? 'bg-[rgba(255,255,255,0.15)] text-[rgba(255,255,255,0.70)]'
          : 'bg-[rgba(28,28,30,0.06)] text-ink-tertiary'
      }`}
    >
      <Icon name="more-h" size={16} />
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

/* ── Nav Button ── */
function NavButton() {
  return (
    <div className="inline-flex items-center gap-[5px] py-1.5 px-[14px] rounded-pill bg-coral text-white text-[12px] mt-2 relative z-[1] shadow-[0_2px_8px_rgba(255,107,61,0.25)]">
      <Icon name="navigate" size={14} />
      导航前往
    </div>
  )
}

/* ── Lower Section ── */
function LowerSection({ dark, photos, note }: { dark?: boolean; photos?: number; note: string }) {
  return (
    <div
      className={`mx-4 mb-3.5 py-4 px-[18px] rounded-t-card-inner rounded-b-[20px] relative z-[1] ${
        dark ? 'bg-[rgba(20,30,48,0.65)]' : 'bg-[rgba(28,28,30,0.04)]'
      }`}
    >
      {photos && photos > 0 && (
        <div className="flex gap-1 mb-1.5">
          {Array.from({ length: photos }).map((_, i) => (
            <div
              key={i}
              className={`w-10 h-10 rounded-lg ${dark ? 'bg-[rgba(255,255,255,0.10)]' : 'bg-[rgba(28,28,30,0.05)]'}`}
            />
          ))}
        </div>
      )}
      <div
        className={`text-[12px] leading-relaxed line-clamp-2 ${
          dark ? 'text-[rgba(255,255,255,0.60)]' : 'text-ink-secondary'
        }`}
      >
        {note}
      </div>
    </div>
  )
}

/* ── Screen ── */
function TravelDetailScreen() {
  return (
    <PhoneFrame>
      {/* Shift orbs for detail screen */}
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
        {/* Pill toggle */}
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

      {/* Day bar */}
      <div className="flex items-center gap-0.5 px-4 py-1.5 relative z-[1] overflow-x-auto scrollbar-none">
        {[
          { day: 'Day 1', weekday: '周四', active: true },
          { day: 'Day 2', weekday: '周五', active: false },
          { day: 'Day 3', weekday: '周六', active: false },
          { day: 'Day 4', weekday: '周日', active: false },
          { day: 'Day 5', weekday: '周一', active: false },
        ].map((d) => (
          <div
            key={d.day}
            className={`py-1.5 px-3.5 rounded-pill flex flex-col items-center border flex-shrink-0 ${
              d.active
                ? 'bg-[rgba(255,255,255,0.55)] border-[rgba(255,255,255,0.70)] shadow-[0_2px_8px_rgba(0,0,0,0.04)] backdrop-blur-[16px]'
                : 'border-transparent'
            }`}
          >
            <span className={`text-[13px] font-medium ${d.active ? 'text-coral' : 'text-ink-tertiary'}`}>
              {d.day}
            </span>
            <span className={`text-[9px] mt-px ${d.active ? 'text-coral' : 'text-ink-tertiary'}`}>
              {d.weekday}
            </span>
          </div>
        ))}
        <div className="flex-shrink-0 w-6 h-6 flex items-center justify-center text-[14px] text-ink-tertiary">
          &#x203A;
        </div>
      </div>

      {/* ── Schedule Card 1: Hotel (dark, upper + lower) ── */}
      <GlassCard
        variant="dark"
        className="mx-4 !mb-0 p-3 !rounded-t-card !rounded-b-card-inner"
      >
        <div className="flex gap-2.5 items-start">
          <ScheduleCover emoji="🏨" type="hotel" />
          <div className="flex-1 min-w-0">
            <TimeBadge variant="hotel" time="入住 15:00" editable />
            <div className="text-[17px] font-medium text-white mb-0.5 line-clamp-2 mt-1">
              新宿格拉斯丽酒店
            </div>
            <div className="text-[11px] text-[rgba(255,255,255,0.60)] truncate">
              东京都新宿区歌舞伎町
            </div>
            <NavButton />
          </div>
        </div>
        <MoreButton dark />
      </GlassCard>
      <LowerSection dark photos={2} note="前台可寄存行李，哥斯拉房间在8楼" />

      {/* ── Schedule Card 2: POI (glass, upper + lower, notes only) ── */}
      <GlassCard
        variant="frost"
        className="mx-4 !mb-0 p-3 !rounded-t-card !rounded-b-card-inner"
      >
        <div className="flex gap-2.5 items-start">
          <ScheduleCover emoji="🍜" type="poi" />
          <div className="flex-1 min-w-0">
            <TimeBadge variant="poi" time="11:30" editable />
            <div className="text-[17px] font-medium text-ink mb-0.5 line-clamp-2 mt-1">
              一兰拉面 新宿中央东口店
            </div>
            <div className="text-[11px] text-ink-tertiary truncate">
              东京都新宿区新宿3-34-11
            </div>
            <NavButton />
          </div>
        </div>
        <MoreButton />
      </GlassCard>
      <LowerSection note="记得提前在机器点餐，选硬面，汤头选浓厚" />

      {/* ── Schedule Card 3: POI (glass, upper + lower, photos + notes) ── */}
      <GlassCard
        variant="frost"
        className="mx-4 !mb-0 p-3 !rounded-t-card !rounded-b-card-inner"
      >
        <div className="flex gap-2.5 items-start">
          <ScheduleCover emoji="⛩" type="poi" />
          <div className="flex-1 min-w-0">
            <TimeBadge variant="poi" time="14:00" editable />
            <div className="text-[17px] font-medium text-ink mb-0.5 line-clamp-2 mt-1">
              明治神宫
            </div>
            <div className="text-[11px] text-ink-tertiary truncate">
              东京都涩谷区代代木神园町
            </div>
            <NavButton />
          </div>
        </div>
        <MoreButton />
      </GlassCard>
      <LowerSection photos={3} note="值得绕到本殿后面的御苑散步，入口需要500日元" />

      {/* ── Schedule Card 4: Unscheduled (glass, no lower) ── */}
      <GlassCard variant="frost" className="mx-4 mb-3.5 p-3">
        <div className="flex gap-2.5 items-start">
          <ScheduleCover emoji="🛍" type="neutral" />
          <div className="flex-1 min-w-0">
            <TimeBadge variant="unplanned" time="待规划" />
            <div className="text-[17px] font-medium text-ink mb-0.5 line-clamp-2 mt-1">
              涩谷 Scramble Square
            </div>
            <div className="text-[11px] text-ink-tertiary truncate">
              东京都涩谷区
            </div>
          </div>
        </div>
        <MoreButton />
      </GlassCard>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/TravelDetail',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <TravelDetailScreen />,
}
