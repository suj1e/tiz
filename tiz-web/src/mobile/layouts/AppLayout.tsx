import { Outlet } from 'react-router-dom'
import { BottomNav } from '../components/BottomNav'
import { Header } from '@/components/layout/Header'

export function AppLayout() {
  return (
    <div className="flex h-screen flex-col bg-background">
      <Header />
      <main className="flex-1 overflow-auto p-4 pb-20">
        <Outlet />
      </main>
      <BottomNav />
    </div>
  )
}
