import { getToken } from '@/utils/tokenStorage'
import { API_URL } from '@/utils/env'

export class ApiError extends Error {
  errors: string[]
  status: number
  constructor(status: number, errors: string[]) {
    super(errors.join(', ') || `Request failed (${status})`)
    this.name = 'ApiError'
    this.status = status
    this.errors = errors
  }
}

interface ApiFetchOptions {
  method?: string
  body?: Record<string, unknown> | FormData
}

// Thin wrapper around the Devise REST endpoints (sign in/up/out, password reset).
// Everything else in the app goes through GraphQL.
export async function apiFetch(path: string, options: ApiFetchOptions = {}): Promise<Response> {
  const headers: Record<string, string> = {}

  const token = getToken()
  if (token) headers.Authorization = `Bearer ${token}`

  let body: BodyInit | undefined
  if (options.body instanceof FormData) {
    body = options.body
  } else if (options.body) {
    headers['Content-Type'] = 'application/json'
    body = JSON.stringify(options.body)
  }

  const response = await fetch(`${API_URL}${path}`, {
    method: options.method ?? 'GET',
    headers,
    body,
  })

  if (!response.ok) {
    let errors: string[] = []
    try {
      const data = await response.json()
      errors = data.errors ?? (data.error ? [data.error] : data.message ? [data.message] : [])
    } catch {
      // non-JSON error body
    }
    throw new ApiError(response.status, errors)
  }

  return response
}
