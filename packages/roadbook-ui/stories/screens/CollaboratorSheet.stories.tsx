import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

/* ── Member Row ── */
function MemberRow({
  letter,
  color,
  name,
  role,
  roleBg,
  roleColor,
}: {
  letter: string
  color: string
  name: string
  role: string
  roleBg: string
  roleColor: string
}) {
  return (
    <div className="flex items-center py-2.5 px-[14px] border-b border-[rgba(28,28,30,0.05)] last:border-0">
      {/* Avatar */}
      <div
        className="w-9 h-9 rounded-full flex items-center justify-center text-white text-[14px] font-medium flex-shrink-0"
        style={{ background: color }}
      >
        {letter}
      </div>
      {/* Name */}
      <div className="flex-1 ml-2.5 text-[14px] text-ink font-medium">{name}</div>
      {/* Role badge */}
      <div
        className="py-0.5 px-2 rounded-pill text-[10px] font-medium"
        style={{ background: roleBg, color: roleColor }}
      >
        {role}
      </div>
    </div>
  )
}

/* ── Screen ── */
function CollaboratorSheetScreen() {
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
        <div className="flex items-center px-4 pb-3 relative z-[1]">
          <div className="flex-1 text-[18px] font-medium text-ink">协作者管理</div>
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="close" size={16} className="text-ink-tertiary" />
          </div>
        </div>

        {/* Invite link pill */}
        <div className="mx-4 mb-3 relative z-[1]">
          <div className="flex items-center justify-center gap-1.5 py-2.5 px-4 rounded-pill bg-[rgba(28,28,30,0.05)] border border-[rgba(28,28,30,0.08)] text-[13px] text-ink">
            <Icon name="link" size={14} className="text-ink-secondary" />
            复制邀请链接
          </div>
        </div>

        {/* Member list */}
        <div className="mx-4 bg-white rounded-card-inner overflow-hidden relative z-[1]">
          <MemberRow
            letter="R"
            color="var(--coral)"
            name="Ronny"
            role="管理者"
            roleBg="rgba(255,107,61,0.10)"
            roleColor="var(--coral)"
          />
          <MemberRow
            letter="L"
            color="#8C5CF6"
            name="Lisa"
            role="编辑者 ▾"
            roleBg="rgba(140,92,246,0.10)"
            roleColor="#8C5CF6"
          />
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/CollaboratorSheet',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <CollaboratorSheetScreen />,
}
