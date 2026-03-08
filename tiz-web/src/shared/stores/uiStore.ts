import { create } from 'zustand'

interface UIState {
  sidebarOpen: boolean
  mobileMenuOpen: boolean
  theme: 'light' | 'dark' | 'system'
}

interface UIActions {
  toggleSidebar: () => void
  setSidebarOpen: (open: boolean) => void
  toggleMobileMenu: () => void
  setMobileMenuOpen: (open: boolean) => void
  setTheme: (theme: UIState['theme']) => void
}

type UIStore = UIState & UIActions

const initialState: UIState = {
  sidebarOpen: true,
  mobileMenuOpen: false,
  theme: 'system',
}

export const useUIStore = create<UIStore>((set) => ({
  ...initialState,
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
  setSidebarOpen: (sidebarOpen) => set({ sidebarOpen }),
  toggleMobileMenu: () => set((state) => ({ mobileMenuOpen: !state.mobileMenuOpen })),
  setMobileMenuOpen: (mobileMenuOpen) => set({ mobileMenuOpen }),
  setTheme: (theme) => set({ theme }),
}))
