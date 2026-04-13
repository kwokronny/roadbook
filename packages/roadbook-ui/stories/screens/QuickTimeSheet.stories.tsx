import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

/* ── Screen ── */
function QuickTimeSheetScreen() {
  const hours = ['08', '09', '10', '11', '12', '13']
  const selectedHour = '11'

  const days = [
    { label: 'DAY 1', active: true },
    { label: 'DAY 2', active: false },
    { label: 'DAY 3', active: false },
  ]

  return (
    <PhoneFrame>
      {/* Dimmed overlay */}
      <div className="absolute inset-0 bg-[rgba(0,0,0,0.35)] z-[2]" />

      {/* Bottom sheet */}
      <div className="absolute bottom-0 left-0 right-0 h-[55%] bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8] border-t border-white/55 rounded-t-sheet z-[3] flex flex-col overflow-hidden">
        <div
          className="absolute inset-0 rounded-[inherit] pointer-events-none"
          style={{ background: 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)' }}
        />

        {/* Handle */}
        <div className="flex justify-center pt-2 pb-1 relative z-[1]">
          <div className="w-9 h-1 rounded-pill bg-[rgba(28,28,30,0.15)]" />
        </div>

        {/* Header */}
        <div className="flex items-center px-4 pb-1 relative z-[1]">
          <div className="flex-1 text-[18px] font-medium text-ink">修改时间</div>
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="close" size={16} className="text-ink-tertiary" />
          </div>
        </div>

        {/* Subtitle */}
        <div className="px-4 pb-3 text-[13px] text-ink-tertiary relative z-[1]">
          一兰拉面 新宿中央东口店
        </div>

        {/* Day selector */}
        <div className="flex gap-1.5 px-4 mb-3.5 relative z-[1]">
          {days.map((d) => (
            <div
              key={d.label}
              className={`py-1.5 px-3.5 rounded-pill text-[12px] font-medium border ${
                d.active
                  ? 'bg-coral text-white border-coral shadow-[0_2px_8px_rgba(255,107,61,0.25)]'
                  : 'bg-[rgba(28,28,30,0.04)] text-ink-tertiary border-transparent'
              }`}
            >
              {d.label}
            </div>
          ))}
        </div>

        {/* Hour grid */}
        <div className="grid grid-cols-6 gap-1.5 px-4 mb-4 relative z-[1]">
          {hours.map((h) => (
            <div
              key={h}
              className={`py-2.5 rounded-card-inner text-center text-[14px] font-medium ${
                h === selectedHour
                  ? 'bg-coral text-white shadow-[0_2px_8px_rgba(255,107,61,0.25)]'
                  : 'bg-white border border-[rgba(28,28,30,0.08)] text-ink'
              }`}
            >
              {h}
            </div>
          ))}
        </div>

        {/* CTA */}
        <div className="px-4 pb-6 pt-2 relative z-[1] mt-auto">
          <button className="w-full py-3 rounded-pill bg-dark text-white text-[15px] font-medium text-center">
            确认 11:30 →
          </button>
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/QuickTimeSheet',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <QuickTimeSheetScreen />,
}
