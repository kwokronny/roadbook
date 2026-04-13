import React from 'react'
import { Slot } from '@radix-ui/react-slot'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-1.5 font-normal transition-transform active:scale-[0.92] ease-spring duration-[400ms] cursor-pointer select-none',
  {
    variants: {
      variant: {
        'dark-pill': 'bg-dark text-white hover:bg-dark-hover rounded-pill text-[15px] px-5 h-11',
        coral: 'bg-coral text-white rounded-pill text-[15px] px-5 h-11 shadow-[0_2px_8px_rgba(255,107,61,0.25)]',
        glass: 'bg-frost text-ink backdrop-blur-[24px] backdrop-saturate-[1.4] border border-frost-border rounded-pill text-[15px] px-5 h-11',
        ghost: 'bg-transparent text-ink-secondary border border-[rgba(28,28,30,0.12)] rounded-pill text-[15px] px-5 h-11',
        'dark-circle': 'bg-dark text-white rounded-full w-9 h-9 p-0',
        'coral-circle': 'bg-coral text-white rounded-full w-9 h-9 p-0 shadow-[0_2px_8px_rgba(255,107,61,0.25)]',
      },
    },
    defaultVariants: {
      variant: 'dark-pill',
    },
  }
)

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

export function Button({ variant, className, asChild, children, ...props }: ButtonProps) {
  const Comp = asChild ? Slot : 'button'
  return <Comp className={cn(buttonVariants({ variant }), className)} {...props}>{children}</Comp>
}
