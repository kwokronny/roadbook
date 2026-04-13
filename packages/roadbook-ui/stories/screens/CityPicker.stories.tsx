import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

/* ── Chip ── */
function SelectedChip({ label }: { label: string }) {
  return (
    <div className="inline-flex items-center gap-1 py-1 px-2.5 rounded-pill bg-coral-tint border border-[rgba(255,107,61,0.15)] text-[13px] text-coral font-medium">
      {label}
      <span className="text-[11px] opacity-70">✕</span>
    </div>
  )
}

/* ── City Row ── */
function CityRow({ name, checked }: { name: string; checked?: boolean }) {
  return (
    <div className="flex items-center py-2.5 px-[14px]">
      <div className="flex-1 text-[14px] text-ink">{name}</div>
      {checked && (
        <Icon name="check" size={16} className="text-coral" />
      )}
    </div>
  )
}

/* ── Section Header ── */
function SectionHeader({ letter }: { letter: string }) {
  return (
    <div className="px-[14px] py-1 text-[12px] text-ink-tertiary font-medium bg-[rgba(28,28,30,0.02)]">
      {letter}
    </div>
  )
}

/* ── Screen ── */
function CityPickerScreen() {
  return (
    <PhoneFrame>
      {/* Dimmed overlay */}
      <div className="absolute inset-0 bg-[rgba(0,0,0,0.35)] z-[2]" />

      {/* Bottom sheet */}
      <div className="absolute bottom-0 left-0 right-0 h-[75%] bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8] border-t border-white/55 rounded-t-sheet z-[3] flex flex-col overflow-hidden">
        <div
          className="absolute inset-0 rounded-[inherit] pointer-events-none"
          style={{ background: 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)' }}
        />

        {/* Handle */}
        <div className="flex justify-center pt-2 pb-1 relative z-[1]">
          <div className="w-9 h-1 rounded-pill bg-[rgba(28,28,30,0.15)]" />
        </div>

        {/* Header */}
        <div className="flex items-center px-4 pb-2 relative z-[1]">
          <div className="flex-1 text-[18px] font-medium text-ink">选择城市</div>
          <div className="text-[15px] text-coral font-medium">完成 (2)</div>
        </div>

        {/* Search bar */}
        <div className="mx-4 mb-2.5 py-[9px] px-3 bg-white border border-[rgba(28,28,30,0.08)] rounded-card-inner text-[13px] text-ink-tertiary flex items-center gap-1.5 relative z-[1]">
          <Icon name="search" size={16} className="text-ink-tertiary" />
          搜索城市或拼音
        </div>

        {/* Selected chips */}
        <div className="flex gap-1.5 px-4 mb-2 relative z-[1]">
          <SelectedChip label="东京" />
          <SelectedChip label="大阪" />
        </div>

        {/* Alphabetical list */}
        <div className="flex-1 overflow-y-auto relative z-[1]">
          <SectionHeader letter="B" />
          <CityRow name="北京" />
          <CityRow name="保定" />

          <SectionHeader letter="C" />
          <CityRow name="成都" />
          <CityRow name="重庆" />
          <CityRow name="长沙" />

          <SectionHeader letter="D" />
          <CityRow name="大连" />
          <CityRow name="大阪" checked />

          <SectionHeader letter="G" />
          <CityRow name="广州" />
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/CityPicker',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <CityPickerScreen />,
}
