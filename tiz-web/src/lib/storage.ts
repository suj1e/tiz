const PREFIX = 'tiz-web-'

export const storage = {
  get<T>(key: string, defaultValue?: T): T | null {
    const value = localStorage.getItem(PREFIX + key)
    if (value === null) {
      return defaultValue ?? null
    }
    try {
      return JSON.parse(value) as T
    }
    catch {
      return value as unknown as T
    }
  },

  set<T>(key: string, value: T): void {
    const serialized = typeof value === 'string' ? value : JSON.stringify(value)
    localStorage.setItem(PREFIX + key, serialized)
  },

  remove(key: string): void {
    localStorage.removeItem(PREFIX + key)
  },

  clear(): void {
    const keysToRemove: string[] = []
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i)
      if (key?.startsWith(PREFIX)) {
        keysToRemove.push(key)
      }
    }
    keysToRemove.forEach(key => localStorage.removeItem(key))
  },
}
