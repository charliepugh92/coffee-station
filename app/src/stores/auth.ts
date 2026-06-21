import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import { apiFetch, ApiError } from '@/utils/api'
import * as tokenStorage from '@/utils/tokenStorage'
import MeDocument from '@/graphql/gql/auth/queries/Me.graphql'
import type { MeQuery, UserFieldsFragment } from '@/graphql/generated/types'

export type User = UserFieldsFragment

function tokenFromResponse(response: Response): string | null {
  return response.headers.get('Authorization')?.replace(/^Bearer /, '') ?? null
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(tokenStorage.getToken())

  const isAuthenticated = computed(() => !!token.value && !!user.value)

  function setToken(newToken: string) {
    token.value = newToken
    tokenStorage.setToken(newToken)
  }

  function clearAuth() {
    token.value = null
    user.value = null
    tokenStorage.clearToken()
    apolloClient.clearStore()
  }

  async function fetchCurrentUser() {
    if (!token.value) return
    try {
      const { data } = await apolloClient.query<MeQuery>({ query: MeDocument, fetchPolicy: 'network-only' })
      user.value = data.me ?? null
      if (!data.me) clearAuth()
    } catch {
      clearAuth()
    }
  }

  // Devise returns the JWT in the Authorization response header; adopt it, then
  // hydrate the user from the `me` query.
  async function adoptToken(response: Response) {
    const newToken = tokenFromResponse(response)
    if (!newToken) throw new ApiError(response.status, ['No token in response'])
    setToken(newToken)
    await fetchCurrentUser()
  }

  async function login(email: string, password: string) {
    const response = await apiFetch('/users/sign_in', { method: 'POST', body: { user: { email, password } } })
    await adoptToken(response)
  }

  async function signup(email: string, password: string, displayName: string) {
    const response = await apiFetch('/users', {
      method: 'POST',
      body: { user: { email, password, display_name: displayName } },
    })
    await adoptToken(response)
  }

  async function logout() {
    try {
      await apiFetch('/users/sign_out', { method: 'DELETE' })
    } catch {
      // best-effort revocation
    }
    clearAuth()
  }

  async function forgotPassword(email: string) {
    await apiFetch('/users/password', { method: 'POST', body: { user: { email } } })
  }

  async function resetPassword(resetToken: string, password: string) {
    await apiFetch('/users/password', {
      method: 'PUT',
      body: { user: { reset_password_token: resetToken, password, password_confirmation: password } },
    })
  }

  return {
    user,
    token,
    isAuthenticated,
    setToken,
    clearAuth,
    fetchCurrentUser,
    login,
    signup,
    logout,
    forgotPassword,
    resetPassword,
  }
})
