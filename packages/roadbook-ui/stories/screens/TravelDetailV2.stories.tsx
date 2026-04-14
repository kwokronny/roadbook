import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { TimeBadge } from '@/components/time-badge'
import { Icon } from '@/components/icon'

/* ═══ Schedule Card ═══ */
function ScheduleCard({
  variant = 'poi',
  emoji,
  time,
  timeVariant = 'poi',
  title,
  address,
  hasNav = true,
  photos,
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
  photos?: number
  note?: string
  dianping?: string
}) {
  const isDark = variant === 'hotel'
  const hasLower = !!(note || photos)

  const coverColors: Record<string, React.CSSProperties> = {
    poi: { background: 'rgba(255,107,61,0.08)', border: '1px solid rgba(255,107,61,0.12)' },
    hotel: { background: 'rgba(140,92,246,0.10)', border: '1px solid rgba(140,92,246,0.15)' },
    neutral: { background: 'rgba(28,28,30,0.04)', border: '1px solid rgba(28,28,30,0.06)' },
  }

  return (
    <div className="mx-4 mb-3 relative z-[1]">
      {/* ── Upper Card ── */}
      <div
        className="relative p-3"
        style={{
          background: isDark ? 'rgba(140,92,246,0.08)' : 'rgba(255,255,255,0.52)',
          backdropFilter: 'blur(40px) saturate(1.4)',
          WebkitBackdropFilter: 'blur(40px) saturate(1.4)',
          border: isDark ? '1px solid rgba(140,92,246,0.15)' : '1px solid rgba(255,255,255,0.65)',
          borderRadius: hasLower ? '24px 24px 0 0' : '24px',
          boxShadow: '0 8px 32px rgba(0,0,0,0.06)',
        }}
      >
        {/* Specular */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            borderRadius: 'inherit',
            background: 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)',
          }}
        />

        {/* Content */}
        <div className="flex gap-2.5 items-start relative z-[1]">
          {/* Cover */}
          <div
            className="w-12 h-12 flex items-center justify-center text-[22px] flex-shrink-0"
            style={{ borderRadius: 12, ...coverColors[variant] }}
          >
            {emoji}
          </div>

          {/* Body */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between">
              <TimeBadge variant={timeVariant} time={time} editable={timeVariant !== 'unplanned'} />
              {/* More — borderless icon */}
              <Icon name="more-h" size={16} style={{ color: isDark ? '#8C5CF6' : 'rgba(28,28,30,0.28)' }} />
            </div>
            <div
              className="text-[16px] font-medium leading-snug line-clamp-2 mt-1"
              style={{ color: isDark ? '#6D3FC0' : undefined }}
            >
              {title}
            </div>
            {address && (
              <div
                className="text-[11px] truncate mt-0.5"
                style={{ color: isDark ? 'rgba(140,92,246,0.50)' : undefined }}
              >
                {!isDark && <span className="text-ink-tertiary">{address}</span>}
                {isDark && address}
              </div>
            )}
          </div>
        </div>

        {/* Nav button — full width at bottom for easy thumb reach */}
        {hasNav && (
          <div
            className="flex items-center justify-center gap-1.5 mt-2.5 relative z-[1]"
            style={{
              height: 34,
              borderRadius: 100,
              background: 'rgba(255,255,255,0.52)',
              backdropFilter: 'blur(24px) saturate(1.4)',
              WebkitBackdropFilter: 'blur(24px) saturate(1.4)',
              color: isDark ? '#8C5CF6' : '#FF6B3D',
              fontSize: 12,
              fontWeight: 500,
              border: '1px solid rgba(255,255,255,0.65)',
            }}
          >
            <Icon name="navigate" size={13} />
            <span>导航前往</span>
          </div>
        )}
      </div>

      {/* ── Lower Card ── */}
      {hasLower && (
        <div
          className="px-3.5 pt-3 pb-6"
          style={{
            background: isDark
              ? 'linear-gradient(180deg, rgba(140,92,246,0.055) 0%, rgba(140,92,246,0.015) 100%)'
              : 'linear-gradient(180deg, rgba(255,243,196,0.065) 0%, rgba(255,243,196,0.025) 100%)',
            borderRadius: '0 0 20px 20px',
          }}
        >
          {photos && photos > 0 && (
            <div className="flex gap-1 mb-2">
              {Array.from({ length: photos }).map((_, i) => (
                <div
                  key={i}
                  className="w-9 h-9"
                  style={{
                    borderRadius: 8,
                    background: isDark ? 'rgba(140,92,246,0.08)' : 'rgba(28,28,30,0.05)',
                  }}
                />
              ))}
            </div>
          )}
          {note && (
            <div
              className="text-[11px] leading-relaxed line-clamp-2"
              style={{ color: isDark ? 'rgba(140,92,246,0.45)' : 'rgba(28,28,30,0.50)' }}
            >
              {note}
            </div>
          )}
          {dianping && (
            <div
              className="text-[10px] mt-1"
              style={{ color: isDark ? 'rgba(140,92,246,0.35)' : 'rgba(28,28,30,0.28)' }}
            >
              {dianping}
            </div>
          )}
        </div>
      )}
    </div>
  )
}

