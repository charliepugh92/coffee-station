import { defineStore } from 'pinia'
import { ref } from 'vue'

const ORDERS_KEY = 'coffee_station_orders'
const NAME_KEY = 'coffee_station_guest_name'

export interface GuestOrderRef {
  orderId: string
  orderToken: string
  guestName: string
  stationName: string
  createdAt: string
}

function load(): GuestOrderRef[] {
  try {
    return JSON.parse(localStorage.getItem(ORDERS_KEY) ?? '[]') as GuestOrderRef[]
  } catch {
    return []
  }
}

// The guest's persistent list of placed orders, kept in localStorage so a
// returning customer (even after closing the browser) can re-read status,
// reorder, and leave reviews later.
export const useGuestStore = defineStore('guest', () => {
  const orders = ref<GuestOrderRef[]>(load())
  const lastName = ref(localStorage.getItem(NAME_KEY) ?? '')

  function remember(entry: GuestOrderRef) {
    orders.value = [entry, ...orders.value.filter((o) => o.orderToken !== entry.orderToken)]
    localStorage.setItem(ORDERS_KEY, JSON.stringify(orders.value))
    lastName.value = entry.guestName
    localStorage.setItem(NAME_KEY, entry.guestName)
  }

  return { orders, lastName, remember }
})
