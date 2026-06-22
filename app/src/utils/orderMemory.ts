import type { OrderFieldsFragment } from '@/graphql/generated/types'

// The self-contained snapshot of an order's contents (base, preset, options),
// independent of the live menu. See the API's Order#build_memory.
export type OrderMemory = OrderFieldsFragment['memory']

// Flat list of chosen option names across every category.
export function memoryOptionNames(memory: OrderMemory): string[] {
  return memory.groups.flatMap((g) => g.options)
}

// What the guest customised, without the base — option names, falling back to the
// preset name. Returns '' when there's nothing beyond the base.
export function memoryCustomisation(memory: OrderMemory): string {
  return memoryOptionNames(memory).join(', ') || memory.presetName || ''
}

// One-line summary of the whole order: base · preset · options (whatever exists).
export function memorySummary(memory: OrderMemory): string {
  const parts = [memory.baseName, memory.presetName, ...memoryOptionNames(memory)].filter(Boolean)
  return parts.length ? parts.join(' · ') : '—'
}
