import { createBrowserRouter, Navigate } from 'react-router-dom'
import { AppLayout } from '@/components/layout/AppLayout'
import { AuthLayout } from '@/components/layout/AuthLayout'
import { ProtectedRoute } from '@/components/common/ProtectedRoute'

// Pages - lazy loaded
const LandingPage = () => import('@/app/landing/LandingPage')
const LoginPage = () => import('@/app/(auth)/login/LoginPage')
const RegisterPage = () => import('@/app/(auth)/register/RegisterPage')
const ChatPage = () => import('@/app/chat/ChatPage')
const NotFoundPage = () => import('@/app/not-found/NotFoundPage')
const HomePage = () => import('@/app/(main)/home/HomePage')
const LibraryPage = () => import('@/app/(main)/library/LibraryPage')
const PracticePage = () => import('@/app/(main)/practice/PracticePage')
const QuizPage = () => import('@/app/(main)/quiz/QuizPage')
const ResultPage = () => import('@/app/(main)/result/ResultPage')
const SettingsPage = () => import('@/app/(main)/settings/SettingsPage')

// Lazy load helper
const lazy = (loader: () => Promise<{ default: React.ComponentType }>) => {
  const LazyComponent = React.lazy(loader)
  return (
    <React.Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center">
          <div className="text-muted-foreground">加载中...</div>
        </div>
      }
    >
      <LazyComponent />
    </React.Suspense>
  )
}

import React from 'react'

export const router = createBrowserRouter([
  {
    path: '/',
    element: lazy(LandingPage),
  },
  {
    element: <AuthLayout />,
    children: [
      {
        path: 'login',
        element: lazy(LoginPage),
      },
      {
        path: 'register',
        element: lazy(RegisterPage),
      },
    ],
  },
  {
    path: '/chat',
    element: lazy(ChatPage),
  },
  {
    element: (
      <ProtectedRoute>
        <AppLayout />
      </ProtectedRoute>
    ),
    children: [
      {
        path: 'home',
        element: lazy(HomePage),
      },
      {
        path: 'library',
        element: lazy(LibraryPage),
      },
      {
        path: 'practice/:id',
        element: lazy(PracticePage),
      },
      {
        path: 'quiz/:id',
        element: lazy(QuizPage),
      },
      {
        path: 'result/:id',
        element: lazy(ResultPage),
      },
      {
        path: 'settings',
        element: lazy(SettingsPage),
      },
    ],
  },
  {
    path: '/404',
    element: lazy(NotFoundPage),
  },
  {
    path: '*',
    element: <Navigate to="/404" replace />,
  },
])
