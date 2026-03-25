import { createRouter, createWebHistory } from 'vue-router'
import { isTokenExpired } from '../stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/LoginView.vue'),
      meta: { requiresAuth: false },
    },
    {
      path: '/',
      component: () => import('../layouts/AdminLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'Dashboard',
          component: () => import('../views/DashboardView.vue'),
        },
        {
          path: 'cards',
          name: 'CardList',
          component: () => import('../views/CardListView.vue'),
        },
        {
          path: 'cards/create',
          name: 'CardCreate',
          component: () => import('../views/CardFormView.vue'),
        },
        {
          path: 'cards/:id/edit',
          name: 'CardEdit',
          component: () => import('../views/CardFormView.vue'),
        },
      ],
    },
  ],
})

router.beforeEach((to) => {
  const token = localStorage.getItem('token')
  const authenticated = !!token && !isTokenExpired(token)

  if (to.meta.requiresAuth !== false && !authenticated) {
    // 만료된 토큰이 있으면 제거
    if (token) localStorage.removeItem('token')
    return '/login'
  }
  if (to.path === '/login' && authenticated) {
    return '/'
  }
})

export default router
