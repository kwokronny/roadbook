import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const glassCardVariants = cva(
  'relative overflow-hidden',
  {
    variants: {
      variant: {
        frost: [
          'bg-frost border border-frost-border',
          'backdrop-blur-[40px] backdrop-saturate-[1.4]',
          'shadow-[0_8px_32px_rgba(0,0,0,0.06),0_1px_2px_rgba(0,0,0,0.03)]',
        ],
        strong: [
          'bg-frost-strong border border-white/55',
          'backdrop-blur-[50px] backdrop-saturate-[1.8]',
          'shadow-[0_-8px_32px_rgba(0,0,0,0.06)]',
        ],
        dark: [
          'bg-nightsky border border-white/[0.08]',
          'backdrop-blur-[40px] backdrop-saturate-[1.4]',
          'shadow-[0_8px_32px_rgba(0,0,0,0.10)]',
        ],
      },
      radius: {
        card: 'rounded-card',
        'card-sm': 'rounded-card-sm',
        'card-inner': 'rounded-card-inner',
      },
    },
    defaultVariants: {
      variant: 'frost',
      radius: 'card',
    },
  }
)

interface GlassCardProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof glassCardVariants> {}

export function GlassCard({ variant, radius, className, children, ...props }: GlassCardProps) {
  return (
    <div className={cn(glassCardVariants({ variant, radius }), className)} {...props}>
      <div
        className="absolute inset-0 rounded-[inherit] pointer-events-none"
        style={{
          background: variant === 'dark'
            ? 'linear-gradient(160deg, rgba(255,255,255,0.08) 0%, transparent 40%)'
            : 'linear-gradient(160deg, rgba(255,255,255,0.35) 0%, transparent 40%)',
        }}
      />
      <div className="relative z-[1]">{children}</div>
    </div>
  )
}
