import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const timeBadgeVariants = cva(
  'inline-flex items-center gap-0.5 rounded-pill font-medium',
  {
    variants: {
      variant: {
        poi: 'bg-coral-tint text-[var(--ongoing-text)] text-[12px] px-2 py-0.5',
        hotel: 'bg-[rgba(61,90,128,0.09)] text-[#2C4A6E] text-[12px] px-2 py-0.5',
        unplanned: 'bg-[rgba(28,28,30,0.05)] text-ink-tertiary text-[12px] px-2 py-0.5',
      },
    },
    defaultVariants: { variant: 'poi' },
  }
)

const CalendarIcon = ({ className }: { className?: string }) => (
  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className={cn('flex-shrink-0 opacity-70', className)}>
    <rect x="3" y="4" width="18" height="18" rx="2" />
    <line x1="16" y1="2" x2="16" y2="6" />
    <line x1="8" y1="2" x2="8" y2="6" />
    <line x1="3" y1="10" x2="21" y2="10" />
  </svg>
)

interface TimeBadgeProps
  extends Omit<React.HTMLAttributes<HTMLSpanElement>, 'children'>,
    VariantProps<typeof timeBadgeVariants> {
  time: string
  editable?: boolean
}

export function TimeBadge({ variant, time, editable = false, className, ...props }: TimeBadgeProps) {
  return (
    <span className={cn(timeBadgeVariants({ variant }), className)} {...props}>
      {time}
      {editable && <CalendarIcon />}
    </span>
  )
}
