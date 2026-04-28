import type { Meta, StoryObj } from '@storybook/react'
import React, { useState } from 'react'
import { FormSheet, FormGroup, FormRow, FormInput, FormTextarea, FormSelector, FormToggle } from '@/components/drawer'
import { PhoneFrame } from '@/components/phone-frame'
import { Badge } from '@/components/ui/badge'

const meta: Meta = {
  title: 'Drawers/FormSheet',
}

export default meta

/* ─── Create Travel ─── */

export const CreateTravel: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)
    const [isPublic, setIsPublic] = useState(false)

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[34px] font-extralight text-ink tracking-tight">旅程</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            创建旅程 +
          </button>

          <FormSheet
            open={open}
            onClose={() => setOpen(false)}
            title="创建旅程"
            ctaLabel="创建"
            onSubmit={() => setOpen(false)}
          >
            <FormGroup>
              <FormRow label="名称">
                <FormInput placeholder="输入旅程名称" />
              </FormRow>
              <FormSelector label="日期" value="04.20 – 04.24" />
              <FormSelector label="城市" placeholder="选择目的地" />
              <FormToggle label="公开" checked={isPublic} onChange={setIsPublic} showDivider={false} />
            </FormGroup>
          </FormSheet>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Edit Schedule ─── */

export const EditSchedule: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">Day 1 · 东京</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            编辑行程单
          </button>

          <FormSheet
            open={open}
            onClose={() => setOpen(false)}
            title="编辑行程单"
            ctaLabel="保存"
            onSubmit={() => setOpen(false)}
          >
            <FormGroup>
              <div className="flex gap-2 px-4 py-3">
                <button className="px-4 h-8 rounded-pill bg-coral text-white text-[13px] cursor-pointer">
                  景点
                </button>
                <button className="px-4 h-8 rounded-pill bg-[rgba(28,28,30,0.05)] text-ink-secondary text-[13px] border border-[rgba(28,28,30,0.08)] cursor-pointer">
                  住宿
                </button>
              </div>
              <div className="h-px bg-divider" />
              <FormRow label="名称">
                <FormInput placeholder="输入名称" defaultValue="浅草寺" />
              </FormRow>
              <FormSelector label="时间" value="Day 1 · 09:00" />
              <FormRow label="截图" showDivider={false}>
                <div className="flex justify-end">
                  <div className="w-12 h-12 rounded-[10px] bg-[rgba(28,28,30,0.05)] border border-dashed border-[rgba(28,28,30,0.12)] flex items-center justify-center text-ink-tertiary text-[20px]">
                    +
                  </div>
                </div>
              </FormRow>
            </FormGroup>

            <FormGroup label="备注">
              <FormTextarea placeholder="添加备注信息..." defaultValue="早上8点出发，步行约15分钟到达。建议穿舒适的鞋子。" />
            </FormGroup>
          </FormSheet>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Form With Errors ─── */

export const FormWithErrors: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">表单验证示例</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            打开表单
          </button>

          <FormSheet
            open={open}
            onClose={() => setOpen(false)}
            title="创建旅程"
            ctaLabel="创建"
            ctaDisabled
            onSubmit={() => {}}
          >
            <FormGroup>
              <FormRow label="名称">
                <FormInput placeholder="输入旅程名称" error="请输入旅程名称" />
              </FormRow>
              <FormSelector label="日期" placeholder="请选择日期" />
              <FormSelector label="城市" placeholder="请选择城市" showDivider={false} />
            </FormGroup>
          </FormSheet>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Hotel Edit (Type variant) ─── */

export const HotelSchedule: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">Day 2 · 东京</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            添加住宿
          </button>

          <FormSheet
            open={open}
            onClose={() => setOpen(false)}
            title="编辑住宿"
            ctaLabel="保存"
            onSubmit={() => setOpen(false)}
          >
            <FormGroup>
              <div className="flex gap-2 px-4 py-3">
                <button className="px-4 h-8 rounded-pill bg-[rgba(28,28,30,0.05)] text-ink-secondary text-[13px] border border-[rgba(28,28,30,0.08)] cursor-pointer">
                  景点
                </button>
                <button className="px-4 h-8 rounded-pill bg-lavender-tint text-lavender-text text-[13px] border border-lavender/20 cursor-pointer">
                  住宿
                </button>
              </div>
              <div className="h-px bg-divider" />
              <FormRow label="名称">
                <FormInput defaultValue="新宿华盛顿酒店" />
              </FormRow>
              <FormSelector label="入住" value="Day 2 · 15:00" />
              <FormSelector label="退房" value="Day 4 · 11:00" showDivider={false} />
            </FormGroup>

            <FormGroup label="备注">
              <FormTextarea placeholder="添加备注信息..." defaultValue="含早餐，大堂有行李寄存" />
            </FormGroup>
          </FormSheet>
        </div>
      </PhoneFrame>
    )
  },
}