/* ═══ Luggage Entry ═══ */
function LuggageEntry() {
  return (
    <div className="mx-4 mb-2 relative z-[1]">
      <div
        className="flex items-center gap-2.5 py-2.5 px-3 relative overflow-hidden"
        style={{
          background: 'rgba(255,255,255,0.48)',
          backdropFilter: 'blur(40px) saturate(1.4)',
          WebkitBackdropFilter: 'blur(40px) saturate(1.4)',
          border: '1px solid rgba(255,255,255,0.60)',
          borderRadius: 16,
        }}
      >
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            borderRadius: 'inherit',
            background: 'linear-gradient(160deg, rgba(255,255,255,0.30) 0%, transparent 40%)',
          }}
        />
        <div
          className="w-9 h-9 flex items-center justify-center text-[18px] flex-shrink-0 relative z-[1]"
          style={{ borderRadius: 10, background: 'rgba(255,107,61,0.08)', border: '1px solid rgba(255,107,61,0.12)' }}
        >
          🧳
        </div>
        <div className="flex-1 relative z-[1]">
          <div className="text-[13px] font-medium text-ink">出发行李清单</div>
          <div className="text-[10px] text-ink-tertiary mt-px">3/12 已准备</div>
        </div>
        <div className="relative z-[1] flex items-center gap-1.5">
          <div className="w-12 h-1 overflow-hidden" style={{ borderRadius: 2, background: 'rgba(28,28,30,0.06)' }}>
            <div className="w-1/4 h-full" style={{ borderRadius: 2, background: '#FF6B3D' }} />
          </div>
          <span className="text-[13px] text-ink-tertiary">›</span>
        </div>
      </div>
    </div>
  )
}

/* ═══ App Bar ═══ */
function AppBar() {
  return (
    <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
      <div
        className="w-8 h-8 rounded-full flex items-center justify-center text-[14px] flex-shrink-0"
        style={{ background: 'rgba(28,28,30,0.88)', color: '#fff' }}
      >
        ‹
      </div>
      <div className="flex-1 min-w-0">
        <div className="text-[16px] font-medium text-ink">东京自由行</div>
        <div className="text-[11px] text-ink-tertiary">东京 · 大阪</div>
      </div>
      <div
        className="flex p-[3px]"
        style={{
          background: 'rgba(255,255,255,0.52)',
          backdropFilter: 'blur(24px)',
          WebkitBackdropFilter: 'blur(24px)',
          border: '1px solid rgba(255,255,255,0.65)',
          borderRadius: 100,
        }}
      >
        <div
          className="py-[5px] px-2.5 flex items-center"
          style={{ borderRadius: 100, background: 'rgba(28,28,30,0.88)' }}
        >
          <Icon name="list" size={16} className="text-white" />
        </div>
        <div className="py-[5px] px-2.5 flex items-center text-ink-tertiary">
          <Icon name="map" size={16} />
        </div>
      </div>
      <div
        className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
        style={{ background: 'rgba(28,28,30,0.88)' }}
      >
        <Icon name="more-v" size={16} className="text-white" />
      </div>
    </div>
  )
}

