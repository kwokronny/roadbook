import React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const skeletonVariants = cva(
  'animate-shimmer',
  {
    variants: {
      variant: {
        text: 'h-3 rounded-[6px]',
        avatar: 'rounded-full',
        image: 'rounded-card-inner',
        tag: 'rounded-pill h-5',
      },
    },
    defaultVariants: { variant: 'text' },
  }
)

interface SkeletonProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof skeletonVariants> {}

export function Skeleton({ variant, className, style, ...props }: SkeletonProps) {
  return (
    <div
      className={cn(skeletonVariants({ variant }), className)}
      style={{
        background: 'linear-gradient(120deg, var(--bone-base) 25%, var(--bone-shimmer) 50%, var(--bone-base) 75%)',
        backgroundSize: '200% 100%',
        ...style,
      }}
      {...props}
    />
  )
}
