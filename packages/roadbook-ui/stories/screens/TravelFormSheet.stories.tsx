import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

/* ── Toggle ── */
function Toggle({ on }: { on: boolean }) {
  return (
    <div
      className={`w-[42px] h-[26px] rounded-pill relative transition-colors ${
        on ? 'bg-[#34C759]' : 'bg-[rgba(28,28,30,0.12)]'
      }`}
    >
      <div
        className={`absolute top-[3px] w-5 h-5 rounded-full bg-white shadow-[0_1px_3px_rgba(0,0,0,0.15)] transition-transform ${
          on ? 'left-[19px]' : 'left-[3px]'
        }`}
      />
    </div>
  )
}

/* ── Form Field ── */
function FormField({
  label,
  children,
}: {
  label: string
  children: React.ReactNode
}) {
  return (
    <div className="mb-3.5">
      <div className="text-[12px] text-ink-secondary mb-1.5 font-medium">{label}</div>
      {children}
    </div>
  )
}

/* ── Screen ── */
function TravelFormSheetScreen() {
  return (
    <PhoneFrame>
      {/* Dimmed overlay */}
      <div className="absolute inset-0 bg-[rgba(0,0,0,0.35)] z-[2]" />

      {/* Bottom sheet */}
      <div className="absolute bottom-0 left-0 right-0 h-[75%] bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8] border-t border-white/55 rounded-t-sheet z-[3] flex flex-col overflow-hidden">
        {/* Inner highlight */}
        <div
          className="absolute inset-0 rounded-[inherit] pointer-events-none"
          style={{ background: 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)' }}
        />

        {/* Handle */}
        <div className="flex justify-center pt-2 pb-1 relative z-[1]">
          <div className="w-9 h-1 rounded-pill bg-[rgba(28,28,30,0.15)]" />
        </div>

        {/* Header */}
        <div className="flex items-center px-4 pb-3 relative z-[1]">
          <div className="flex-1 text-[18px] font-medium text-ink">新建旅程</div>
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="close" size={16} className="text-ink-tertiary" />
          </div>
        </div>

        {/* Form */}
        <div className="flex-1 overflow-y-auto px-4 pb-4 relative z-[1]">
          <FormField label="名称">
            <input
              type="text"
              placeholder="输入旅程名称"
              className="w-full py-2.5 px-3 rounded-card-inner bg-white border border-[rgba(28,28,30,0.08)] text-[14px] text-ink placeholder:text-ink-tertiary outline-none"
            />
          </FormField>

          <FormField label="目的地">
            <div className="w-full py-2.5 px-3 rounded-card-inner bg-white border border-[rgba(28,28,30,0.08)] text-[14px] text-ink-tertiary flex items-center justify-between">
              <span>选择城市</span>
              <span className="text-[12px]">&#x203A;</span>
            </div>
          </FormField>

          <FormField label="日期">
            <div className="w-full py-2.5 px-3 rounded-card-inner bg-white border border-[rgba(28,28,30,0.08)] text-[14px] text-ink flex items-center justify-between">
              <span>2026/04/10 → 2026/04/14</span>
              <span className="text-[12px] text-ink-tertiary">&#x203A;</span>
            </div>
          </FormField>

          <div className="flex items-center justify-between py-1">
            <div className="text-[14px] text-ink">公开</div>
            <Toggle on={true} />
          </div>
        </div>

        {/* CTA */}
        <div className="px-4 pb-6 pt-2 relative z-[1]">
          <button className="w-full py-3 rounded-pill bg-dark text-white text-[15px] font-medium text-center">
            创建旅程 →
          </button>
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/TravelFormSheet',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <TravelFormSheetScreen />,
}
