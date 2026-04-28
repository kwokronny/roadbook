import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { TimeBadge } from '@/components/time-badge'
import { Icon } from '@/components/icon'

/* ── Compact Schedule Card ── */
function ScheduleCard({
  variant = 'poi',
  emoji,
  time,
  timeVariant = 'poi',
  title,
  address,
  hasNav = true,
  hasLower = false,
  photos = 0,
  note,
  dianping,
}: {
  variant?: 'poi' | 'hotel' | 'neutral'
  emoji: string
  time: string
  timeVariant?: 'poi' | 'hotel' | 'unplanned'
  title: string
  address?: string
  hasNav?: boolean
  hasLower?: boolean
  photos?: number
  note?: string
  dianping?: string
}) {
  const isDark = variant === 'hotel'
  const coverBg = {
    poi: 'bg-[rgba(255,107,61,0.08)] border border-[rgba(255,107,61,0.12)]',
    hotel: 'bg-lavender-tint border border-[rgba(140,92,246,0.15)]',
    neutral: 'bg-[rgba(28,28,30,0.04)] border border-[rgba(28,28,30,0.06)]',
  }

  return (
    <div className="mx-4 mb-3">
      {/* Upper: main card */}
      <GlassCard
        variant={isDark ? 'dark' : 'frost'}
        className={`p-3 ${hasLower ? '!rounded-b-card-inner !mb-0' : ''}`}
      >
        <div className="flex gap-2.5 items-start">
          {/* Cover */}
          <div className={`w-12 h-12 rounded-[12px] flex items-center justify-center text-[22px] flex-shrink-0 ${coverBg[variant]}`}>
            {emoji}
          </div>
          {/* Body */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5">
              <TimeBadge variant={timeVariant} time={time} editable={timeVariant !== 'unplanned'} />
            </div>
            <div className="flex items-start gap-2 mt-1">
              <div className="flex-1 min-w-0">
                <div className={`text-[16px] font-medium leading-tight line-clamp-2 ${isDark ? 'text-white' : 'text-ink'}`}>
                  {title}
                </div>
                {address && (
                  <div className={`text-[11px] truncate mt-0.5 ${isDark ? 'text-[rgba(255,255,255,0.55)]' : 'text-ink-tertiary'}`}>
                    {address}
                  </div>
                )}
              </div>
              {/* Nav button — compact circle */}
              {hasNav && (
                <div className="w-7 h-7 rounded-full bg-coral flex items-center justify-center flex-shrink-0 shadow-[0_2px_6px_rgba(255,107,61,0.25)] mt-0.5">
                  <Icon name="navigate" size={14} className="text-white" />
                </div>
              )}
            </div>
          </div>
        </div>
        {/* More button */}
        <div className={`absolute top-2.5 right-2.5 w-7 h-7 rounded-full flex items-center justify-center z-[2] ${
          isDark ? 'bg-[rgba(255,255,255,0.12)] text-[rgba(255,255,255,0.60)]' : 'bg-[rgba(28,28,30,0.05)] text-ink-tertiary'
        }`}>
          <Icon name="more-h" size={14} />
        </div>
      </GlassCard>

      {/* Lower: notes/photos */}
      {hasLower && (
        <div className={`py-3 px-3.5 rounded-t-[10px] rounded-b-[18px] ${
          isDark ? 'bg-[rgba(20,30,48,0.60)]' : 'bg-[rgba(28,28,30,0.035)]'
        }`}>
          {photos > 0 && (
            <div className="flex gap-1 mb-2">
              {Array.from({ length: photos }).map((_, i) => (
                <div key={i} className={`w-9 h-9 rounded-lg ${isDark ? 'bg-[rgba(255,255,255,0.08)]' : 'bg-[rgba(28,28,30,0.05)]'}`} />
              ))}
            </div>
          )}
          {note && (
            <div className={`text-[11px] leading-[1.5] line-clamp-2 ${isDark ? 'text-[rgba(255,255,255,0.55)]' : 'text-ink-secondary'}`}>
              {note}
            </div>
          )}
          {dianping && (
            <div className={`text-[10px] mt-1.5 ${isDark ? 'text-[rgba(255,255,255,0.35)]' : 'text-ink-tertiary'}`}>
              {dianping}
            </div>
          )}
        </div>
      )}
    </div>
  )
}

/* ── Luggage Entry ── */
function LuggageEntry() {
  return (
    <div className="mx-4 mb-2.5 relative z-[1]">
      <div className="flex items-center gap-2.5 py-2.5 px-3.5 rounded-card-sm bg-[rgba(255,255,255,0.48)] backdrop-blur-[40px] border border-[rgba(255,255,255,0.60)] relative overflow-hidden">
        <div className="absolute inset-0 rounded-[inherit] bg-gradient-to-br from-[rgba(255,255,255,0.30)] to-transparent pointer-events-none" />
        <div className="w-9 h-9 rounded-[10px] bg-[rgba(255,107,61,0.08)] border border-[rgba(255,107,61,0.12)] flex items-center justify-center text-[18px] flex-shrink-0 relative z-[1]">🧳</div>
        <div className="flex-1 relative z-[1]">
          <div className="text-[13px] font-medium text-ink">出发行李清单</div>
          <div className="text-[10px] text-ink-tertiary mt-px">3/12 已准备</div>
        </div>
        <div className="relative z-[1] flex items-center gap-1.5">
          <div className="w-12 h-1 rounded-sm bg-[rgba(28,28,30,0.06)] overflow-hidden">
            <div className="w-1/4 h-full rounded-sm bg-coral" />
          </div>
          <span className="text-[14px] text-ink-tertiary">›</span>
        </div>
      </div>
    </div>
  )
}

/* ── Optimized Screen ── */
function TravelDetailOptimizedScreen() {
  return (
    <PhoneFrame>
      <div className="absolute w-[260px] h-[260px] rounded-full blur-[50px] bg-[rgba(255,107,61,0.10)] top-[25%] -right-[18%]" />
      <div className="absolute w-[180px] h-[180px] rounded-full blur-[50px] bg-[rgba(245,210,170,0.12)] -top-[5%] -left-[8%]" />

      {/* App bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[14px] flex-shrink-0">‹</div>
        <div className="flex-1 min-w-0">
          <div className="text-[16px] font-medium text-ink">东京自由行</div>
          <div className="text-[11px] text-ink-tertiary">东京 · 大阪</div>
        </div>
        <div className="flex bg-frost backdrop-blur-[24px] border border-frost-border rounded-pill p-[3px]">
          <div className="py-[5px] px-2.5 rounded-pill bg-dark"><Icon name="list" size={16} className="text-white" /></div>
          <div className="py-[5px] px-2.5 rounded-pill text-ink-tertiary"><Icon name="map" size={16} /></div>
        </div>
        <div className="w-8 h-8 rounded-full bg-dark flex items-center justify-center flex-shrink-0">
          <Icon name="more-v" size={16} className="text-white" />
        </div>
      </div>

      {/* Day bar */}
      <div className="flex items-center gap-0.5 px-4 py-1.5 relative z-[1] overflow-x-auto">
        {[
          { day: 'Day 1', wd: '周四', on: true },
          { day: 'Day 2', wd: '周五', on: false },
          { day: 'Day 3', wd: '周六', on: false },
          { day: 'Day 4', wd: '周日', on: false },
          { day: 'Day 5', wd: '周一', on: false },
        ].map(d => (
          <div key={d.day} className={`py-1.5 px-3.5 rounded-pill flex flex-col items-center border flex-shrink-0 ${
            d.on ? 'bg-[rgba(255,255,255,0.55)] border-[rgba(255,255,255,0.70)] shadow-[0_2px_8px_rgba(0,0,0,0.04)] backdrop-blur-[16px]' : 'border-transparent'
          }`}>
            <span className={`text-[13px] font-medium ${d.on ? 'text-coral' : 'text-ink-tertiary'}`}>{d.day}</span>
            <span className={`text-[9px] mt-px ${d.on ? 'text-coral' : 'text-ink-tertiary'}`}>{d.wd}</span>
          </div>
        ))}
        <div className="flex-shrink-0 w-6 h-6 flex items-center justify-center text-[14px] text-ink-tertiary">›</div>
      </div>

      {/* Luggage entry */}
      <LuggageEntry />

      {/* Schedule Cards — optimized compact layout */}
      <ScheduleCard
        variant="hotel"
        emoji="🏨"
        time="入住 15:00"
        timeVariant="hotel"
        title="新宿格拉斯丽酒店"
        address="东京都新宿区歌舞伎町"
        hasLower
        photos={2}
        note="前台可寄存行李，哥斯拉房间在8楼，窗户能看到哥斯拉头部"
      />

      <ScheduleCard
        variant="poi"
        emoji="🍜"
        time="11:30"
        timeVariant="poi"
        title="一兰拉面 新宿中央东口店"
        address="东京都新宿区新宿3-34-11"
        hasLower
        note="记得提前在机器点餐，选硬面，汤头选浓厚"
        dianping="大众点评 · ★★★★★ · ¥60/人"
      />

      <ScheduleCard
        variant="poi"
        emoji="⛩"
        time="14:00"
        timeVariant="poi"
        title="明治神宫"
        address="东京都涩谷区代代木神园町"
        hasLower
        photos={3}
        note="值得绕到本殿后面的御苑散步，入口需要500日元，秋天红叶超美"
      />

      <ScheduleCard
        variant="neutral"
        emoji="🛍"
        time="待规划"
        timeVariant="unplanned"
        title="涩谷 Scramble Square"
        address="东京都涩谷区"
        hasNav={false}
      />

      <ScheduleCard
        variant="poi"
        emoji="🎡"
        time="17:00"
        timeVariant="poi"
        title="台场海滨公园"
        address="东京都港区台场1丁目"
      />
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/TravelDetail Optimized',
  parameters: { layout: 'centered', backgrounds: { default: 'canvas' } },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <TravelDetailOptimizedScreen />,
}

export const Comparison: Story = {
  render: () => (
    <div className="flex gap-6 items-start">
      <div>
        <div className="text-center text-[12px] text-ink-tertiary mb-3 font-medium">Optimized</div>
        <TravelDetailOptimizedScreen />
      </div>
    </div>
  ),
}
