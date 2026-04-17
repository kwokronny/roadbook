import React from 'react'
import { cn } from '@/lib/utils'
import { BottomSheetRoot, DrawerHandle, DrawerHeader, DrawerFooter, DrawerContent, StaggerChild } from './drawer-primitives'

/* ─── Form Group ─── */

interface FormGroupProps extends React.HTMLAttributes<HTMLDivElement> {
  label?: string
}

export function FormGroup({ label, className, children, ...props }: FormGroupProps) {
  return (
    <div className={cn('mb-4', className)} {...props}>
      {label && (
        <p className="text-[12px] text-ink-tertiary font-normal mb-2 px-1">{label}</p>
      )}
      <div className="bg-form-card rounded-card-inner overflow-hidden">
        {children}
      </div>
    </div>
  )
}

/* ─── Form Row ─── */

interface FormRowProps extends React.HTMLAttributes<HTMLDivElement> {
  label: string
  showDivider?: boolean
}

export function FormRow({ label, showDivider = true, className, children, ...props }: FormRowProps) {
  return (
    <>
      <div className={cn('flex items-center min-h-[48px] px-4', className)} {...props}>
        <span className="w-[60px] shrink-0 text-[15px] text-ink">{label}</span>
        <div className="flex-1 ml-3">{children}</div>
      </div>
      {showDivider && <div className="h-px bg-divider ml-[76px]" />}
    </>
  )
}

/* ─── Form Input ─── */

interface FormInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: string
}

export function FormInput({ error, className, ...props }: FormInputProps) {
  return (
    <div>
      <input
        className={cn(
          'w-full bg-transparent text-[15px] text-ink text-right outline-none placeholder:text-ink-tertiary',
          error && 'animate-shake',
          className
        )}
        {...props}
      />
      {error && <p className="text-[12px] text-[#D4410A] text-right mt-0.5">{error}</p>}
    </div>
  )
}

/* ─── Form Textarea ─── */

interface FormTextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  error?: string
}

export function FormTextarea({ error, className, ...props }: FormTextareaProps) {
  return (
    <div className="px-4 pb-3">
      <textarea
        className={cn(
          'w-full bg-transparent text-[15px] text-ink outline-none placeholder:text-ink-tertiary resize-none leading-relaxed',
          error && 'animate-shake',
          className
        )}
        rows={3}
        {...props}
      />
      {error && <p className="text-[12px] text-[#D4410A] mt-0.5">{error}</p>}
    </div>
  )
}

/* ─── Form Selector Row ─── */

interface FormSelectorProps {
  label: string
  value?: string
  placeholder?: string
  showDivider?: boolean
  onClick?: () => void
}

export function FormSelector({ label, value, placeholder = '请选择', showDivider = true, onClick }: FormSelectorProps) {
  return (
    <>
      <button
        className="w-full flex items-center min-h-[48px] px-4 hover:bg-row-hover active:bg-row-hover transition-colors cursor-pointer"
        onClick={onClick}
      >
        <span className="w-[60px] shrink-0 text-[15px] text-ink text-left">{label}</span>
        <div className="flex-1 ml-3 flex items-center justify-end gap-1">
          <span className={cn('text-[15px]', value ? 'text-ink' : 'text-ink-tertiary')}>
            {value || placeholder}
          </span>
          <svg width={12} height={12} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-ink-tertiary">
            <path d="M9 18l6-6-6-6" />
          </svg>
        </div>
      </button>
      {showDivider && <div className="h-px bg-divider ml-[76px]" />}
    </>
  )
}

/* ─── Form Toggle ─── */

interface FormToggleProps {
  label: string
  checked: boolean
  showDivider?: boolean
  onChange: (checked: boolean) => void
}

export function FormToggle({ label, checked, showDivider = true, onChange }: FormToggleProps) {
  return (
    <>
      <div className="flex items-center min-h-[48px] px-4">
        <span className="w-[60px] shrink-0 text-[15px] text-ink">{label}</span>
        <div className="flex-1 ml-3 flex justify-end">
          <button
            className={cn(
              'relative w-[51px] h-[31px] rounded-full transition-colors duration-300 cursor-pointer',
              checked ? 'bg-coral' : 'bg-[rgba(28,28,30,0.10)]'
            )}
            onClick={() => onChange(!checked)}
          >
            <div
              className={cn(
                'absolute top-[2px] w-[27px] h-[27px] rounded-full bg-white shadow-[0_1px_3px_rgba(0,0,0,0.12)]',
                'transition-all ease-spring duration-[350ms]',
                checked ? 'left-[22px]' : 'left-[2px]'
              )}
            />
          </button>
        </div>
      </div>
      {showDivider && <div className="h-px bg-divider ml-[76px]" />}
    </>
  )
}

/* ─── Form Sheet (Pre-composed) ─── */

interface FormSheetProps {
  open: boolean
  onClose: () => void
  title: string
  subtitle?: string
  ctaLabel?: string
  ctaDisabled?: boolean
  onSubmit?: () => void
  children: React.ReactNode
}

export function FormSheet({ open, onClose, title, subtitle, ctaLabel = '保存', ctaDisabled, onSubmit, children }: FormSheetProps) {
  return (
    <BottomSheetRoot open={open} onClose={onClose} maxHeight="85%">
      <DrawerHandle />
      <DrawerHeader title={title} subtitle={subtitle} onClose={onClose} showDivider />
      <DrawerContent className="py-4">
        {React.Children.map(children, (child, i) => (
          <StaggerChild key={i} index={i}>{child}</StaggerChild>
        ))}
      </DrawerContent>
      <DrawerFooter>
        <button
          className={cn(
            'w-full h-11 rounded-pill text-[15px] transition-transform active:scale-[0.92] ease-spring duration-[400ms] cursor-pointer',
            ctaDisabled
              ? 'bg-[rgba(28,28,30,0.12)] text-ink-tertiary cursor-not-allowed'
              : 'bg-dark text-white'
          )}
          disabled={ctaDisabled}
          onClick={onSubmit}
        >
          {ctaLabel} →
        </button>
      </DrawerFooter>
    </BottomSheetRoot>
  )
}
