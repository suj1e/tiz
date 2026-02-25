import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import {
  cn,
  formatDate,
  formatTime,
  formatDateTime,
  formatRelativeTime,
  sleep,
  debounce,
  throttle,
  generateId,
} from '@/lib/utils'

describe('cn', () => {
  it('should merge class names', () => {
    expect(cn('foo', 'bar')).toBe('foo bar')
  })

  it('should handle conditional classes', () => {
    expect(cn('foo', false && 'bar', 'baz')).toBe('foo baz')
  })

  it('should merge tailwind classes correctly', () => {
    expect(cn('px-2', 'px-4')).toBe('px-4')
  })
})

describe('formatDate', () => {
  it('should format date string', () => {
    const date = '2024-01-15T10:30:00Z'
    const result = formatDate(date)
    expect(result).toMatch(/2024/)
  })

  it('should format Date object', () => {
    const date = new Date('2024-06-20T00:00:00Z')
    const result = formatDate(date)
    expect(result).toMatch(/2024/)
  })
})

describe('formatTime', () => {
  it('should format time', () => {
    const date = '2024-01-15T10:30:00Z'
    const result = formatTime(date)
    expect(result).toMatch(/\d{2}:\d{2}/)
  })
})

describe('formatDateTime', () => {
  it('should format date and time', () => {
    const date = '2024-01-15T10:30:00Z'
    const result = formatDateTime(date)
    expect(result).toContain('2024')
  })
})

describe('formatRelativeTime', () => {
  it('should return "刚刚" for recent times', () => {
    const now = new Date()
    const result = formatRelativeTime(now.toISOString())
    expect(result).toBe('刚刚')
  })

  it('should return minutes ago', () => {
    const date = new Date(Date.now() - 5 * 60 * 1000)
    const result = formatRelativeTime(date.toISOString())
    expect(result).toBe('5 分钟前')
  })

  it('should return hours ago', () => {
    const date = new Date(Date.now() - 2 * 60 * 60 * 1000)
    const result = formatRelativeTime(date.toISOString())
    expect(result).toBe('2 小时前')
  })

  it('should return days ago', () => {
    const date = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000)
    const result = formatRelativeTime(date.toISOString())
    expect(result).toBe('3 天前')
  })
})

describe('sleep', () => {
  it('should resolve after specified time', async () => {
    const start = Date.now()
    await sleep(50)
    const end = Date.now()
    expect(end - start).toBeGreaterThanOrEqual(40)
  })
})

describe('debounce', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('should debounce function calls', () => {
    const fn = vi.fn()
    const debouncedFn = debounce(fn, 100)

    debouncedFn()
    debouncedFn()
    debouncedFn()

    expect(fn).not.toHaveBeenCalled()

    vi.advanceTimersByTime(100)

    expect(fn).toHaveBeenCalledTimes(1)
  })
})

describe('throttle', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('should throttle function calls', () => {
    const fn = vi.fn()
    const throttledFn = throttle(fn, 100)

    throttledFn()
    throttledFn()
    throttledFn()

    expect(fn).toHaveBeenCalledTimes(1)

    vi.advanceTimersByTime(100)

    throttledFn()
    expect(fn).toHaveBeenCalledTimes(2)
  })
})

describe('generateId', () => {
  it('should generate a string id', () => {
    const id = generateId()
    expect(typeof id).toBe('string')
    expect(id.length).toBeGreaterThan(0)
  })

  it('should generate unique ids', () => {
    const ids = new Set()
    for (let i = 0; i < 100; i++) {
      ids.add(generateId())
    }
    expect(ids.size).toBe(100)
  })
})
