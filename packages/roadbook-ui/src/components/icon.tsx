import React from 'react'
import { cn } from '@/lib/utils'
import { iconPaths } from './icons'

interface IconProps extends React.SVGAttributes<SVGSVGElement> {
  name: string
  size?: number
}

export function Icon({ name, size = 24, className, ...props }: IconProps) {
  const path = iconPaths[name]
  if (!path) return null

  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={cn('inline-block', className)}
      dangerouslySetInnerHTML={{ __html: path }}
      {...props}
    />
  )
}
