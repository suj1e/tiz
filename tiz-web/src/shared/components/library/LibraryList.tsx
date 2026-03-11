import type { KnowledgeSetSummary } from '@/types'
import { LibraryCard } from './LibraryCard'

interface LibraryListProps {
  libraries: KnowledgeSetSummary[]
}

export function LibraryList({ libraries }: LibraryListProps) {
  return (
    <div className="grid gap-3 sm:gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
      {libraries.map(library => (
        <div
          key={library.id}
          style={{
            contentVisibility: 'auto',
            containIntrinsicSize: '200px',
          }}
        >
          <LibraryCard library={library} />
        </div>
      ))}
    </div>
  )
}
