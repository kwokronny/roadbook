import type { Meta, StoryObj } from '@storybook/react'
import React, { useState } from 'react'
import { SideDrawer } from '@/components/drawer'
import { PhoneFrame } from '@/components/phone-frame'
import { GlassCard } from '@/components/glass-card'
import { Badge } from '@/components/ui/badge'
import { Icon } from '@/components/icon'
import { TimeBadge } from '@/components/time-badge'

const meta: Meta = {
  title: 'Drawers/SideDrawer',
}

export default meta

/* ─── Schedule Detail ─── */

export const ScheduleDetail: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">Day 1 · 东京</p>
            <p className="text-[13px] text-ink-secondary mt-1">点击行程单查看详情</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            浅草寺详情 →
          </button>

          <SideDrawer
            open={open}
            onClose={() => setOpen(false)}
            title="行程详情"
            action={
              <button className="w-8 h-8 rounded-full bg-close-bg flex items-center justify-center cursor-pointer active:scale-[0.88] transition-transform ease-spring duration-[400ms]">
                <Icon name="edit" size={14} className="text-ink-secondary" />
              </button>
            }
          >
            {/* Cover */}
            <div className="mb-4 w-full h-40 rounded-card-inner bg-[rgba(28,28,30,0.04)] flex items-center justify-center overflow-hidden">
              <div className="text-center">
                <span className="text-4xl">⛩</span>
                <p className="text-[12px] text-ink-tertiary mt-2">浅草寺</p>
              </div>
            </div>

            {/* Info */}
            <div className="space-y-3">
              <div>
                <h4 className="text-[17px] font-medium text-ink">浅草寺</h4>
                <p className="text-[13px] text-ink-secondary mt-0.5">东京都台东区浅草2-3-1</p>
              </div>

              <div className="flex gap-2">
                <TimeBadge time="09:00" />
                <Badge variant="ongoing">Day 1</Badge>
              </div>

              <div className="h-px bg-divider" />

              <div>
                <p className="text-[12px] text-ink-tertiary mb-1">备注</p>
                <p className="text-[14px] text-ink-secondary leading-relaxed">
                  早上8点出发，步行约15分钟到达。记得先去本堂参拜，然后逛仲见世通商店街。推荐买人形烧作为伴手礼。
                </p>
              </div>

              <div className="h-px bg-divider" />

              <div>
                <p className="text-[12px] text-ink-tertiary mb-2">照片</p>
                <div className="grid grid-cols-3 gap-2">
                  {[1, 2, 3].map(i => (
                    <div key={i} className="aspect-square rounded-[10px] bg-[rgba(28,28,30,0.04)] flex items-center justify-center">
                      <Icon name="image" size={20} className="text-ink-tertiary" />
                    </div>
                  ))}
                </div>
              </div>

              <div className="h-px bg-divider" />

              <div>
                <p className="text-[12px] text-ink-tertiary mb-2">点评信息</p>
                <GlassCard className="p-3">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-full bg-coral-tint flex items-center justify-center">
                      <span className="text-[14px]">⭐</span>
                    </div>
                    <div>
                      <p className="text-[14px] font-medium text-ink">4.7 分</p>
                      <p className="text-[11px] text-ink-tertiary">大众点评 · 28961 条评价</p>
                    </div>
                  </div>
                </GlassCard>
              </div>
            </div>
          </SideDrawer>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Photo Viewer ─── */

export const PhotoViewer: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)

    const photos = Array.from({ length: 6 }, (_, i) => i + 1)

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">旅程照片</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            查看全部照片
          </button>

          <SideDrawer
            open={open}
            onClose={() => setOpen(false)}
            title="全部照片"
            action={
              <span className="text-[13px] text-ink-secondary">6 张</span>
            }
          >
            <div className="grid grid-cols-2 gap-2">
              {photos.map(i => (
                <div
                  key={i}
                  className="aspect-[4/3] rounded-card-inner bg-[rgba(28,28,30,0.04)] flex items-center justify-center"
                >
                  <div className="text-center">
                    <Icon name="image" size={24} className="text-ink-tertiary" />
                    <p className="text-[10px] text-ink-tertiary mt-1">照片 {i}</p>
                  </div>
                </div>
              ))}
            </div>
          </SideDrawer>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Luggage Detail ─── */

export const LuggageList: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)

    const items = [
      { name: '护照', packed: true },
      { name: '充电器', packed: true },
      { name: '转换插头', packed: false },
      { name: '洗漱包', packed: false },
      { name: '相机', packed: true },
      { name: '雨伞', packed: false },
      { name: '防晒霜', packed: false },
      { name: '药品', packed: true },
    ]

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">行李清单</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            查看行李清单
          </button>

          <SideDrawer
            open={open}
            onClose={() => setOpen(false)}
            title="行李清单"
            action={
              <span className="text-[13px] text-coral">{items.filter(i => i.packed).length}/{items.length}</span>
            }
          >
            <div className="space-y-1">
              {items.map((item, i) => (
                <div
                  key={i}
                  className="flex items-center gap-3 h-11 px-1 rounded-[10px] hover:bg-row-hover transition-colors cursor-pointer"
                >
                  <div
                    className={`w-5 h-5 rounded-full border-[1.5px] flex items-center justify-center transition-all ease-spring duration-[400ms] ${
                      item.packed
                        ? 'bg-coral border-coral'
                        : 'border-check-border'
                    }`}
                  >
                    {item.packed && (
                      <svg width={10} height={10} viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                    )}
                  </div>
                  <span className={`text-[15px] ${item.packed ? 'text-ink-tertiary line-through' : 'text-ink'}`}>
                    {item.name}
                  </span>
                </div>
              ))}
            </div>
          </SideDrawer>
        </div>
      </PhoneFrame>
    )
  },
}
