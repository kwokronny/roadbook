import React from 'react'
import { cn } from '@/lib/utils'
import { BottomSheetRoot, DrawerHandle, DrawerHeader, DrawerFooter, StaggerChild } from './drawer-primitives'

/* ─── Action Item ─── */

interface ActionItemProps {
  icon?: React.ReactNode
  label: string
  destructive?: boolean
  onClick?: () => void
}

export function ActionItem({ icon, label, destructive, onClick }: ActionItemProps) {
  return (
    <button
      className={cn(
        'w-full flex items-center gap-3 h-12 px-page-h rounded-[12px] transition-colors cursor-pointer',
        destructive
          ? 'text-[#D4410A] hover:bg-row-hover-destructive active:bg-row-hover-destructive'
          : 'text-ink hover:bg-row-hover active:bg-row-hover'
      )}
      onClick={onClick}
    >
      {icon && <span className={cn('w-5 h-5 flex items-center justify-center', destructive ? 'text-[#D4410A]' : 'text-ink-secondary')}>{icon}</span>}
      <span className={cn('text-[15px]', destructive ? 'font-medium' : 'font-normal')}>{label}</span>
    </button>
  )
}

/* ─── Action Sheet ─── */

interface ActionSheetProps {
  open: boolean
  onClose: () => void
  title: string
  subtitle?: string
  children: React.ReactNode
}

export function ActionSheet({ open, onClose, title, subtitle, children }: ActionSheetProps) {
  return (
    <BottomSheetRoot open={open} onClose={onClose} maxHeight="40%">
      <DrawerHandle />
      <DrawerHeader title={title} subtitle={subtitle} onClose={onClose} />
      <div className="mt-3 pb-2">
        {React.Children.map(children, (child, i) => (
          <StaggerChild key={i} index={i}>
            {i > 0 && <div className="h-px bg-divider mx-page-h" />}
            {child}
          </StaggerChild>
        ))}
      </div>
      <div className="pb-6" />
    </BottomSheetRoot>
  )
}

/* ─── Confirm Sheet ─── */

interface ConfirmSheetProps {
  open: boolean
  onClose: () => void
  title: string
  subtitle?: string
  cancelLabel?: string
  confirmLabel: string
  destructive?: boolean
  onCancel?: () => void
  onConfirm: () => void
}

export function ConfirmSheet({
  open,
  onClose,
  title,
  subtitle,
  cancelLabel = '取消',
  confirmLabel,
  destructive,
  onCancel,
  onConfirm,
}: ConfirmSheetProps) {
  return (
    <BottomSheetRoot open={open} onClose={onClose} maxHeight="40%">
      <DrawerHandle />
      <div className="px-page-h pt-1 pb-6">
        <h3 className="text-[17px] font-medium text-ink">{title}</h3>
        {subtitle && <p className="text-[13px] text-ink-tertiary mt-1">{subtitle}</p>}
        <StaggerChild index={0} baseDelay={120}>
          <div className="flex gap-3 mt-6">
            <button
              className="flex-1 h-11 rounded-pill border border-[rgba(28,28,30,0.12)] text-ink-secondary text-[15px] active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer"
              onClick={onCancel ?? onClose}
            >
              {cancelLabel}
            </button>
            <button
              className={cn(
                'flex-1 h-11 rounded-pill text-white text-[15px] font-normal active:scale-[0.92] transition-transform ease-spring duration-[400ms] cursor-pointer',
                destructive ? 'bg-[#D4410A]' : 'bg-dark'
              )}
              onClick={onConfirm}
            >
              {confirmLabel}
            </button>
          </div>
        </StaggerChild>
      </div>
    </BottomSheetRoot>
  )
}
