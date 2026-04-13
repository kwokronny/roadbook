import type { Preview } from '@storybook/react'
import React from 'react'
import '../src/globals.css'

const preview: Preview = {
  decorators: [
    (Story) => (
      <div
        style={{
          background: 'var(--canvas)',
          minHeight: '100vh',
          padding: '24px',
          position: 'relative',
        }}
      >
        <div style={{ position: 'fixed', inset: 0, zIndex: 0, overflow: 'hidden', pointerEvents: 'none' }}>
          <div
            style={{
              position: 'absolute', width: 350, height: 350,
              borderRadius: '50%', filter: 'blur(80px)',
              background: 'rgba(245,210,170,0.18)',
              top: '-5%', right: '-5%',
              animation: 'drift 25s ease-in-out infinite',
            }}
          />
          <div
            style={{
              position: 'absolute', width: 300, height: 300,
              borderRadius: '50%', filter: 'blur(80px)',
              background: 'rgba(255,180,140,0.12)',
              bottom: '5%', left: '-5%',
              animation: 'drift 25s ease-in-out infinite',
              animationDelay: '-10s',
            }}
          />
        </div>
        <div style={{ position: 'relative', zIndex: 1 }}>
          <Story />
        </div>
      </div>
    ),
  ],
}

export default preview
