import { Check, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import type { GenerationSummary } from '@/types'

interface ChatConfirmProps {
  summary: GenerationSummary
  onConfirm: () => void
  onCancel: () => void
}

export function ChatConfirm({ summary, onConfirm, onCancel }: ChatConfirmProps) {
  return (
    <Card className="border-primary">
      <CardHeader>
        <CardTitle className="text-lg">确认生成</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-muted-foreground">标题</span>
            <span className="font-medium">{summary.title}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">分类</span>
            <span className="font-medium">{summary.category}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">难度</span>
            <span className="font-medium">{summary.difficulty}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">题目数量</span>
            <span className="font-medium">{summary.question_count}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-muted-foreground">题型</span>
            <span className="font-medium">
              {summary.question_types.map((t) => (t === 'choice' ? '选择题' : '简答题')).join('、')}
            </span>
          </div>
          {summary.tags.length > 0 && (
            <div className="flex justify-between">
              <span className="text-muted-foreground">标签</span>
              <div className="flex gap-1">
                {summary.tags.map((tag) => (
                  <span
                    key={tag}
                    className="rounded-full bg-muted px-2 py-0.5 text-xs"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>
        <div className="flex gap-2">
          <Button onClick={onConfirm} className="flex-1">
            <Check className="mr-2 h-4 w-4" />
            确认生成
          </Button>
          <Button variant="outline" onClick={onCancel}>
            <X className="mr-2 h-4 w-4" />
            取消
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
