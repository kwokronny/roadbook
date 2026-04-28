import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { Icon } from '@/components/icon'

/* ── Map Marker ── */
function MapMarker({ label, x, y }: { label: string; x: number; y: number }) {
  return (
    <div className="absolute flex flex-col items-center" style={{ left: `${x}%`, top: `${y}%` }}>
      {/* Label pill */}
      <div className="bg-coral text-white text-[10px] font-medium px-2 py-[3px] rounded-pill whitespace-nowrap shadow-[0_2px_8px_rgba(255,107,61,0.30)]">
        {label}
      </div>
      {/* Stem */}
      <div className="w-px h-3 bg-coral" />
      {/* Dot */}
      <div className="w-2 h-2 rounded-full bg-coral border-2 border-white shadow-[0_1px_4px_rgba(255,107,61,0.35)]" />
    </div>
  )
}

/* ── Screen ── */
function MapViewScreen() {
  return (
    <PhoneFrame>
      {/* App bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[2]">
        {/* Back */}
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[14px] flex-shrink-0">
          &#x2039;
        </div>
        {/* Title */}
        <div className="flex-1 min-w-0">
          <div className="text-[16px] font-medium text-ink">东京自由行</div>
          <div className="text-[11px] text-ink-tertiary">东京 &middot; 大阪</div>
        </div>
        {/* Pill toggle – map active */}
        <div className="flex bg-frost backdrop-blur-[24px] border border-frost-border rounded-pill p-[3px]">
          <div className="py-[5px] px-2.5 rounded-pill text-[13px] text-ink-tertiary flex items-center">
            <Icon name="list" size={16} />
          </div>
          <div className="py-[5px] px-2.5 rounded-pill bg-dark text-white text-[13px] flex items-center">
            <Icon name="map" size={16} className="text-white" />
          </div>
        </div>
        {/* More */}
        <div className="w-8 h-8 rounded-full bg-dark flex items-center justify-center flex-shrink-0">
          <Icon name="more-v" size={16} className="text-white" />
        </div>
      </div>

      {/* Map area */}
      <div className="relative flex-1 mx-3 mt-1 mb-2 rounded-[20px] overflow-hidden bg-[#f0ede6] z-[1]" style={{ minHeight: 360 }}>
        {/* Fake roads */}
        <svg className="absolute inset-0 w-full h-full" preserveAspectRatio="none">
          {/* Major road horizontal */}
          <line x1="0" y1="40%" x2="100%" y2="40%" stroke="#d9d4c8" strokeWidth="6" />
          <line x1="0" y1="40%" x2="100%" y2="40%" stroke="#e8e3d9" strokeWidth="4" />
          {/* Major road vertical */}
          <line x1="55%" y1="0" x2="55%" y2="100%" stroke="#d9d4c8" strokeWidth="6" />
          <line x1="55%" y1="0" x2="55%" y2="100%" stroke="#e8e3d9" strokeWidth="4" />
          {/* Minor roads */}
          <line x1="0" y1="65%" x2="100%" y2="65%" stroke="#e3ded4" strokeWidth="2" />
          <line x1="25%" y1="0" x2="25%" y2="100%" stroke="#e3ded4" strokeWidth="2" />
          <line x1="80%" y1="0" x2="80%" y2="100%" stroke="#e3ded4" strokeWidth="2" />
          <line x1="0" y1="20%" x2="100%" y2="20%" stroke="#e3ded4" strokeWidth="2" />
          {/* Diagonal */}
          <line x1="10%" y1="80%" x2="65%" y2="25%" stroke="#e3ded4" strokeWidth="2" />
        </svg>

        {/* Block fills */}
        <div className="absolute top-[22%] left-[27%] w-[26%] h-[16%] bg-[#e7e2d8] rounded-sm" />
        <div className="absolute top-[42%] left-[0%] w-[23%] h-[21%] bg-[#e7e2d8] rounded-sm" />
        <div className="absolute top-[67%] left-[57%] w-[21%] h-[18%] bg-[#dfe8d6] rounded-sm opacity-60" />

        {/* Map markers */}
        <MapMarker label="D1·🏨酒店" x={30} y={28} />
        <MapMarker label="D1·🍜一兰" x={60} y={45} />
        <MapMarker label="D1·⛩明治神宫" x={40} y={68} />

        {/* Day selector on map */}
        <div className="absolute bottom-3 left-3 right-3 flex items-center gap-1.5 z-[2]">
          {[
            { label: 'Day 1', active: true },
            { label: 'Day 2', active: false },
            { label: 'Day 3', active: false },
            { label: '待规划', active: false },
          ].map((d) => (
            <div
              key={d.label}
              className={`py-1.5 px-3 rounded-pill text-[12px] font-medium border flex-shrink-0 ${
                d.active
                  ? 'bg-coral text-white border-coral shadow-[0_2px_8px_rgba(255,107,61,0.30)]'
                  : 'bg-[rgba(255,255,255,0.55)] backdrop-blur-[16px] border-[rgba(255,255,255,0.70)] text-ink-secondary shadow-[0_2px_8px_rgba(0,0,0,0.04)]'
              }`}
            >
              {d.label}
            </div>
          ))}
        </div>

        {/* Search FAB */}
        <div className="absolute bottom-3 right-3 w-11 h-11 rounded-full bg-coral text-white flex items-center justify-center text-[18px] shadow-[0_4px_16px_rgba(255,107,61,0.35)] z-[3]">
          🔍
        </div>
      </div>

      {/* Bottom info bar */}
      <GlassCard variant="frost" className="mx-3 mb-4 p-3 z-[2]">
        <div className="flex gap-2.5 items-start">
          {/* Emoji cover */}
          <div className="w-11 h-11 rounded-[10px] bg-[rgba(255,107,61,0.08)] border border-[rgba(255,107,61,0.12)] flex items-center justify-center text-[20px] flex-shrink-0">
            🍜
          </div>
          {/* Info */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <div className="text-[15px] font-medium text-ink flex-1 truncate">一兰拉面 新宿中央东口店</div>
              {/* Nav circle button */}
              <div className="w-8 h-8 rounded-full bg-coral text-white flex items-center justify-center flex-shrink-0 shadow-[0_2px_8px_rgba(255,107,61,0.25)]">
                <Icon name="navigate" size={14} />
              </div>
            </div>
            <div className="text-[11px] text-ink-tertiary mt-0.5">11:30 · 东京都新宿区新宿3-34-11</div>
            {/* Photo thumbnails + note link */}
            <div className="flex items-center gap-1.5 mt-2">
              {[0, 1, 2].map((i) => (
                <div
                  key={i}
                  className="w-8 h-8 rounded-md bg-[rgba(28,28,30,0.05)]"
                />
              ))}
              <span className="text-[11px] text-coral ml-1 font-medium">查看备注 ›</span>
            </div>
          </div>
        </div>
      </GlassCard>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/MapView',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <MapViewScreen />,
}
