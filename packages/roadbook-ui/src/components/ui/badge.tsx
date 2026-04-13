import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const badgeVariants = cva(
  'inline-flex items-center rounded-pill px-2 py-0.5 text-[10px] font-medium',
  {
    variants: {
      variant: {
        ongoing: 'bg-[var(--ongoing-bg)] text-[var(--ongoing-text)]',
        upcoming: 'bg-[var(--upcoming-bg)] text-[var(--upcoming-text)]',
        planning: 'bg-[rgba(28,28,30,0.06)] text-ink-secondary',
        ended: 'bg-[rgba(28,28,30,0.04)] text-ink-tertiary',
        city: 'bg-[rgba(28,28,30,0.05)] text-ink-secondary border border-[rgba(28,28,30,0.08)]',
        hotel: 'bg-lavender-tint text-lavender-text',
      },
    },
    defaultVariants: {
      variant: 'planning',
    },
  }
)

interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {}

export function Badge({ variant, className, ...props }: BadgeProps) {
  return <span className={cn(badgeVariants({ variant }), className)} {...props} />
}
