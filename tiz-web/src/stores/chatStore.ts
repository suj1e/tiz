import { create } from 'zustand'
import type { GenerationSummary, Message } from '@/types'

interface ChatState {
  sessionId: string | null
  messages: Message[]
  summary: GenerationSummary | null
  status: 'idle' | 'streaming' | 'confirming' | 'generating'
  streamingContent: string
}

interface ChatActions {
  setSessionId: (id: string | null) => void
  addMessage: (message: Message) => void
  updateLastMessage: (content: string) => void
  setSummary: (summary: GenerationSummary | null) => void
  setStatus: (status: ChatState['status']) => void
  setStreamingContent: (content: string) => void
  appendStreamingContent: (content: string) => void
  clearStreamingContent: () => void
  reset: () => void
}

type ChatStore = ChatState & ChatActions

const initialState: ChatState = {
  sessionId: null,
  messages: [],
  summary: null,
  status: 'idle',
  streamingContent: '',
}

export const useChatStore = create<ChatStore>((set) => ({
  ...initialState,
  setSessionId: (sessionId) => set({ sessionId }),
  addMessage: (message) => set((state) => ({ messages: [...state.messages, message] })),
  updateLastMessage: (content) =>
    set((state) => {
      const messages = [...state.messages]
      if (messages.length > 0) {
        messages[messages.length - 1] = { ...messages[messages.length - 1], content }
      }
      return { messages }
    }),
  setSummary: (summary) => set({ summary }),
  setStatus: (status) => set({ status }),
  setStreamingContent: (streamingContent) => set({ streamingContent }),
  appendStreamingContent: (content) =>
    set((state) => ({ streamingContent: state.streamingContent + content })),
  clearStreamingContent: () => set({ streamingContent: '' }),
  reset: () => set(initialState),
}))
