import { describe, it, expect } from 'vitest'
import { ordinal, orderStatusMessage } from './orderStatus'

describe('ordinal', () => {
  it('formats ordinals correctly', () => {
    expect([1, 2, 3, 4, 11, 12, 21, 23].map(ordinal)).toEqual([
      '1st', '2nd', '3rd', '4th', '11th', '12th', '21st', '23rd',
    ])
  })
})

describe('orderStatusMessage', () => {
  it('reads "being made" at the front of the queue', () => {
    expect(orderStatusMessage({ status: 'PENDING', queuePosition: 1 })).toBe('Your order is being made…')
  })

  it('reads the ordinal position further back', () => {
    expect(orderStatusMessage({ status: 'PENDING', queuePosition: 4 })).toBe('4th in the queue')
  })

  it('reads "being made" when in progress regardless of position', () => {
    expect(orderStatusMessage({ status: 'IN_PROGRESS', queuePosition: 3 })).toBe('Your order is being made…')
  })

  it('announces ready', () => {
    expect(orderStatusMessage({ status: 'READY', queuePosition: null })).toContain('ready')
  })
})
