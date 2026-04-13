import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

/* ── Numbered Marker ── */
function NumberedMarker({ num, x, y }: { num: number; x: number; y: number }) {
  return (
    <div className="absolute flex flex-col items-center" style={{ left: `${x}%`, top: `${y}%` }}>
      <div className="w-6 h-6 rounded-full bg-coral text-white text-[11px] font-bold flex items-center justify-center shadow-[0_2px_8px_rgba(255,107,61,0.35)]">
        {num}
      </div>
      {/* Stem */}
      <div className="w-px h-2 bg-coral" />
      {/* Dot */}
      <div className="w-1.5 h-1.5 rounded-full bg-coral border border-white shadow-[0_1px_3px_rgba(255,107,61,0.30)]" />
    </div>
  )
}

/* ── Search Result Item ── */
function SearchResultItem({ num, name, address }: { num: number; name: string; address: string }) {
  return (
    <div className="flex items-center gap-3 py-2.5 px-1">
      {/* Numbered circle */}
      <div className="w-8 h-8 rounded-full bg-[rgba(255,107,61,0.10)] text-coral text-[13px] font-bold flex items-center justify-center flex-shrink-0">
        {num}
      </div>
      {/* Content */}
      <div className="flex-1 min-w-0">
        <div className="text-[14px] font-medium text-ink truncate">{name}</div>
        <div className="text-[11px] text-ink-tertiary truncate mt-0.5">{address}</div>
      </div>
      {/* Add button */}
      <div className="w-8 h-8 rounded-full bg-[rgba(255,107,61,0.10)] text-coral flex items-center justify-center flex-shrink-0">
        <Icon name="plus" size={16} />
      </div>
    </div>
  )
}

/* ── Screen ── */
function MapSearchScreen() {
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

      {/* Map area with search overlay */}
      <div className="relative flex-1 mx-3 mt-1 rounded-[20px] overflow-hidden bg-[#f0ede6] z-[1]" style={{ minHeight: 240 }}>
        {/* Fake roads */}
        <svg className="absolute inset-0 w-full h-full" preserveAspectRatio="none">
          <line x1="0" y1="35%" x2="100%" y2="35%" stroke="#d9d4c8" strokeWidth="6" />
          <line x1="0" y1="35%" x2="100%" y2="35%" stroke="#e8e3d9" strokeWidth="4" />
          <line x1="50%" y1="0" x2="50%" y2="100%" stroke="#d9d4c8" strokeWidth="6" />
          <line x1="50%" y1="0" x2="50%" y2="100%" stroke="#e8e3d9" strokeWidth="4" />
          <line x1="0" y1="70%" x2="100%" y2="70%" stroke="#e3ded4" strokeWidth="2" />
          <line x1="20%" y1="0" x2="20%" y2="100%" stroke="#e3ded4" strokeWidth="2" />
          <line x1="78%" y1="0" x2="78%" y2="100%" stroke="#e3ded4" strokeWidth="2" />
        </svg>

        {/* Block fills */}
        <div className="absolute top-[8%] left-[22%] w-[26%] h-[24%] bg-[#e7e2d8] rounded-sm" />
        <div className="absolute top-[37%] left-[52%] w-[24%] h-[30%] bg-[#e7e2d8] rounded-sm" />

        {/* Numbered markers */}
        <NumberedMarker num={1} x={28} y={22} />
        <NumberedMarker num={2} x={62} y={42} />
        <NumberedMarker num={3} x={38} y={65} />

        {/* Search bar overlay */}
        <div className="absolute top-3 left-3 right-3 z-[3] flex items-center gap-1.5 bg-[rgba(255,255,255,0.85)] backdrop-blur-[24px] border border-[rgba(255,255,255,0.70)] rounded-pill px-3 py-2 shadow-[0_4px_16px_rgba(0,0,0,0.06)]">
          {/* City chip */}
          <div className="flex items-center gap-0.5 bg-[rgba(255,107,61,0.10)] text-coral text-[12px] font-medium px-2 py-1 rounded-pill flex-shrink-0">
            东京 ▾
          </div>
          {/* Keyword */}
          <span className="text-[14px] text-ink flex-1">拉面</span>
          {/* Clear */}
          <div className="w-5 h-5 rounded-full bg-[rgba(28,28,30,0.08)] flex items-center justify-center flex-shrink-0">
            <Icon name="close" size={10} className="text-ink-tertiary" />
          </div>
          {/* Close circle */}
          <div className="w-7 h-7 rounded-full bg-dark text-white flex items-center justify-center flex-shrink-0">
            <Icon name="close" size={12} />
          </div>
        </div>
      </div>

      {/* Bottom draggable sheet */}
      <div className="relative mx-3 mt-2 mb-3 bg-[rgba(255,255,255,0.75)] backdrop-blur-[40px] backdrop-saturate-[1.4] border border-[rgba(255,255,255,0.60)] rounded-t-[20px] rounded-b-[20px] shadow-[0_-4px_24px_rgba(0,0,0,0.06)] z-[2] overflow-hidden">
        {/* Glass inner highlight */}
        <div className="absolute inset-0 rounded-[inherit] pointer-events-none" style={{ background: 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)' }} />
        <div className="relative z-[1]">
          {/* Drag handle */}
          <div className="flex justify-center pt-2 pb-1">
            <div className="w-8 h-1 rounded-full bg-[rgba(28,28,30,0.12)]" />
          </div>
          {/* Result count */}
          <div className="px-4 pt-1 pb-1 text-[13px] text-ink-secondary font-medium">找到 3 个结果</div>
          {/* Results */}
          <div className="px-3 pb-3">
            <SearchResultItem num={1} name="一兰拉面 新宿中央东口店" address="东京都新宿区新宿3-34-11" />
            <hr className="border-0 border-t border-[rgba(28,28,30,0.06)] mx-1" />
            <SearchResultItem num={2} name="拉面二郎 歌舞伎町店" address="东京都新宿区歌舞伎町1-19-1" />
            <hr className="border-0 border-t border-[rgba(28,28,30,0.06)] mx-1" />
            <SearchResultItem num={3} name="AFURI 阿夫利拉面 新宿" address="东京都新宿区西新宿1-4-1" />
          </div>
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/MapSearch',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <MapSearchScreen />,
}
