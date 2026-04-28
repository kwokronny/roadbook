import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { Badge } from '@/components/ui/badge'
import { Icon } from '@/components/icon'

/* ── Dock ── */
function Dock({ activeTab }: { activeTab: 'travel' | 'profile' }) {
  const indicatorPosition = activeTab === 'travel' ? 'left-1' : 'left-[calc(50%+1px)]'
  return (
    <div className="absolute bottom-4 left-4 right-4 h-[52px] bg-[rgba(255,255,255,0.30)] backdrop-blur-[50px] backdrop-saturate-[1.8] border border-[rgba(255,255,255,0.50)] rounded-pill flex items-center p-1 z-10 shadow-[0_8px_32px_rgba(0,0,0,0.06),inset_0_1px_0_rgba(255,255,255,0.55)]">
      <div className={`absolute top-1 ${indicatorPosition} h-[44px] w-[calc(50%-4px)] rounded-pill bg-[rgba(255,255,255,0.45)] border border-[rgba(255,255,255,0.60)] shadow-[0_2px_8px_rgba(0,0,0,0.04),inset_0_1px_0_rgba(255,255,255,0.80)] pointer-events-none overflow-hidden`}>
        <div className="absolute inset-0 rounded-[inherit] bg-gradient-to-br from-white/45 to-transparent" />
      </div>
      <div className="flex-1 h-[44px] flex flex-col items-center justify-center relative z-[1]">
        <Icon name="map" size={20} className={activeTab === 'travel' ? 'text-coral' : 'text-ink-tertiary'} />
        <span className={`text-[9px] mt-0.5 font-medium ${activeTab === 'travel' ? 'text-coral' : 'text-ink-tertiary'}`}>旅程</span>
      </div>
      <div className="flex-1 h-[44px] flex flex-col items-center justify-center relative z-[1]">
        <Icon name="user" size={20} className={activeTab === 'profile' ? 'text-coral' : 'text-ink-tertiary'} />
        <span className={`text-[9px] mt-0.5 ${activeTab === 'profile' ? 'text-coral font-medium' : 'text-ink-tertiary'}`}>我的</span>
      </div>
    </div>
  )
}

/* ── Travel Card ── */
interface TravelCardProps {
  name: string
  dateRange: string
  badgeVariant: 'ongoing' | 'upcoming' | 'planning'
  badgeLabel: string
  cities: string[]
  avatars: { letter: string; color: string }[]
  days: string
}

function TravelCard({ name, dateRange, badgeVariant, badgeLabel, cities, avatars, days }: TravelCardProps) {
  return (
    <GlassCard variant="frost" className="mx-4 mb-2.5 p-[14px]">
      {/* Header */}
      <div className="flex justify-between items-start mb-1">
        <div>
          <div className="text-[16px] font-medium text-ink">{name}</div>
          <div className="text-[11px] text-ink-tertiary mt-0.5">{dateRange}</div>
        </div>
        <Badge variant={badgeVariant}>{badgeLabel}</Badge>
      </div>
      {/* City tags */}
      <div className="flex gap-1 mt-1.5">
        {cities.map((city) => (
          <Badge key={city} variant="city">{city}</Badge>
        ))}
      </div>
      {/* Dashed divider */}
      <hr className="my-2 border-0 border-t border-dashed border-[rgba(28,28,30,0.08)]" />
      {/* Footer */}
      <div className="flex justify-between items-center">
        <div className="flex">
          {avatars.map((av, i) => (
            <div
              key={i}
              className="w-5 h-5 rounded-full border-2 border-white/60 flex items-center justify-center text-[8px] text-white font-medium"
              style={{ background: av.color, marginLeft: i > 0 ? -4 : 0 }}
            >
              {av.letter}
            </div>
          ))}
        </div>
        <div className="text-[11px] text-ink-tertiary">{days}</div>
      </div>
    </GlassCard>
  )
}

/* ── Screen ── */
function TravelListScreen() {
  return (
    <PhoneFrame>
      {/* Top bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
        <div className="flex-1 text-[30px] font-extralight tracking-tight text-ink">旅程</div>
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[16px] flex-shrink-0">
          ＋
        </div>
      </div>

      {/* Search bar */}
      <div className="mx-4 mb-2.5 py-[9px] px-3 bg-[rgba(255,255,255,0.45)] backdrop-blur-[24px] border border-[rgba(255,255,255,0.60)] rounded-card-inner text-[13px] text-ink-tertiary relative z-[1] flex items-center gap-1.5">
        <Icon name="search" size={16} className="text-ink-tertiary" />
        搜索旅行计划...
      </div>

      {/* Travel cards */}
      <TravelCard
        name="东京自由行"
        dateRange="04/10 — 04/17"
        badgeVariant="ongoing"
        badgeLabel="旅行中"
        cities={['东京', '大阪']}
        avatars={[
          { letter: 'R', color: 'var(--coral)' },
          { letter: 'L', color: '#8C5CF6' },
        ]}
        days="7天"
      />
      <TravelCard
        name="清迈之旅"
        dateRange="05/01 — 05/05"
        badgeVariant="planning"
        badgeLabel="规划中"
        cities={['清迈']}
        avatars={[{ letter: 'R', color: 'var(--coral)' }]}
        days="4天"
      />
      <TravelCard
        name="首尔美食团"
        dateRange="06/12 — 06/16"
        badgeVariant="upcoming"
        badgeLabel="即将出发"
        cities={['首尔']}
        avatars={[
          { letter: 'R', color: 'var(--coral)' },
          { letter: 'M', color: '#E08500' },
        ]}
        days="4天"
      />

      {/* Dock */}
      <Dock activeTab="travel" />
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/TravelList',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <TravelListScreen />,
}
