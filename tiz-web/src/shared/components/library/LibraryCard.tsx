import { useNavigate } from 'react-router-dom'
import { BookOpen, Play, Timer } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import type { KnowledgeSetSummary } from '@/types'
import { formatDate } from '@/lib/utils'

interface LibraryCardProps {
  library: KnowledgeSetSummary
}

export function LibraryCard({ library }: LibraryCardProps) {
  const navigate = useNavigate()

  const difficultyLabel = {
    easy: '简单',
    medium: '中等',
    hard: '困难',
  }

  return (
    <Card className="overflow-hidden">
      <CardHeader className="pb-2 sm:pb-4">
        <div className="flex items-start justify-between gap-2">
          <CardTitle className="line-clamp-2 text-base sm:text-lg">{library.title}</CardTitle>
          <span className="shrink-0 rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary">
            {difficultyLabel[library.difficulty]}
          </span>
        </div>
      </CardHeader>
      <CardContent className="pb-2 sm:pb-4">
        <div className="flex flex-wrap items-center gap-2 text-xs text-muted-foreground sm:gap-4 sm:text-sm">
          <div className="flex items-center gap-1">
            <BookOpen className="h-3 w-3 sm:h-4 sm:w-4" />
            <span>{library.question_count} 题</span>
          </div>
          <span>{library.category}</span>
        </div>
        <div className="mt-1 text-xs text-muted-foreground sm:mt-2">
          创建于 {formatDate(library.created_at)}
        </div>
      </CardContent>
      <CardFooter className="gap-2 pt-0 sm:pt-0">
        <Button
          variant="outline"
          size="sm"
          className="flex-1 text-xs sm:text-sm"
          onClick={() => navigate(`/practice/${library.id}`)}
        >
          <Play className="mr-1 h-3 w-3" />
          练习
        </Button>
        <Button
          size="sm"
          className="flex-1 text-xs sm:text-sm"
          onClick={() => navigate(`/quiz/${library.id}`)}
        >
          <Timer className="mr-1 h-3 w-3" />
          测验
        </Button>
      </CardFooter>
    </Card>
  )
}
