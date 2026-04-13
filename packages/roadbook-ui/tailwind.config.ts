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
      },
      animation: {
        shimmer: 'shimmer 1.6s ease-in-out infinite',
        drift: 'drift 25s ease-in-out infinite',
      },
    },
  },
  plugins: [],
}

export default config
