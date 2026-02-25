import { LibraryCard } from './LibraryCard'
import type { KnowledgeSetSummary } from '@/types'

interface LibraryListProps {
  libraries: KnowledgeSetSummary[]
}

export function LibraryList({ libraries }: LibraryListProps) {
  return (
    <div className="grid gap-3 sm:gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
      {libraries.map((library) => (
        <LibraryCard key={library.id} library={library} />
      ))}
    </div>
  )
}
