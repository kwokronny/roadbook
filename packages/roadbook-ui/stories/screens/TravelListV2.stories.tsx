import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

/* ═══ Travel Card V2 ═══ */
function TravelCard({
  name,
  status,
  statusLabel,
  dateRange,
  cities,
  days,
  spots,
  emoji,
  avatars,
  people,
}: {
  name: string
  status: 'ongoing' | 'upcoming' | 'planning' | 'ended'
  statusLabel: string
  dateRange: string
  cities: string[]
  days: number
  spots: number
  emoji?: string
  avatars: { initial: string }[]
  people: number
}) {
  const statusColors: Record<string, { bg: string; text: string; dot: string }> = {
    ongoing:  { bg: 'rgba(255,107,61,0.10)', text: '#D4410A', dot: '#FF6B3D' },
    upcoming: { bg: 'rgba(224,133,0,0.10)',  text: '#B56800', dot: '#E08500' },
    planning: { bg: 'rgba(28,28,30,0.05)',   text: 'rgba(28,28,30,0.50)', dot: 'rgba(28,28,30,0.28)' },
    ended:    { bg: 'rgba(28,28,30,0.04)',   text: 'rgba(28,28,30,0.28)', dot: 'rgba(28,28,30,0.18)' },
  }

  const sc = statusColors[status]
  const decoColor: Record<string, string> = {
    ongoing: '#FF6B3D',
    upcoming: '#E08500',
    planning: 'rgba(28,28,30,0.35)',
    ended: 'rgba(28,28,30,0.20)',
  }

  return (
    <div className="mx-4 mb-3.5 relative z-[1]">
      <div
        className="relative"
        style={{
          padding: '18px 18px 16px',
          background: status === 'ongoing'
            ? 'linear-gradient(135deg, rgba(255,255,255,0.60) 0%, rgba(255,107,61,0.08) 100%)'
            : status === 'upcoming'
              ? 'linear-gradient(135deg, rgba(255,255,255,0.55) 0%, rgba(140,92,246,0.06) 100%)'
              : status === 'planning'
                ? 'linear-gradient(135deg, rgba(255,255,255,0.52) 0%, rgba(140,92,246,0.04) 100%)'
                : 'linear-gradient(135deg, rgba(255,255,255,0.38) 0%, rgba(28,28,30,0.03) 100%)',
          backdropFilter: 'blur(40px) saturate(1.4)',
          WebkitBackdropFilter: 'blur(40px) saturate(1.4)',
          border: status === 'ongoing'
            ? '1px solid rgba(255,107,61,0.12)'
            : (status === 'upcoming' || status === 'planning')
              ? '1px solid rgba(140,92,246,0.10)'
              : '1px solid rgba(255,255,255,0.65)',
          borderRadius: 24,
          boxShadow: status === 'ongoing'
            ? '0 8px 32px rgba(255,107,61,0.06), 0 2px 8px rgba(0,0,0,0.04)'
            : '0 8px 32px rgba(0,0,0,0.06)',
          opacity: status === 'ended' ? 0.75 : 1,
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

        {/* Ongoing accent bar */}
        {status === 'ongoing' && (
          <div
            className="absolute top-0 left-6 right-6 h-[2px] pointer-events-none"
            style={{
              background: 'linear-gradient(90deg, transparent, #FF6B3D, transparent)',
              borderRadius: '0 0 2px 2px',
              opacity: 0.5,
            }}
          />
        )}

        {/* Decorative emoji */}

        {/* Content */}
        <div className="relative z-[1]">
          {/* Row 1: Name + More */}
          <div className="flex items-start justify-between mb-2">
            <div
              className="flex-1 min-w-0 mr-4"
              style={{ fontSize: 18, fontWeight: 500, color: 'rgba(28,28,30,0.90)', lineHeight: 1.3 }}
            >
              {name}
            </div>
            <Icon name="more-h" size={16} style={{ color: 'rgba(28,28,30,0.28)', marginTop: 3, flexShrink: 0 }} />
          </div>

          {/* Row 2: Status + Date | People + Spots */}
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <div className="inline-flex items-center gap-1"
                style={{
                  padding: '2px 8px',
                  borderRadius: 100,
                  background: sc.bg,
                }}
              >
                <div className="w-1.5 h-1.5 rounded-full" style={{ background: sc.dot }} />
                <span style={{ fontSize: 10, fontWeight: 500, color: sc.text }}>{statusLabel}</span>
              </div>
              <span style={{ fontSize: 12, fontWeight: 500, color: 'rgba(28,28,30,0.55)' }}>{dateRange}</span>
            </div>
            <span style={{ fontSize: 11, color: 'rgba(28,28,30,0.50)', position: 'relative', zIndex: 2 }}>
              {people}人 · {spots}景点
            </span>
          </div>

          {/* Row 3: Avatars | Cities */}
          <div className="flex items-center justify-between">
            <div className="flex">
              {avatars.map((av, i) => (
                <div
                  key={i}
                  className="flex items-center justify-center"
                  style={{
                    width: 24,
                    height: 24,
                    borderRadius: '50%',
                    background: '#C4C4C6',
                    border: '2px solid rgba(255,255,255,0.70)',
                    marginLeft: i > 0 ? -6 : 0,
                    fontSize: 9,
                    fontWeight: 500,
                    color: '#fff',
                    position: 'relative',
                    zIndex: avatars.length - i,
                  }}
                >
                  {av.initial}
                </div>
              ))}
            </div>
            <div className="flex flex-wrap gap-1 justify-end">
              {cities.map((city) => (
                <span
                  key={city}
                  style={{
                    padding: '2px 8px',
                    borderRadius: 100,
                    background: 'rgba(28,28,30,0.04)',
                    border: '1px solid rgba(28,28,30,0.06)',
                    fontSize: 10,
                    color: 'rgba(28,28,30,0.50)',
                  }}
                >
                  {city}
                </span>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

/* ═══ Screen ═══ */
function TravelListV2Screen() {
  return (
    <PhoneFrame>
      {/* App bar */}
      <div className="pt-11 px-5 pb-1 flex items-center gap-2 relative z-[1]">
        <div style={{ fontSize: 30, fontWeight: 200, letterSpacing: '-0.02em', flex: 1 }}>
          旅程
        </div>
        <div
          className="w-8 h-8 rounded-full flex items-center justify-center"
          style={{ background: 'rgba(28,28,30,0.88)', color: '#fff', fontSize: 16 }}
        >
          ＋
        </div>
      </div>

      {/* Search */}
      <div className="mx-4 mb-3 relative z-[1]">
        <div
          className="flex items-center gap-1.5"
          style={{
            padding: '9px 12px',
            background: 'rgba(255,255,255,0.45)',
            backdropFilter: 'blur(24px)',
            WebkitBackdropFilter: 'blur(24px)',
            border: '1px solid rgba(255,255,255,0.60)',
            borderRadius: 14,
          }}
        >
          <Icon name="search" size={16} className="text-ink-tertiary" />
          <span style={{ fontSize: 13, color: 'rgba(28,28,30,0.28)' }}>搜索旅行计划...</span>
        </div>
      </div>

      {/* Cards */}
      <TravelCard
        name="东京自由行"
        status="ongoing"
        statusLabel="旅行中"
        dateRange="04/10 — 04/17"
        cities={['东京', '大阪']}
        days={7}
        spots={12}
        emoji="⛩"
        avatars={[
          { initial: 'R' },
          { initial: 'L' },
        ]}
        people={2}
      />

      <TravelCard
        name="清迈之旅"
        status="planning"
        statusLabel="规划中"
        dateRange="05/01 — 05/05"
        cities={['清迈']}
        days={4}
        spots={6}
        emoji="🐘"
        avatars={[{ initial: 'R' }]}
        people={1}
      />

      <TravelCard
        name="首尔美食团"
        status="upcoming"
        statusLabel="即将出发"
        dateRange="06/12 — 06/16"
        cities={['首尔']}
        days={4}
        spots={8}
        emoji="🍜"
        avatars={[
          { initial: 'R' },
          { initial: 'M' },
        ]}
        people={2}
      />

      <TravelCard
        name="北海道冬季温泉之旅"
        status="ended"
        statusLabel="已结束"
        dateRange="01/15 — 01/22"
        cities={['札幌', '小樽', '函馆']}
        days={7}
        spots={15}
        emoji="♨️"
        avatars={[
          { initial: 'R' },
          { initial: 'L' },
          { initial: 'K' },
        ]}
        people={3}
      />

      {/* Dock */}
      <div
        className="absolute bottom-4 left-4 right-4 h-[52px] flex items-center p-1 z-10"
        style={{
          background: 'rgba(255,255,255,0.30)',
          backdropFilter: 'blur(50px) saturate(1.8) brightness(1.05)',
          WebkitBackdropFilter: 'blur(50px) saturate(1.8) brightness(1.05)',
          border: '1px solid rgba(255,255,255,0.50)',
          borderRadius: 100,
          boxShadow: '0 8px 32px rgba(0,0,0,0.06), inset 0 1px 0 rgba(255,255,255,0.55)',
        }}
      >
        {/* Indicator */}
        <div
          className="absolute top-1 left-1 h-[44px] pointer-events-none"
          style={{
            width: 'calc(50% - 4px)',
            borderRadius: 100,
            background: 'rgba(255,255,255,0.45)',
            border: '1px solid rgba(255,255,255,0.60)',
            boxShadow: '0 2px 8px rgba(0,0,0,0.04), inset 0 1px 0 rgba(255,255,255,0.80)',
          }}
        />
        <div className="flex-1 h-[44px] flex flex-col items-center justify-center relative z-[1]">
          <Icon name="map" size={20} className="text-coral" />
          <span style={{ fontSize: 9, marginTop: 1, color: '#FF6B3D', fontWeight: 500 }}>旅程</span>
        </div>
        <div className="flex-1 h-[44px] flex flex-col items-center justify-center relative z-[1]">
          <Icon name="user" size={20} className="text-ink-tertiary" />
          <span style={{ fontSize: 9, marginTop: 1, color: 'rgba(28,28,30,0.28)' }}>我的</span>
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ═══ Storybook ═══ */
const meta: Meta = {
  title: 'Screens/TravelList V2',
  parameters: { layout: 'centered', backgrounds: { default: 'canvas' } },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <TravelListV2Screen />,
}
