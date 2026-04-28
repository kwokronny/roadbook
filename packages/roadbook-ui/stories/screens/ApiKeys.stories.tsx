import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { Icon } from '@/components/icon'

/* ── API Key Card ── */
function ApiKeyCard({
  name,
  maskedKey,
  lastUsed,
}: {
  name: string
  maskedKey: string
  lastUsed: string
}) {
  return (
    <GlassCard variant="frost" className="mx-4 mb-2.5 p-[14px]">
      <div className="flex items-start gap-2.5">
        {/* Key icon */}
        <div className="w-9 h-9 rounded-[10px] bg-[rgba(140,92,246,0.10)] border border-[rgba(140,92,246,0.15)] flex items-center justify-center flex-shrink-0">
          <Icon name="key" size={18} className="text-[#8C5CF6]" />
        </div>
        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="text-[15px] font-medium text-ink">{name}</div>
          <div className="text-[12px] text-ink-tertiary mt-0.5 font-mono truncate">{maskedKey}</div>
          <div className="text-[11px] text-ink-tertiary mt-1">上次使用: {lastUsed}</div>
        </div>
        {/* Delete */}
        <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.05)] flex items-center justify-center flex-shrink-0">
          <Icon name="trash" size={15} className="text-destructive" />
        </div>
      </div>
    </GlassCard>
  )
}

/* ── Screen ── */
function ApiKeysScreen() {
  return (
    <PhoneFrame>
      {/* App bar */}
      <div className="pt-11 px-4 pb-2 flex items-center gap-2 relative z-[1]">
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[14px] flex-shrink-0">
          &#x2039;
        </div>
        <div className="flex-1 text-[16px] font-medium text-ink text-center">API Key 管理</div>
        <div className="w-8 h-8 rounded-full bg-dark text-white flex items-center justify-center text-[16px] flex-shrink-0">
          ＋
        </div>
      </div>

      {/* Key cards */}
      <div className="mt-2 relative z-[1]">
        <ApiKeyCard
          name="Claude MCP"
          maskedKey="sk-rb-****...7f3a"
          lastUsed="2026-04-12"
        />
        <ApiKeyCard
          name="Cursor Agent"
          maskedKey="sk-rb-****...b2e1"
          lastUsed="2026-04-08"
        />
      </div>

      {/* Help text */}
      <div className="mx-4 mt-3 text-[11px] text-ink-tertiary text-center relative z-[1] leading-relaxed">
        创建 API Key 后可让 AI 助手通过 MCP 协议管理你的行程
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/ApiKeys',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <ApiKeysScreen />,
}
