import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { Icon } from '@/components/icon'

/* ── Form Row ── */
function FormRow({
  label,
  value,
  trailing,
}: {
  label: string
  value: string
  trailing?: React.ReactNode
}) {
  return (
    <div className="flex items-center py-3 px-[14px] border-b border-[rgba(28,28,30,0.05)] last:border-0">
      <div className="text-[14px] text-ink-secondary w-16 flex-shrink-0">{label}</div>
      <div className="flex-1 text-[14px] text-ink">{value}</div>
      {trailing}
    </div>
  )
}

/* ── Screen ── */
function EditProfileScreen() {
  return (
    <PhoneFrame>
      {/* App bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[14px] flex-shrink-0">
          &#x2039;
        </div>
        <div className="flex-1 text-[16px] font-medium text-ink text-center">编辑资料</div>
        <div className="text-[15px] text-coral font-medium flex-shrink-0">保存</div>
      </div>

      {/* Avatar */}
      <div className="flex justify-center py-5 relative z-[1]">
        <div className="relative">
          <div className="w-[72px] h-[72px] rounded-full bg-gradient-to-br from-[rgba(140,92,246,0.25)] to-[rgba(42,126,245,0.20)] flex items-center justify-center text-white text-[28px]">
            R
          </div>
          {/* Camera badge */}
          <div className="absolute -bottom-0.5 -right-0.5 w-6 h-6 rounded-full bg-coral flex items-center justify-center shadow-[0_2px_6px_rgba(255,107,61,0.30)]">
            <Icon name="camera" size={12} className="text-white" />
          </div>
        </div>
      </div>

      {/* Form card */}
      <div className="mx-4 bg-white rounded-card-inner overflow-hidden relative z-[1]">
        <FormRow label="用户名" value="ronny" />
        <FormRow label="昵称" value="Ronny" />
        <FormRow
          label="密码"
          value="修改密码"
          trailing={<span className="text-[12px] text-ink-tertiary">&#x203A;</span>}
        />
      </div>

      {/* Help text */}
      <div className="mx-4 mt-2.5 px-1 text-[11px] text-ink-tertiary relative z-[1]">
        用户名仅用于登录，昵称显示在旅程中
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/EditProfile',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <EditProfileScreen />,
}
