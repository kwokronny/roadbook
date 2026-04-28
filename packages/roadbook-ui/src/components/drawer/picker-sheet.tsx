import React, { useState, useMemo } from 'react'
import { cn } from '@/lib/utils'
import { BottomSheetRoot, DrawerHandle, DrawerHeader, DrawerFooter, StaggerChild } from './drawer-primitives'

/* ─── Search Input ─── */

interface PickerSearchProps extends React.InputHTMLAttributes<HTMLInputElement> {}

export function PickerSearch({ className, ...props }: PickerSearchProps) {
  return (
    <div className="px-page-h mb-3">
      <div className={cn(
        'flex items-center h-10 px-3 gap-2 rounded-card-inner',
        'bg-[rgba(28,28,30,0.05)] border border-[rgba(28,28,30,0.08)]',
        'focus-within:border-[rgba(255,107,61,0.40)]',
        'transition-colors',
        className
      )}>
        <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-ink-tertiary shrink-0">
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
        <input
          className="flex-1 bg-transparent text-[14px] text-ink outline-none placeholder:text-ink-tertiary"
          {...props}
        />
      </div>
    </div>
  )
}

/* ─── Section Header ─── */

interface SectionHeaderProps {
  label: string
}

export function SectionHeader({ label }: SectionHeaderProps) {
  return (
    <div className="sticky top-0 z-10 px-page-h pt-4 pb-1 bg-frost-strong/80 backdrop-blur-sm">
      <span className="text-[12px] font-medium text-ink-tertiary">{label}</span>
    </div>
  )
}

/* ─── Picker Item ─── */

interface PickerItemProps {
  label: string
  selected?: boolean
  onClick?: () => void
}

export function PickerItem({ label, selected, onClick }: PickerItemProps) {
  return (
    <button
      className={cn(
        'w-full flex items-center gap-3 h-12 px-page-h transition-colors cursor-pointer',
        selected ? 'bg-selected-bg' : 'hover:bg-row-hover active:bg-row-hover'
      )}
      onClick={onClick}
    >
      <div
        className={cn(
          'w-5 h-5 rounded-full border-[1.5px] flex items-center justify-center transition-all ease-spring duration-[400ms]',
          selected
            ? 'bg-coral border-coral scale-100'
            : 'border-check-border scale-100'
        )}
      >
        {selected && (
          <svg width={10} height={10} viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="20 6 9 17 4 12" />
          </svg>
        )}
      </div>
      <span className={cn('text-[15px]', selected ? 'font-medium text-ink' : 'text-ink')}>{label}</span>
    </button>
  )
}

/* ─── Letter Index ─── */

interface LetterIndexProps {
  letters: string[]
  activeLetter?: string
  onSelect: (letter: string) => void
}

export function LetterIndex({ letters, activeLetter, onSelect }: LetterIndexProps) {
  return (
    <div className="absolute right-0 top-0 bottom-0 w-7 flex flex-col items-center justify-center py-2 z-20">
      {letters.map(letter => (
        <button
          key={letter}
          className={cn(
            'w-4 h-4 flex items-center justify-center text-[10px] font-medium rounded-full transition-all cursor-pointer',
            activeLetter === letter
              ? 'bg-coral text-white scale-150'
              : 'text-ink-tertiary hover:text-coral'
          )}
          onClick={() => onSelect(letter)}
        >
          {letter}
        </button>
      ))}
    </div>
  )
}

/* ─── Filter Chips ─── */

interface FilterChip {
  label: string
  value: string
}

interface FilterChipsProps {
  chips: FilterChip[]
  active: string
  onChange: (value: string) => void
}

export function FilterChips({ chips, active, onChange }: FilterChipsProps) {
  return (
    <div className="px-page-h mb-3 flex gap-2 overflow-x-auto no-scrollbar">
      {chips.map(chip => (
        <button
          key={chip.value}
          className={cn(
            'shrink-0 px-4 h-8 rounded-pill text-[13px] transition-all ease-spring duration-[400ms] cursor-pointer',
            'active:scale-[0.92]',
            active === chip.value
              ? 'bg-dark text-white'
              : 'bg-[rgba(28,28,30,0.05)] text-ink-secondary border border-[rgba(28,28,30,0.08)]'
          )}
          onClick={() => onChange(chip.value)}
        >
          {chip.label}
        </button>
      ))}
    </div>
  )
}

/* ─── Picker Sheet (Pre-composed) ─── */

interface PickerSheetProps {
  open: boolean
  onClose: () => void
  title: string
  subtitle?: string
  selectedCount?: number
  itemLabel?: string
  ctaLabel?: string
  onConfirm?: () => void
  children: React.ReactNode
}

export function PickerSheet({
  open,
  onClose,
  title,
  subtitle,
  selectedCount = 0,
  itemLabel = '项',
  ctaLabel = '确定',
  onConfirm,
  children,
}: PickerSheetProps) {
  return (
    <BottomSheetRoot open={open} onClose={onClose} maxHeight="70%">
      <DrawerHandle />
      <DrawerHeader title={title} subtitle={subtitle} onClose={onClose} />
      <div className="flex-1 overflow-y-auto mt-3 relative">
        {children}
      </div>
      <DrawerFooter>
        <div className="flex items-center justify-between">
          <p className="text-[13px] text-ink-secondary">
            已选 <span className="font-medium text-coral">{selectedCount}</span> 个{itemLabel}
          </p>
          <button
            className={cn(
              'px-6 h-10 rounded-pill text-[15px] transition-transform active:scale-[0.92] ease-spring duration-[400ms] cursor-pointer',
              selectedCount > 0
                ? 'bg-dark text-white'
                : 'bg-[rgba(28,28,30,0.12)] text-ink-tertiary cursor-not-allowed'
            )}
            disabled={selectedCount === 0}
            onClick={onConfirm}
          >
            {ctaLabel} →
          </button>
        </div>
      </DrawerFooter>
    </BottomSheetRoot>
  )
}
