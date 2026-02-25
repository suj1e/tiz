import { useState } from 'react'
import { Send } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'

interface ChatInputProps {
  onSend: (message: string) => void
  disabled?: boolean
  placeholder?: string
}

export function ChatInput({ onSend, disabled, placeholder = '输入消息...' }: ChatInputProps) {
  const [value, setValue] = useState('')

  const handleSend = () => {
    if (!value.trim() || disabled) return
    onSend(value.trim())
    setValue('')
  }

  return (
    <div className="flex gap-2 border-t p-4">
      <Textarea
        value={value}
        onChange={(e) => setValue(e.target.value)}
        placeholder={placeholder}
        className="min-h-[60px] resize-none"
        onKeyDown={(e) => {
          if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault()
            handleSend()
          }
        }}
      />
      <Button onClick={handleSend} disabled={disabled || !value.trim()}>
        <Send className="h-4 w-4" />
      </Button>
    </div>
  )
}
