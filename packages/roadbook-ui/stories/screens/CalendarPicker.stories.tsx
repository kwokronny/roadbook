import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'

/* ── Calendar Grid ── */
function CalendarGrid() {
  const weekLabels = ['一', '二', '三', '四', '五', '六', '日']

  // April 2026 starts on Wednesday (index 2 in Mon-based week)
  // So we need 2 empty slots before day 1
  const blanks = Array.from({ length: 2 }, (_, i) => (
    <div key={`blank-${i}`} className="w-full aspect-square" />
  ))

  const days = Array.from({ length: 30 }, (_, i) => {
    const day = i + 1
    const isStart = day === 10
    const isEnd = day === 14
    const isRange = day > 10 && day < 14
    const isSelected = isStart || isEnd

    let cellBg = ''
    let textColor = 'text-ink'
    let fontWeight = ''

    if (isSelected) {
      cellBg = 'bg-coral'
      textColor = 'text-white'
      fontWeight = 'font-medium'
    } else if (isRange) {
      cellBg = 'bg-coral-tint'
      textColor = 'text-ink'
    }

    // Past days (before 10) — slightly muted
    if (day < 10) {
      textColor = 'text-ink-tertiary'
    }

    return (
      <div key={day} className="w-full aspect-square flex items-center justify-center">
        <div
          className={`w-8 h-8 rounded-full flex items-center justify-center text-[13px] ${cellBg} ${textColor} ${fontWeight}`}
        >
          {day}
        </div>
      </div>
    )
  })

  return (
    <div>
      {/* Week labels */}
      <div className="grid grid-cols-7 mb-1">
        {weekLabels.map((label) => (
          <div key={label} className="text-center text-[11px] text-ink-tertiary font-medium py-1">
            {label}
          </div>
        ))}
      </div>
      {/* Day grid */}
      <div className="grid grid-cols-7">
        {blanks}
        {days}
      </div>
    </div>
  )
}

/* ── Screen ── */
function CalendarPickerScreen() {
  return (
    <PhoneFrame>
      {/* Dimmed overlay */}
      <div className="absolute inset-0 bg-[rgba(0,0,0,0.35)] z-[2]" />

      {/* Centered dialog */}
      <div className="absolute inset-0 flex items-center justify-center z-[3] px-5">
        <div className="w-full bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8] border border-white/55 rounded-card p-4 shadow-[0_20px_60px_rgba(0,0,0,0.12)] relative overflow-hidden">
          <div
            className="absolute inset-0 rounded-[inherit] pointer-events-none"
            style={{ background: 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)' }}
          />

          <div className="relative z-[1]">
            {/* Title */}
            <div className="text-[18px] font-medium text-ink mb-1">出行日期</div>
            <div className="text-[12px] text-coral mb-3">已选 4/10 — 请选结束日期</div>

            {/* Month nav */}
            <div className="flex items-center justify-between mb-2">
              <span className="text-[14px] text-ink-tertiary">&#x2039;</span>
              <span className="text-[15px] font-medium text-ink">2026年4月</span>
              <span className="text-[14px] text-ink-tertiary">&#x203A;</span>
            </div>

            {/* Calendar */}
            <CalendarGrid />

            {/* Range summary */}
            <div className="mt-3 pt-3 border-t border-[rgba(28,28,30,0.06)] flex items-center justify-between">
              <div>
                <div className="text-[13px] text-ink">4/10 (周五) → 4/14 (周二)</div>
              </div>
              <div className="text-[13px] text-coral font-medium">4晚5天</div>
            </div>
          </div>
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/CalendarPicker',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <CalendarPickerScreen />,
}
