export function ordinal(n: number): string {
  const suffixes = ['th', 'st', 'nd', 'rd']
  const v = n % 100
  return `${n}${suffixes[(v - 20) % 10] ?? suffixes[v] ?? suffixes[0]}`
}

export interface OrderLike {
  status: string
  queuePosition?: number | null
}

// The customer-facing message for an order, derived from its status and place
// in the queue. Front of the line (or in progress) reads "being made"; further
// back reads the ordinal position; ready/picked up read their own message.
export function orderStatusMessage(order: OrderLike): string {
  if (order.status === 'READY') return 'Your order is ready! ☕'
  if (order.status === 'PICKED_UP') return 'Enjoy your coffee!'
  if (order.status === 'IN_PROGRESS' || order.queuePosition === 1) return 'Your order is being made…'
  if (order.queuePosition) return `${ordinal(order.queuePosition)} in the queue`
  return 'Working on it…'
}
