import { create } from 'zustand'
import type { Category, KnowledgeSetSummary, Tag } from '@/types'

interface LibraryState {
  libraries: KnowledgeSetSummary[]
  categories: Category[]
  tags: Tag[]
  selectedCategory: string | null
  selectedTags: string[]
  searchQuery: string
  isLoading: boolean
  // Cursor pagination state
  hasNextPage: boolean
  nextToken: string | null
}

interface LibraryActions {
  setLibraries: (libraries: KnowledgeSetSummary[]) => void
  appendLibraries: (libraries: KnowledgeSetSummary[]) => void
  addLibrary: (library: KnowledgeSetSummary) => void
  removeLibrary: (id: string) => void
  setCategories: (categories: Category[]) => void
  setTags: (tags: Tag[]) => void
  setSelectedCategory: (category: string | null) => void
  setSelectedTags: (tags: string[]) => void
  toggleTag: (tag: string) => void
  setSearchQuery: (query: string) => void
  setLoading: (loading: boolean) => void
  setPagination: (hasNextPage: boolean, nextToken: string | null) => void
  resetPagination: () => void
}

type LibraryStore = LibraryState & LibraryActions

const initialState: LibraryState = {
  libraries: [],
  categories: [],
  tags: [],
  selectedCategory: null,
  selectedTags: [],
  searchQuery: '',
  isLoading: false,
  hasNextPage: false,
  nextToken: null,
}

export const useLibraryStore = create<LibraryStore>((set) => ({
  ...initialState,
  setLibraries: (libraries) => set({ libraries }),
  appendLibraries: (newLibraries) =>
    set((state) => ({ libraries: [...state.libraries, ...newLibraries] })),
  addLibrary: (library) => set((state) => ({ libraries: [library, ...state.libraries] })),
  removeLibrary: (id) => set((state) => ({ libraries: state.libraries.filter((l) => l.id !== id) })),
  setCategories: (categories) => set({ categories }),
  setTags: (tags) => set({ tags }),
  setSelectedCategory: (selectedCategory) => set({ selectedCategory }),
  setSelectedTags: (selectedTags) => set({ selectedTags }),
  toggleTag: (tag) =>
    set((state) => ({
      selectedTags: state.selectedTags.includes(tag)
        ? state.selectedTags.filter((t) => t !== tag)
        : [...state.selectedTags, tag],
    })),
  setSearchQuery: (searchQuery) => set({ searchQuery }),
  setLoading: (isLoading) => set({ isLoading }),
  setPagination: (hasNextPage, nextToken) => set({ hasNextPage, nextToken }),
  resetPagination: () => set({ hasNextPage: false, nextToken: null }),
}))
