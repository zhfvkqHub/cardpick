import axios from 'axios'
import { useAuthStore, isTokenExpired } from '../stores/auth'
import router from '../router'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use((config) => {

  if (config.url === '/admin/auth/login') {
    return config
  }

  const token = localStorage.getItem('token')
  if (!token || isTokenExpired(token)) {
    // 만료된 토큰으로 요청하지 않고 즉시 로그아웃
    const authStore = useAuthStore()
    authStore.logout()
    router.push('/login')
    return Promise.reject(new Error('토큰이 만료되었습니다. 다시 로그인해주세요.'))
  }
  config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      const authStore = useAuthStore()
      authStore.logout()
      router.push('/login')
    }
    return Promise.reject(error)
  },
)

export default api
