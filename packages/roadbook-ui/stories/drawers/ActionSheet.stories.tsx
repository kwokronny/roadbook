import type { Meta, StoryObj } from '@storybook/react'
import React, { useState } from 'react'
import { ActionSheet, ActionItem, ConfirmSheet } from '@/components/drawer'
import { Icon } from '@/components/icon'
import { PhoneFrame } from '@/components/phone-frame'

const meta: Meta = {
  title: 'Drawers/ActionSheet',
}

export default meta

/* ─── Actions List ─── */

export const ActionsMenu: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)
    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">东京五日游</p>
            <p className="text-[13px] text-ink-secondary mt-1">2026.04.20 – 2026.04.24</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            更多操作
          </button>

          <ActionSheet open={open} onClose={() => setOpen(false)} title="旅程操作">
            <ActionItem
              icon={<Icon name="edit" size={18} />}
              label="编辑旅程"
              onClick={() => setOpen(false)}
            />
            <ActionItem
              icon={<Icon name="users" size={18} />}
              label="协作者管理"
              onClick={() => setOpen(false)}
            />
            <ActionItem
              icon={<Icon name="copy" size={18} />}
              label="复制邀请链接"
              onClick={() => setOpen(false)}
            />
            <ActionItem
              icon={<Icon name="trash" size={18} />}
              label="删除旅程"
              destructive
              onClick={() => setOpen(false)}
            />
          </ActionSheet>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Confirm Delete ─── */

export const ConfirmDelete: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)
    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">东京五日游</p>
            <p className="text-[13px] text-ink-secondary mt-1">确认删除示例</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-[#D4410A] text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            删除旅程
          </button>

          <ConfirmSheet
            open={open}
            onClose={() => setOpen(false)}
            title="确定删除这个旅程吗？"
            subtitle="删除后无法恢复，所有行程单和照片都将丢失"
            confirmLabel="删除"
            destructive
            onConfirm={() => setOpen(false)}
          />
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Confirm Save ─── */

export const ConfirmSave: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)
    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">编辑行程单</p>
            <p className="text-[13px] text-ink-secondary mt-1">非破坏性确认示例</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            放弃编辑？
          </button>

          <ConfirmSheet
            open={open}
            onClose={() => setOpen(false)}
            title="放弃当前编辑？"
            subtitle="已编辑的内容将不会保存"
            cancelLabel="继续编辑"
            confirmLabel="放弃"
            onConfirm={() => setOpen(false)}
          />
        </div>
      </PhoneFrame>
    )
  },
}
