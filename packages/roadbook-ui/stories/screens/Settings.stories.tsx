import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { Icon } from '@/components/icon'

/* ── Setting Row ── */
function SettingRow({
  label,
  trailing,
}: {
  label: string
  trailing?: React.ReactNode
}) {
  return (
    <div className="flex items-center py-2.5 px-[14px] border-b border-[rgba(28,28,30,0.05)] last:border-0">
      <div className="text-[14px] flex-1 text-ink">{label}</div>
      {trailing ?? <span className="text-[12px] text-ink-tertiary">&#x203A;</span>}
    </div>
  )
}

/* ── Toggle ── */
function Toggle({ on }: { on: boolean }) {
  return (
    <div
      className={`w-[42px] h-[26px] rounded-pill relative transition-colors ${
        on ? 'bg-coral' : 'bg-[rgba(28,28,30,0.12)]'
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

/* ── Section Label ── */
function SectionLabel({ children }: { children: React.ReactNode }) {
  return (
    <div className="mx-4 mb-1.5 mt-3 px-1 text-[12px] text-ink-tertiary font-medium relative z-[1]">
      {children}
    </div>
  )
}

/* ── Screen ── */
function SettingsScreen() {
  return (
    <PhoneFrame>
      {/* App bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[14px] flex-shrink-0">
          &#x2039;
        </div>
        <div className="flex-1 text-[16px] font-medium text-ink text-center">设置</div>
        <div className="w-8 flex-shrink-0" />
      </div>

      {/* Section: 通用 */}
      <SectionLabel>通用</SectionLabel>
      <GlassCard variant="frost" className="mx-4 !p-0">
        <SettingRow
          label="深色模式"
          trailing={<Toggle on={false} />}
        />
        <SettingRow
          label="语言"
          trailing={
            <div className="flex items-center gap-1">
              <span className="text-[13px] text-ink-tertiary">简体中文</span>
              <span className="text-[12px] text-ink-tertiary">&#x203A;</span>
            </div>
          }
        />
      </GlassCard>

      {/* Section: 存储 */}
      <SectionLabel>存储</SectionLabel>
      <GlassCard variant="frost" className="mx-4 !p-0">
        <SettingRow
          label="清除缓存"
          trailing={
            <span className="text-[13px] text-ink-tertiary">12.5 MB</span>
          }
        />
      </GlassCard>

      {/* Section: 关于 */}
      <SectionLabel>关于</SectionLabel>
      <GlassCard variant="frost" className="mx-4 !p-0">
        <SettingRow
          label="版本"
          trailing={
            <span className="text-[13px] text-ink-tertiary">v1.0.6</span>
          }
        />
        <SettingRow label="反馈" />
      </GlassCard>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/Settings',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <SettingsScreen />,
}
