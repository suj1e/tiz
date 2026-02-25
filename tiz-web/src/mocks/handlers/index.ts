import { authHandlers } from './auth'
import { chatHandlers } from './chat'
import { contentHandlers } from './content'
import { practiceHandlers } from './practice'
import { quizHandlers } from './quiz'
import { userHandlers } from './user'

export const handlers = [
  ...authHandlers,
  ...chatHandlers,
  ...contentHandlers,
  ...practiceHandlers,
  ...quizHandlers,
  ...userHandlers,
]
