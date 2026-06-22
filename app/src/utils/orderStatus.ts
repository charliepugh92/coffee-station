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
  if (order.status === 'READY') return "Your coffee's ready!"
  if (order.status === 'PICKED_UP') return 'Enjoy your coffee!'
  if (order.status === 'IN_PROGRESS' || order.queuePosition === 1) return 'Your order is being made…'
  if (order.queuePosition) return `${ordinal(order.queuePosition)} in the queue`
  return 'Working on it…'
}

// Style-bible §6.5 pill — one source of truth for the 4-state status badge,
// reused on the guest status card, the host order board, and the
// returning-customer history list.
const PILL_CLASS: Record<string, string> = {
  PENDING: 'bg-sunken text-muted',
  IN_PROGRESS: 'bg-accent-tint text-roast',
  READY: 'bg-success-tint text-success',
  PICKED_UP: 'bg-picked-up text-muted',
}

export function statusPillClass(status: string): string {
  return PILL_CLASS[status] ?? 'bg-sunken text-muted'
}

export function statusPillLabel(status: string): string {
  return status.replace('_', ' ')
}
