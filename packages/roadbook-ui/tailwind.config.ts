import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{ts,tsx}', './stories/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        canvas: 'var(--canvas)',
        frost: {
          DEFAULT: 'var(--frost)',
          strong: 'var(--frost-strong)',
          border: 'var(--frost-border)',
        },
        coral: {
          DEFAULT: 'var(--coral)',
          glow: 'var(--coral-glow)',
          tint: 'var(--coral-tint)',
        },
        dark: {
          DEFAULT: 'var(--dark)',
          hover: 'var(--dark-hover)',
        },
        ink: {
          DEFAULT: 'var(--ink)',
          secondary: 'var(--ink-secondary)',
          tertiary: 'var(--ink-tertiary)',
        },
        lavender: {
          DEFAULT: 'var(--lavender)',
          tint: 'var(--lavender-tint)',
          text: 'var(--lavender-text)',
        },
        nightsky: {
          DEFAULT: 'var(--nightsky)',
          light: 'var(--nightsky-light)',
        },
        destructive: 'var(--destructive)',
        scrim: 'var(--scrim)',
        handle: 'var(--handle)',
        'close-bg': 'var(--close-bg)',
        divider: 'var(--divider)',
        'form-card': 'var(--form-card)',
        'row-hover': 'var(--row-hover)',
        'row-hover-destructive': 'var(--row-hover-destructive)',
        'selected-bg': 'var(--selected-bg)',
        'check-border': 'var(--check-border)',
      },
      borderRadius: {
        card: '24px',
        'card-sm': '16px',
        'card-inner': '14px',
        pill: '100px',
        sheet: '24px',
      },
      spacing: {
        'page-h': '20px',
        'card-pad': '16px',
        'dock-inset': '20px',
        touch: '44px',
      },
      fontFamily: {
        sans: ['PingFang SC', 'system-ui', 'sans-serif'],
      },
      transitionTimingFunction: {
        spring: 'cubic-bezier(0.34, 1.3, 0.64, 1)',
        'ease-expo': 'cubic-bezier(0.22, 0.0, 0.36, 1)',
        expressive: 'cubic-bezier(0.22, 1.0, 0.36, 1)',
      },
      keyframes: {
        shimmer: {
          '0%': { backgroundPosition: '200% 0' },
          '100%': { backgroundPosition: '-200% 0' },
        },
        drift: {
          '0%, 100%': { transform: 'translate(0,0) scale(1)' },
          '33%': { transform: 'translate(25px,-15px) scale(1.04)' },
          '66%': { transform: 'translate(-15px,12px) scale(0.96)' },
        },
        'slide-up': {
          from: { transform: 'translateY(100%)' },
          to: { transform: 'translateY(0)' },
        },
        'slide-down': {
          from: { transform: 'translateY(0)' },
          to: { transform: 'translateY(100%)' },
        },
        'slide-in-right': {
          from: { transform: 'translateX(100%)' },
          to: { transform: 'translateX(0)' },
        },
        'slide-out-right': {
          from: { transform: 'translateX(0)' },
          to: { transform: 'translateX(100%)' },
        },
        'fade-in': {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        'fade-out': {
          from: { opacity: '1' },
          to: { opacity: '0' },
        },
        'content-reveal': {
          from: { opacity: '0', transform: 'translateY(12px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        shake: {
          '0%, 100%': { transform: 'translateX(0)' },
          '15%': { transform: 'translateX(-6px)' },
          '30%': { transform: 'translateX(6px)' },
          '50%': { transform: 'translateX(-4px)' },
          '70%': { transform: 'translateX(4px)' },
        },
      },
      animation: {
        shimmer: 'shimmer 1.6s ease-in-out infinite',
        drift: 'drift 25s ease-in-out infinite',
        'slide-up': 'slide-up 380ms cubic-bezier(0.22, 1.0, 0.36, 1)',
        'slide-down': 'slide-down 280ms cubic-bezier(0.22, 0.0, 0.36, 1)',
        'slide-in-right': 'slide-in-right 500ms cubic-bezier(0.34, 1.3, 0.64, 1)',
        'slide-out-right': 'slide-out-right 280ms cubic-bezier(0.22, 0.0, 0.36, 1)',
        'fade-in': 'fade-in 280ms ease',
        'fade-out': 'fade-out 200ms ease',
        'content-reveal': 'content-reveal 320ms cubic-bezier(0.22, 1.0, 0.36, 1) both',
        shake: 'shake 400ms cubic-bezier(0.34, 1.3, 0.64, 1)',
      },
    },
  },
  plugins: [],
}

export default config