/* ═══ Day Bar ═══ */
function DayBar() {
  const days = [
    { day: 'Day 1', wd: '周四', on: true },
    { day: 'Day 2', wd: '周五', on: false },
    { day: 'Day 3', wd: '周六', on: false },
    { day: 'Day 4', wd: '周日', on: false },
    { day: 'Day 5', wd: '周一', on: false },
  ]
  return (
    <div className="flex items-center gap-0.5 px-4 py-1.5 relative z-[1] overflow-x-auto">
      {days.map((d) => (
        <div
          key={d.day}
          className="flex flex-col items-center flex-shrink-0"
          style={{
            padding: '6px 14px',
            borderRadius: 100,
            background: d.on ? 'rgba(255,255,255,0.55)' : 'transparent',
            border: d.on ? '1px solid rgba(255,255,255,0.70)' : '1px solid transparent',
            boxShadow: d.on ? '0 2px 8px rgba(0,0,0,0.04)' : 'none',
          }}
        >
          <span
            className="text-[13px] font-medium"
            style={{ color: d.on ? '#FF6B3D' : 'rgba(28,28,30,0.28)' }}
          >
            {d.day}
          </span>
          <span
            className="text-[9px] mt-px"
            style={{ color: d.on ? '#FF6B3D' : 'rgba(28,28,30,0.28)' }}
          >
            {d.wd}
          </span>
        </div>
      ))}
      <div className="flex-shrink-0 w-6 h-6 flex items-center justify-center text-[14px] text-ink-tertiary">
        ›
      </div>
    </div>
  )
}

/* ═══ Screen ═══ */
function TravelDetailV2Screen() {
  return (
    <PhoneFrame>
      <div className="absolute w-[260px] h-[260px] rounded-full blur-[50px]" style={{ background: 'rgba(255,107,61,0.08)', top: '25%', right: '-18%' }} />
      <div className="absolute w-[180px] h-[180px] rounded-full blur-[50px]" style={{ background: 'rgba(245,210,170,0.12)', top: '-5%', left: '-8%' }} />

      <AppBar />
      <DayBar />
      <LuggageEntry />

      <ScheduleCard
        variant="hotel"
        emoji="🏨"
        time="入住 15:00"
        timeVariant="hotel"
        title="新宿格拉斯丽酒店"
        address="东京都新宿区歌舞伎町"
        photos={2}
        note="前台可寄存行李，哥斯拉房间在8楼"
      />

      <ScheduleCard
        emoji="🍜"
        time="11:30"
        title="一兰拉面 新宿中央东口店"
        address="东京都新宿区新宿3-34-11"
        note="记得提前在机器点餐，选硬面，汤头选浓厚"
        dianping="大众点评 · ★★★★★ · ¥60/人"
      />

      <ScheduleCard
        emoji="⛩"
        time="14:00"
        title="明治神宫"
        address="东京都涩谷区代代木神园町"
        photos={3}
        note="值得绕到本殿后面的御苑散步，入口需要500日元"
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
        emoji="🎡"
        time="17:00"
        title="台场海滨公园"
        address="东京都港区台场1丁目"
      />
    </PhoneFrame>
  )
}

/* ═══ Storybook ═══ */
const meta: Meta = {
  title: 'Screens/TravelDetail V2',
  parameters: { layout: 'centered', backgrounds: { default: 'canvas' } },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <TravelDetailV2Screen />,
}
