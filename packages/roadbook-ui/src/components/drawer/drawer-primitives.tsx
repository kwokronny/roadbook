import React, { useEffect, useRef, useState, useCallback } from 'react'
import { cn } from '@/lib/utils'

/* ─── Overlay (Scrim) ─── */

interface DrawerOverlayProps extends React.HTMLAttributes<HTMLDivElement> {
  open: boolean
  onClose?: () => void
}

export function DrawerOverlay({ open, onClose, className, ...props }: DrawerOverlayProps) {
  if (!open) return null
  return (
    <div
      className={cn(
        'fixed inset-0 z-50 bg-scrim animate-fade-in',
        className
      )}
      onClick={onClose}
      {...props}
    />
  )
}

/* ─── Drag Handle ─── */

export function DrawerHandle({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={cn('flex justify-center pt-[10px] pb-3', className)} {...props}>
      <div className="w-9 h-1 rounded-pill bg-handle" />
    </div>
  )
}

/* ─── Close Button ─── */

interface DrawerCloseProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  size?: number
}

export function DrawerClose({ size = 26, className, onClick, ...props }: DrawerCloseProps) {
  return (
    <button
      className={cn(
        'flex items-center justify-center rounded-full bg-close-bg',
        'active:scale-[0.88] transition-transform ease-spring duration-[400ms]',
        'cursor-pointer shrink-0',
        className
      )}
      style={{ width: size, height: size }}
      onClick={onClick}
      {...props}
    >
      <svg width={12} height={12} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="text-ink-secondary">
        <line x1="18" y1="6" x2="6" y2="18" />
        <line x1="6" y1="6" x2="18" y2="18" />
      </svg>
    </button>
  )
}

/* ─── Header ─── */

interface DrawerHeaderProps extends React.HTMLAttributes<HTMLDivElement> {
  title: string
  subtitle?: string
  onClose?: () => void
  showDivider?: boolean
}

export function DrawerHeader({ title, subtitle, onClose, showDivider, className, ...props }: DrawerHeaderProps) {
  return (
    <div className={cn('px-page-h', className)} {...props}>
      <div className="flex items-center justify-between">
        <div className="flex-1 min-w-0">
          <h3 className="text-[17px] font-medium text-ink leading-tight">{title}</h3>
          {subtitle && (
            <p className="text-[13px] text-ink-tertiary mt-0.5">{subtitle}</p>
          )}
        </div>
        {onClose && <DrawerClose onClick={onClose} />}
      </div>
      {showDivider && <div className="h-px bg-divider mt-4" />}
    </div>
  )
}

/* ─── Footer ─── */

interface DrawerFooterProps extends React.HTMLAttributes<HTMLDivElement> {
  showDivider?: boolean
}

export function DrawerFooter({ showDivider = true, className, children, ...props }: DrawerFooterProps) {
  return (
    <div className={cn('px-page-h pb-6', className)} {...props}>
      {showDivider && <div className="h-px bg-divider mb-3" />}
      {children}
    </div>
  )
}

/* ─── Content ─── */

export function DrawerContent({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={cn('flex-1 overflow-y-auto px-page-h', className)} {...props}>
      {children}
    </div>
  )
}

/* ─── Staggered Content Wrapper ─── */

interface StaggerChildProps extends React.HTMLAttributes<HTMLDivElement> {
  index: number
  baseDelay?: number
}

export function StaggerChild({ index, baseDelay = 80, className, children, style, ...props }: StaggerChildProps) {
  const delay = Math.min(baseDelay + index * 50, 300)
  return (
    <div
      className={cn('animate-content-reveal', className)}
      style={{ animationDelay: `${delay}ms`, ...style }}
      {...props}
    >
      {children}
    </div>
  )
}

/* ─── Bottom Sheet Root ─── */

interface BottomSheetRootProps extends React.HTMLAttributes<HTMLDivElement> {
  open: boolean
  onClose?: () => void
  maxHeight?: string
}

export function BottomSheetRoot({ open, onClose, maxHeight = '85%', className, children, ...props }: BottomSheetRootProps) {
  const [visible, setVisible] = useState(false)
  const [closing, setClosing] = useState(false)

  useEffect(() => {
    if (open) {
      setVisible(true)
      setClosing(false)
    }
  }, [open])

  const handleClose = useCallback(() => {
    setClosing(true)
    setTimeout(() => {
      setVisible(false)
      setClosing(false)
      onClose?.()
    }, 280)
  }, [onClose])

  if (!visible) return null

  return (
    <>
      <div
        className={cn(
          'fixed inset-0 z-50 bg-scrim',
          closing ? 'animate-fade-out' : 'animate-fade-in'
        )}
        onClick={handleClose}
      />
      <div
        className={cn(
          'fixed bottom-0 left-0 right-0 z-50 flex flex-col',
          'bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8]',
          'border-t border-white/55',
          'shadow-[0_-8px_32px_rgba(0,0,0,0.06)]',
          'rounded-t-sheet',
          closing ? 'animate-slide-down' : 'animate-slide-up',
          className
        )}
        style={{ maxHeight }}
        {...props}
      >
        {children}
      </div>
    </>
  )
}

/* ─── Side Drawer Root ─── */

interface SideDrawerRootProps extends React.HTMLAttributes<HTMLDivElement> {
  open: boolean
  onClose?: () => void
  width?: string
}

export function SideDrawerRoot({ open, onClose, width = '85%', className, children, ...props }: SideDrawerRootProps) {
  const [visible, setVisible] = useState(false)
  const [closing, setClosing] = useState(false)

  useEffect(() => {
    if (open) {
      setVisible(true)
      setClosing(false)
    }
  }, [open])

  const handleClose = useCallback(() => {
    setClosing(true)
    setTimeout(() => {
      setVisible(false)
      setClosing(false)
      onClose?.()
    }, 280)
  }, [onClose])

  if (!visible) return null

  return (
    <>
      <div
        className={cn(
          'fixed inset-0 z-50 bg-scrim',
          closing ? 'animate-fade-out' : 'animate-fade-in'
        )}
        onClick={handleClose}
      />
      <div
        className={cn(
          'fixed top-0 right-0 bottom-0 z-50 flex flex-col',
          'bg-frost-strong backdrop-blur-[50px] backdrop-saturate-[1.8]',
          'border-l border-white/55',
          'shadow-[-8px_0_32px_rgba(0,0,0,0.06)]',
          'rounded-l-sheet',
          closing ? 'animate-slide-out-right' : 'animate-slide-in-right',
          className
        )}
        style={{ width, maxWidth: 380 }}
        {...props}
      >
        {children}
      </div>
    </>
  )
}
