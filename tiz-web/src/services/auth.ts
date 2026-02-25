import { api } from './api'
import type { LoginRequest, LoginResponse, RegisterRequest, User } from '@/types'

export const authService = {
  login: (data: LoginRequest): Promise<LoginResponse> => {
    return api.post<LoginResponse>('/auth/v1/login', data)
  },

  register: (data: RegisterRequest): Promise<LoginResponse> => {
    return api.post<LoginResponse>('/auth/v1/register', data)
  },

  logout: (): Promise<void> => {
    return api.post('/auth/v1/logout')
  },

  getCurrentUser: (): Promise<User> => {
    return api.get<User>('/auth/v1/me')
  },
}
