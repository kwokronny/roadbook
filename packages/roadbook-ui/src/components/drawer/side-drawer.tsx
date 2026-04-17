import React from 'react'
import { cn } from '@/lib/utils'
import { SideDrawerRoot, DrawerContent } from './drawer-primitives'

/* ─── Side Drawer Header ─── */

interface SideDrawerHeaderProps extends React.HTMLAttributes<HTMLDivElement> {
  title: string
  onBack?: () => void
  action?: React.ReactNode
}

export function SideDrawerHeader({ title, onBack, action, className, ...props }: SideDrawerHeaderProps) {
  return (
    <div className={cn('flex items-center h-14 px-page-h border-b border-divider', className)} {...props}>
      {onBack && (
        <button
          className="w-8 h-8 rounded-full bg-dark flex items-center justify-center mr-3 active:scale-[0.88] transition-transform ease-spring duration-[400ms] cursor-pointer"
          onClick={onBack}
        >
          <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M15 18l-6-6 6-6" />
          </svg>
        </button>
      )}
      <h3 className="flex-1 text-[17px] font-medium text-ink text-center">{title}</h3>
      {action ? (
        <div className="ml-3">{action}</div>
      ) : onBack ? (
        <div className="w-8" /> /* balance the back button */
      ) : null}
    </div>
  )
}

/* ─── Side Drawer (Pre-composed) ─── */

interface SideDrawerProps {
  open: boolean
  onClose: () => void
  title: string
  action?: React.ReactNode
  width?: string
  children: React.ReactNode
}

export function SideDrawer({ open, onClose, title, action, width, children }: SideDrawerProps) {
  return (
    <SideDrawerRoot open={open} onClose={onClose} width={width}>
      <SideDrawerHeader title={title} onBack={onClose} action={action} />
      <DrawerContent className="py-4">
        {children}
      </DrawerContent>
    </SideDrawerRoot>
  )
}
