import React from 'react'
import { cn } from '@/lib/utils'

interface PhoneFrameProps {
  children: React.ReactNode
  className?: string
}

export function PhoneFrame({ children, className }: PhoneFrameProps) {
  return (
    <div className={cn('w-[320px] rounded-[32px] overflow-hidden border-[3px] border-[rgba(28,28,30,0.06)] shadow-[0_20px_60px_rgba(28,28,30,0.10)] flex-shrink-0', className)}>
      <div className="min-h-[640px] relative overflow-hidden bg-canvas">
        {/* Ambient orbs */}
        <div className="absolute w-[240px] h-[240px] rounded-full blur-[50px] bg-[rgba(255,107,61,0.10)] -top-[8%] -right-[12%]" />
        <div className="absolute w-[180px] h-[180px] rounded-full blur-[50px] bg-[rgba(245,210,170,0.14)] bottom-[12%] -left-[8%]" />
        {children}
      </div>
    </div>
  )
}
