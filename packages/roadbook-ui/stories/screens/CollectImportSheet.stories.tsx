import type { Meta, StoryObj } from '@storybook/react'
import React from 'react'
import { PhoneFrame } from '@/components/phone-frame'
import { Icon } from '@/components/icon'

/* ── Screen ── */
function CollectImportSheetScreen() {
  return (
    <PhoneFrame>
      {/* Dimmed overlay */}
      <div className="absolute inset-0 bg-[rgba(0,0,0,0.35)] z-[2]" />

      {/* Bottom sheet */}
      <div className="absolute bottom-0 left-0 right-0 h-[50%] bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8] border-t border-white/55 rounded-t-sheet z-[3] flex flex-col overflow-hidden">
        <div
          className="absolute inset-0 rounded-[inherit] pointer-events-none"
          style={{ background: 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)' }}
        />

        {/* Handle */}
        <div className="flex justify-center pt-2 pb-1 relative z-[1]">
          <div className="w-9 h-1 rounded-pill bg-[rgba(28,28,30,0.15)]" />
        </div>

        {/* Header */}
        <div className="flex items-center px-4 pb-2 relative z-[1]">
          <div className="flex-1 text-[18px] font-medium text-ink">批量导入</div>
          <div className="w-8 h-8 rounded-full bg-[rgba(28,28,30,0.06)] flex items-center justify-center">
            <Icon name="close" size={16} className="text-ink-tertiary" />
          </div>
        </div>

        {/* Description */}
        <div className="px-4 pb-3 text-[13px] text-ink-secondary relative z-[1]">
          粘贴大众点评收藏夹的分享链接
        </div>

        {/* URL input area */}
        <div className="mx-4 flex-1 relative z-[1]">
          <div className="w-full h-28 rounded-card-inner bg-[rgba(28,28,30,0.03)] border-2 border-dashed border-[rgba(28,28,30,0.12)] p-3 text-[13px] text-ink-tertiary leading-relaxed">
            https://m.dianping.com/...
          </div>
        </div>

        {/* CTA */}
        <div className="px-4 pb-6 pt-3 relative z-[1]">
          <button className="w-full py-3 rounded-pill bg-dark text-white text-[15px] font-medium text-center">
            开始导入 →
          </button>
        </div>
      </div>
    </PhoneFrame>
  )
}

/* ── Storybook ── */
const meta: Meta = {
  title: 'Screens/CollectImportSheet',
  parameters: {
    layout: 'centered',
    backgrounds: { default: 'canvas' },
  },
}

export default meta
type Story = StoryObj

export const Default: Story = {
  render: () => <CollectImportSheetScreen />,
}
