# Implementation Tasks

## 1. Auth Store Token Persistence

- [x] 1.1 Modify `authStore.ts` - login action to save token to localStorage
- [x] 1.2 Modify `authStore.ts` - logout action to remove token from localStorage
- [x] 1.3 Remove unused `useAuth` hook or mark as deprecated

## 2. AuthProvider Component

- [x] 2.1 Create `src/shared/providers/AuthProvider.tsx`
- [x] 2.2 Implement token reading from localStorage
- [x] 2.3 Implement token validation via `/auth/v1/me`
- [x] 2.4 Handle validation failure (clear token, reset state)
- [x] 2.5 Add loading state during initialization
- [x] 2.6 Export `useAuthContext` hook for consuming auth state

## 3. App Integration

- [x] 3.1 Modify `src/desktop/App.tsx` - wrap with AuthProvider
- [x] 3.2 Modify `src/mobile/App.tsx` - wrap with AuthProvider
- [x] 3.3 Update `ProtectedRoute.tsx` to use AuthProvider context (optional refactor)

## 4. Landing Page Start Trial Button

- [x] 4.1 Add auth state check to LandingPage
- [x] 4.2 Implement smart navigation logic for "开始试用" button
- [x] 4.3 Add loading state while checking auth

## 5. 404 Page Optimization

- [x] 5.1 Modify `NotFoundPage.tsx` - handle back button without history

## 6. Testing

- [ ] 6.1 Test login flow - verify token saved to localStorage
- [ ] 6.2 Test page refresh - verify auth state persisted
- [ ] 6.3 Test direct URL access to protected routes
- [ ] 6.4 Test "开始试用" button in all three scenarios
- [ ] 6.5 Test logout - verify token removed from localStorage
