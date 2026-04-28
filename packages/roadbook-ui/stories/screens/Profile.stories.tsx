import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
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

/* ── Menu Item ── */
function MenuItem({
  iconBg,
  iconName,
  label,
  trailing,
}: {
  iconBg: string
  iconName: string
  label: string
  trailing?: React.ReactNode
}) {
  return (
    <div className="flex items-center py-2.5 px-[14px] gap-2.5 relative z-[1]">
      <div
        className="w-6 h-6 rounded-[7px] flex items-center justify-center flex-shrink-0"
        style={{ background: iconBg }}
      >
        <Icon name={iconName} size={14} className="text-white" />
      </div>
      <div className="text-[14px] flex-1 text-ink">{label}</div>
      {trailing ?? <span className="text-[12px] text-ink-tertiary">&#x203A;</span>}
    </div>
  )
}

/* ── Menu Divider ── */
function MenuDivider() {
  return <div className="ml-12 border-t border-[rgba(28,28,30,0.05)]" />
}

/* ── Screen ── */
function ProfileScreen() {
  return (
    <PhoneFrame>
      {/* Adjust orbs for profile screen */}
      <div className="absolute w-[240px] h-[240px] rounded-full blur-[50px] bg-[rgba(255,107,61,0.08)] -top-[8%] -right-[10%]" />
      <div className="absolute w-[180px] h-[180px] rounded-full blur-[50px] bg-[rgba(245,210,170,0.12)] bottom-[15%] -left-[8%]" />

      {/* Title bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
        <div className="flex-1 text-[30px] font-extralight tracking-tight text-ink">我的</div>
      </div>

      {/* User card */}
      <GlassCard variant="frost" className="mx-4 mb-2 p-[14px]">
        <div className="flex items-center gap-2.5">
          {/* Avatar */}
          <div className="w-11 h-11 rounded-full bg-gradient-to-br from-[rgba(140,92,246,0.25)] to-[rgba(42,126,245,0.20)] flex items-center justify-center text-white text-[18px]">
            R
          </div>
          {/* Name + stats */}
          <div className="flex-1">
            <div className="text-[16px] font-medium text-ink">Ronny</div>
            <div className="flex gap-3.5 mt-1">
              <div className="text-center">
                <div className="text-[15px] font-medium text-ink">5</div>
                <div className="text-[10px] text-ink-tertiary">旅程</div>
              </div>
              <div className="text-center">
                <div className="text-[15px] font-medium text-ink">12</div>
                <div className="text-[10px] text-ink-tertiary">城市</div>
              </div>
              <div className="text-center">
                <div className="text-[15px] font-medium text-ink">38</div>
                <div className="text-[10px] text-ink-tertiary">天数</div>
              </div>
            </div>
          </div>
          {/* Chevron */}
          <span className="text-[14px] text-ink-tertiary">&#x203A;</span>
        </div>
      </GlassCard>

      {/* Menu card */}
      <GlassCard variant="frost" className="mx-4 mb-2 !p-0">
        <MenuItem
          iconBg="var(--coral)"
          iconName="message"
          label="消息中心"
          trailing={
            <span className="py-0.5 px-1.5 rounded-pill bg-[rgba(232,56,122,0.08)] border border-[rgba(232,56,122,0.15)] text-[9px] text-[#C02060]">
              即将推出
            </span>
          }
        />
        <MenuDivider />
        <MenuItem iconBg="#34C759" iconName="edit" label="编辑资料" />
        <MenuDivider />
        <MenuItem iconBg="var(--ink-secondary)" iconName="settings" label="设置" />
        <MenuDivider />
        <MenuItem iconBg="#8C5CF6" iconName="key" label="API Key 管理" />
      </GlassCard>

      {/* Spacer */}
      <div className="h-2" />

      {/* Logout card */}
      <GlassCard variant="frost" className="mx-4 !p-0">
        <div className="flex items-center justify-center py-2.5 px-[14px] relative z-[1]">
          <div className="text-[14px] text-center text-destructive font-medium">退出登录</div>
        </div>
      </GlassCard>

      {/* Dock */}
      <Dock activeTab="profile" />
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/Profile',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <ProfileScreen />,
}
