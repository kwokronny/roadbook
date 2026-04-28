import type { Meta, StoryObj } from '@storybook/react'
import React, { useState } from 'react'
import { PickerSheet, PickerSearch, PickerItem, SectionHeader, LetterIndex, FilterChips } from '@/components/drawer'
import { PhoneFrame } from '@/components/phone-frame'

const meta: Meta = {
  title: 'Drawers/PickerSheet',
}

export default meta

/* ─── City Picker ─── */

const cityData: Record<string, string[]> = {
  B: ['北京', '保定', '包头'],
  C: ['成都', '重庆', '长沙', '长春'],
  D: ['大连', '大理', '东莞'],
  G: ['广州', '贵阳', '桂林'],
  H: ['杭州', '合肥', '哈尔滨', '海口'],
  K: ['昆明', '开封'],
  N: ['南京', '南宁', '宁波'],
  Q: ['青岛', '泉州'],
  S: ['上海', '深圳', '苏州', '三亚', '沈阳'],
  T: ['天津', '太原'],
  W: ['武汉', '无锡', '温州'],
  X: ['西安', '厦门', '西宁'],
  Z: ['郑州', '珠海'],
}

export const CityPicker: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)
    const [selected, setSelected] = useState<string[]>(['东京', '大阪'])
    const [search, setSearch] = useState('')

    const toggle = (city: string) => {
      setSelected(prev =>
        prev.includes(city) ? prev.filter(c => c !== city) : [...prev, city]
      )
    }

    const letters = Object.keys(cityData)

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">创建旅程</p>
            <p className="text-[13px] text-ink-secondary mt-1">选择目的地城市</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            选择城市
          </button>

          <PickerSheet
            open={open}
            onClose={() => setOpen(false)}
            title="选择城市"
            selectedCount={selected.length}
            itemLabel="城市"
            onConfirm={() => setOpen(false)}
          >
            <PickerSearch
              placeholder="搜索城市"
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            <div className="relative">
              {letters.map(letter => (
                <div key={letter}>
                  <SectionHeader label={letter} />
                  {cityData[letter].map(city => (
                    <PickerItem
                      key={city}
                      label={city}
                      selected={selected.includes(city)}
                      onClick={() => toggle(city)}
                    />
                  ))}
                </div>
              ))}
              <LetterIndex
                letters={letters}
                onSelect={() => {}}
              />
            </div>
          </PickerSheet>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Quick Time Picker ─── */

const hours = Array.from({ length: 24 }, (_, i) => `${String(i).padStart(2, '0')}:00`)

export const TimePicker: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)
    const [selectedDay, setSelectedDay] = useState(1)
    const [selectedHour, setSelectedHour] = useState('09:00')
    const [filter, setFilter] = useState('all')

    const days = [
      { label: 'Day 1', sub: '周一' },
      { label: 'Day 2', sub: '周二' },
      { label: 'Day 3', sub: '周三' },
      { label: 'Day 4', sub: '周四' },
      { label: 'Day 5', sub: '周五' },
    ]

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">设置时间</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            选择时间
          </button>

          <PickerSheet
            open={open}
            onClose={() => setOpen(false)}
            title="选择时间"
            selectedCount={1}
            itemLabel="时间"
            onConfirm={() => setOpen(false)}
          >
            {/* Day row */}
            <div className="px-page-h mb-3 flex gap-2 overflow-x-auto no-scrollbar">
              {days.map((day, i) => (
                <button
                  key={i}
                  className={`shrink-0 w-16 py-2 rounded-[12px] text-center transition-all ease-spring duration-[400ms] cursor-pointer active:scale-[0.92] ${
                    selectedDay === i + 1
                      ? 'bg-coral-tint border border-coral/20'
                      : 'bg-[rgba(28,28,30,0.05)]'
                  }`}
                  onClick={() => setSelectedDay(i + 1)}
                >
                  <p className={`text-[13px] font-medium ${selectedDay === i + 1 ? 'text-coral' : 'text-ink-tertiary'}`}>
                    {day.label}
                  </p>
                  <p className={`text-[10px] mt-0.5 ${selectedDay === i + 1 ? 'text-coral/70' : 'text-ink-tertiary'}`}>
                    {day.sub}
                  </p>
                </button>
              ))}
            </div>

            {/* Hour grid */}
            <div className="px-page-h grid grid-cols-4 gap-2">
              {hours.slice(6, 22).map(hour => (
                <button
                  key={hour}
                  className={`h-9 rounded-[8px] text-[13px] transition-all ease-spring duration-[400ms] cursor-pointer active:scale-[0.92] ${
                    selectedHour === hour
                      ? 'bg-coral-tint border border-coral/20 text-coral font-medium'
                      : 'bg-[rgba(28,28,30,0.05)] text-ink-tertiary'
                  }`}
                  onClick={() => setSelectedHour(hour)}
                >
                  {hour}
                </button>
              ))}
            </div>
          </PickerSheet>
        </div>
      </PhoneFrame>
    )
  },
}

/* ─── Collaborator Picker ─── */

export const CollaboratorPicker: StoryObj = {
  render: () => {
    const [open, setOpen] = useState(true)
    const [selected, setSelected] = useState<string[]>(['小明'])

    const collaborators = ['小明', '小红', '小华', '张三', '李四', '王五']

    const toggle = (name: string) => {
      setSelected(prev =>
        prev.includes(name) ? prev.filter(n => n !== name) : [...prev, name]
      )
    }

    return (
      <PhoneFrame>
        <div className="relative h-full">
          <div className="p-page-h pt-16">
            <p className="text-[22px] font-light text-ink tracking-tight">协作者</p>
          </div>

          <button
            className="mx-page-h mt-6 px-5 h-11 rounded-pill bg-dark text-white text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
            onClick={() => setOpen(true)}
          >
            邀请协作者
          </button>

          <PickerSheet
            open={open}
            onClose={() => setOpen(false)}
            title="邀请协作者"
            subtitle="选择要邀请的好友"
            selectedCount={selected.length}
            itemLabel="人"
            ctaLabel="邀请"
            onConfirm={() => setOpen(false)}
          >
            <PickerSearch placeholder="搜索好友" />

            <FilterChips
              chips={[
                { label: '全部', value: 'all' },
                { label: '最近', value: 'recent' },
                { label: '常用', value: 'frequent' },
              ]}
              active="all"
              onChange={() => {}}
            />

            {collaborators.map(name => (
              <PickerItem
                key={name}
                label={name}
                selected={selected.includes(name)}
                onClick={() => toggle(name)}
              />
            ))}
          </PickerSheet>
        </div>
      </PhoneFrame>
    )
  },
}
