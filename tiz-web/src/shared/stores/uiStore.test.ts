import { describe, it, expect, beforeEach } from 'vitest'
import { useUIStore } from '@/stores/uiStore'

describe('useUIStore', () => {
  beforeEach(() => {
    useUIStore.setState({
      sidebarOpen: true,
      mobileMenuOpen: false,
      theme: 'system',
    })
  })

  it('should have correct initial state', () => {
    const state = useUIStore.getState()
    expect(state.sidebarOpen).toBe(true)
    expect(state.mobileMenuOpen).toBe(false)
    expect(state.theme).toBe('system')
  })

  it('should toggle sidebar', () => {
    useUIStore.getState().toggleSidebar()
    expect(useUIStore.getState().sidebarOpen).toBe(false)

    useUIStore.getState().toggleSidebar()
    expect(useUIStore.getState().sidebarOpen).toBe(true)
  })

  it('should set sidebar open', () => {
    useUIStore.getState().setSidebarOpen(false)
    expect(useUIStore.getState().sidebarOpen).toBe(false)

    useUIStore.getState().setSidebarOpen(true)
    expect(useUIStore.getState().sidebarOpen).toBe(true)
  })

  it('should toggle mobile menu', () => {
    useUIStore.getState().toggleMobileMenu()
    expect(useUIStore.getState().mobileMenuOpen).toBe(true)

    useUIStore.getState().toggleMobileMenu()
    expect(useUIStore.getState().mobileMenuOpen).toBe(false)
  })

  it('should set mobile menu open', () => {
    useUIStore.getState().setMobileMenuOpen(true)
    expect(useUIStore.getState().mobileMenuOpen).toBe(true)

    useUIStore.getState().setMobileMenuOpen(false)
    expect(useUIStore.getState().mobileMenuOpen).toBe(false)
  })

  it('should set theme', () => {
    useUIStore.getState().setTheme('dark')
    expect(useUIStore.getState().theme).toBe('dark')

    useUIStore.getState().setTheme('light')
    expect(useUIStore.getState().theme).toBe('light')
  })
})
