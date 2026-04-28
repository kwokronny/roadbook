import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { GlassCard } from '@/components/glass-card'

/* ── Screen ── */
function SignInScreen() {
  return (
    <div className="w-[320px] rounded-[32px] overflow-hidden border-[3px] border-[rgba(28,28,30,0.06)] shadow-[0_20px_60px_rgba(28,28,30,0.10)] flex-shrink-0">
      <div className="min-h-[640px] relative overflow-hidden">
        {/* Background: warm beach gradient placeholder */}
        <div className="absolute inset-0 bg-gradient-to-br from-[#F5C07A] via-[#E8845C] to-[#D45B7A]" />
        {/* Warm overlay + blur layer */}
        <div className="absolute inset-0 bg-[rgba(245,190,130,0.25)] backdrop-blur-[2px]" />

        {/* Ambient orbs (separate from PhoneFrame defaults) */}
        <div className="absolute w-[200px] h-[200px] rounded-full blur-[60px] bg-[rgba(255,220,180,0.35)] -top-[5%] -left-[10%]" />
        <div className="absolute w-[180px] h-[180px] rounded-full blur-[50px] bg-[rgba(255,107,61,0.20)] bottom-[20%] -right-[12%]" />
        <div className="absolute w-[140px] h-[140px] rounded-full blur-[45px] bg-[rgba(214,130,180,0.18)] top-[40%] left-[5%]" />

        {/* Content */}
        <div className="relative z-[1] flex flex-col min-h-[640px]">
          {/* Title area */}
          <div className="pt-28 px-6 mb-8">
            <div className="text-[34px] font-extralight text-white tracking-tight leading-tight">
              小肥路书
            </div>
            <div className="text-[14px] text-white/70 mt-1.5">
              登录你的旅行计划
            </div>
          </div>

          {/* Login card */}
          <GlassCard variant="frost" className="mx-5 p-5">
            {/* Username */}
            <div className="mb-3.5">
              <div className="text-[12px] text-ink-secondary mb-1.5 font-medium">用户名</div>
              <input
                type="text"
                placeholder="输入用户名"
                className="w-full py-2.5 px-3 rounded-card-inner bg-white/80 border border-[rgba(28,28,30,0.08)] text-[14px] text-ink placeholder:text-ink-tertiary outline-none"
              />
            </div>

            {/* Password */}
            <div className="mb-5">
              <div className="text-[12px] text-ink-secondary mb-1.5 font-medium">密码</div>
              <input
                type="password"
                placeholder="输入密码"
                className="w-full py-2.5 px-3 rounded-card-inner bg-white/80 border border-[rgba(28,28,30,0.08)] text-[14px] text-ink placeholder:text-ink-tertiary outline-none"
              />
            </div>

            {/* CTA */}
            <button className="w-full py-3 rounded-pill bg-dark text-white text-[15px] font-medium text-center">
              登录 →
            </button>
          </GlassCard>

          {/* Register link */}
          <div className="text-center mt-4 text-[13px] text-white/70">
            没有账号？<span className="text-coral font-medium">注册</span>
          </div>
        </div>
      </div>
    </div>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/SignIn',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <SignInScreen />,
}
