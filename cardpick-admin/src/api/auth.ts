import api from './index'

export interface LoginRequest {
  loginId: string
  password: string
}

export interface TokenResponse {
  accessToken: string
  tokenType: string
}

export interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: {
    code: string
    message: string
  }
}

export const authApi = {
  login(data: LoginRequest) {
    return api.post<ApiResponse<TokenResponse>>('/admin/auth/login', data)
  },
}
