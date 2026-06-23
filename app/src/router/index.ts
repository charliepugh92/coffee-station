import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/HomeView.vue'),
      meta: { customerFacing: true },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/AuthView.vue'),
      props: { mode: 'login' },
      meta: { guestOnly: true },
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/AuthView.vue'),
      props: { mode: 'register' },
      meta: { guestOnly: true },
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('@/views/DashboardView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/account',
      name: 'account',
      component: () => import('@/views/AccountView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/orders',
      name: 'order-history',
      component: () => import('@/views/OrderHistoryView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/stations/:id',
      name: 'station-edit',
      component: () => import('@/views/StationEditView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/stations/:id/board',
      name: 'order-board',
      component: () => import('@/views/OrderBoardView.vue'),
      meta: { requiresAuth: true },
    },
    {
      // Public guest ordering link — no auth.
      path: '/s/:token',
      name: 'guest-order',
      component: () => import('@/views/GuestOrderView.vue'),
      meta: { customerFacing: true },
    },
    {
      // Returning-customer hub — reads the browser's persisted order list.
      path: '/my-orders',
      name: 'my-orders',
      component: () => import('@/views/MyOrdersView.vue'),
      meta: { customerFacing: true },
    },
    {
      // Single order status, keyed by guest token. Deep-link target for the
      // "your drink is ready" push and where a returning customer tracks status.
      path: '/o/:token',
      name: 'order-status',
      component: () => import('@/views/OrderStatusView.vue'),
      meta: { customerFacing: true },
    },
  ],
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()

  // Settle the session on deep links before evaluating guards.
  if (auth.token && !auth.user) {
    await auth.fetchCurrentUser()
  }

  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  if (to.meta.guestOnly && auth.isAuthenticated) {
    return { name: 'dashboard' }
  }
})

export default router
