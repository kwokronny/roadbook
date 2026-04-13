import React from 'react'
import { cn } from '@/lib/utils'

interface AmbientBgProps {
  className?: string
}

const orbs = [
  { color: 'rgba(245,210,170,0.18)', size: 350, top: '-5%', right: '-5%', delay: '0s' },
  { color: 'rgba(255,180,140,0.12)', size: 300, bottom: '5%', left: '-5%', delay: '-10s' },
  { color: 'rgba(245,224,176,0.13)', size: 260, bottom: '30%', right: '10%', delay: '-18s' },
]

export function AmbientBg({ className }: AmbientBgProps) {
  return (
    <div className={cn('fixed inset-0 z-0 overflow-hidden pointer-events-none', className)}>
      {orbs.map((orb, i) => (
        <div
          key={i}
          className="absolute rounded-full animate-drift"
          style={{
            width: orb.size,
            height: orb.size,
            background: orb.color,
            filter: 'blur(80px)',
            top: orb.top,
            right: orb.right,
            bottom: orb.bottom,
            left: orb.left,
            animationDelay: orb.delay,
          }}
        />
      ))}
    </div>
  )
}
