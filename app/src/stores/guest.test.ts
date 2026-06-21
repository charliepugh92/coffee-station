import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useGuestStore } from './guest'

describe('guest store', () => {
  beforeEach(() => {
    localStorage.clear()
    setActivePinia(createPinia())
  })

  const entry = {
    orderId: '1',
    orderToken: 'tok-1',
    guestName: 'Sam',
    stationName: 'Davey’s',
    createdAt: '2026-01-01T00:00:00Z',
  }

  it('remembers an order and persists it to localStorage', () => {
    const guest = useGuestStore()
    guest.remember(entry)
    expect(guest.orders).toHaveLength(1)
    expect(guest.lastName).toBe('Sam')
    expect(JSON.parse(localStorage.getItem('coffee_station_orders')!)).toHaveLength(1)
  })

  it('dedupes by order token, keeping the newest first', () => {
    const guest = useGuestStore()
    guest.remember(entry)
    guest.remember({ ...entry, guestName: 'Sammy' })
    expect(guest.orders).toHaveLength(1)
    expect(guest.orders[0].guestName).toBe('Sammy')
  })

  it('rehydrates the persisted list on a fresh store', () => {
    useGuestStore().remember(entry)
    setActivePinia(createPinia())
    expect(useGuestStore().orders).toHaveLength(1)
  })
})
