import { describe, it, expect, beforeEach } from 'vitest'
import { getToken, setToken, clearToken } from './tokenStorage'

describe('tokenStorage', () => {
  beforeEach(() => localStorage.clear())

  it('returns null when no token is stored', () => {
    expect(getToken()).toBeNull()
  })

  it('round-trips a token through set/get/clear', () => {
    setToken('jwt-abc')
    expect(getToken()).toBe('jwt-abc')
    clearToken()
    expect(getToken()).toBeNull()
  })
})
