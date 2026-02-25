import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { renderHook, act } from '@testing-library/react'
import { useMediaQuery, useIsMobile, useIsDesktop } from '@/hooks/useMediaQuery'

describe('useMediaQuery', () => {
  const originalMatchMedia = window.matchMedia

  beforeEach(() => {
    window.matchMedia = vi.fn()
  })

  afterEach(() => {
    window.matchMedia = originalMatchMedia
  })

  it('should return true when query matches', () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: true,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }))

    const { result } = renderHook(() => useMediaQuery('(min-width: 768px)'))
    expect(result.current).toBe(true)
  })

  it('should return false when query does not match', () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }))

    const { result } = renderHook(() => useMediaQuery('(min-width: 768px)'))
    expect(result.current).toBe(false)
  })

  it('should update when query changes', () => {
    const listeners: Array<(event: { matches: boolean }) => void> = []

    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: (_event: string, listener: (event: { matches: boolean }) => void) => {
        listeners.push(listener)
      },
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }))

    const { result } = renderHook(() => useMediaQuery('(min-width: 768px)'))
    expect(result.current).toBe(false)

    act(() => {
      listeners.forEach((listener) => listener({ matches: true }))
    })

    expect(result.current).toBe(true)
  })
})

describe('useIsMobile', () => {
  const originalMatchMedia = window.matchMedia

  beforeEach(() => {
    window.matchMedia = vi.fn()
  })

  afterEach(() => {
    window.matchMedia = originalMatchMedia
  })

  it('should return true for mobile viewport', () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: query === '(max-width: 768px)',
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }))

    const { result } = renderHook(() => useIsMobile())
    expect(result.current).toBe(true)
  })
})

describe('useIsDesktop', () => {
  const originalMatchMedia = window.matchMedia

  beforeEach(() => {
    window.matchMedia = vi.fn()
  })

  afterEach(() => {
    window.matchMedia = originalMatchMedia
  })

  it('should return true for desktop viewport', () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: query === '(min-width: 1024px)',
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }))

    const { result } = renderHook(() => useIsDesktop())
    expect(result.current).toBe(true)
  })
})
