import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

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
function ScheduleEditSheetScreen() {
  return (
    <PhoneFrame>
      {/* Dimmed overlay */}
      <div className="absolute inset-0 bg-[rgba(0,0,0,0.35)] z-[2]" />

      {/* Bottom sheet */}
      <div className="absolute bottom-0 left-0 right-0 h-[70%] bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8] border-t border-white/55 rounded-t-sheet z-[3] flex flex-col overflow-hidden">
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
          <div className="flex-1 text-[18px] font-medium text-ink">编辑行程</div>
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="close" size={16} className="text-ink-tertiary" />
          </div>
        </div>

        {/* Form */}
        <div className="flex-1 overflow-y-auto px-4 pb-4 relative z-[1]">
          <FormField label="名称">
            <input
              type="text"
              defaultValue="一兰拉面"
              className="w-full py-2.5 px-3 rounded-card-inner bg-white border border-[rgba(28,28,30,0.08)] text-[14px] text-ink outline-none"
            />
          </FormField>

          <FormField label="截图">
            <div className="flex gap-2">
              {/* Thumbnail 1 */}
              <div className="w-16 h-16 rounded-[10px] bg-[rgba(28,28,30,0.06)] border border-[rgba(28,28,30,0.08)] flex items-center justify-center overflow-hidden">
                <Icon name="image" size={20} className="text-ink-tertiary" />
              </div>
              {/* Thumbnail 2 */}
              <div className="w-16 h-16 rounded-[10px] bg-[rgba(28,28,30,0.06)] border border-[rgba(28,28,30,0.08)] flex items-center justify-center overflow-hidden">
                <Icon name="image" size={20} className="text-ink-tertiary" />
              </div>
              {/* Add button */}
              <div className="w-16 h-16 rounded-[10px] border-2 border-dashed border-[rgba(28,28,30,0.12)] flex items-center justify-center">
                <span className="text-[22px] text-ink-tertiary">＋</span>
              </div>
            </div>
          </FormField>

          <FormField label="备注">
            <textarea
              placeholder="添加备注..."
              className="w-full py-2.5 px-3 rounded-card-inner bg-white border border-[rgba(28,28,30,0.08)] text-[14px] text-ink placeholder:text-ink-tertiary outline-none resize-none h-20"
            />
          </FormField>
        </div>

        {/* CTA */}
        <div className="px-4 pb-6 pt-2 relative z-[1]">
          <button className="w-full py-3 rounded-pill bg-dark text-white text-[15px] font-medium text-center">
            保存修改 →
          </button>
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/ScheduleEditSheet',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <ScheduleEditSheetScreen />,
}
