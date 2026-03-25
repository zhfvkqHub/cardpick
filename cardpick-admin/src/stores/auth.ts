import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi, type LoginRequest } from '../api/auth'

/**
 * JWT 페이로드에서 exp(만료 시각, Unix timestamp)를 추출합니다.
 * 파싱 실패 시 null을 반환합니다.
 */
function getTokenExpiry(token: string): number | null {
  try {
    const payload = token.split('.')[1]
    const decoded = JSON.parse(atob(payload))
    return typeof decoded.exp === 'number' ? decoded.exp * 1000 : null
  } catch {
    return null
  }
}

/**
 * 토큰이 만료됐는지 확인합니다. (현재 시각 기준 30초 여유 포함)
 */
export function isTokenExpired(token: string | null): boolean {
  if (!token) return true
  const expiry = getTokenExpiry(token)
  if (expiry === null) return true
  return Date.now() >= expiry - 30_000
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('token'))

  const isAuthenticated = computed(() => !!token.value && !isTokenExpired(token.value))

  async function login(data: LoginRequest) {
    const response = await authApi.login(data)
    if (response.data.success && response.data.data) {
      token.value = response.data.data.accessToken
      localStorage.setItem('token', response.data.data.accessToken)
    } else {
      throw new Error(response.data.error?.message || '로그인에 실패했습니다')
    }
  }

  function logout() {
    token.value = null
    localStorage.removeItem('token')
  }

  return { token, isAuthenticated, login, logout }
})
