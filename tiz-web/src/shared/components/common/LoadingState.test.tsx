import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { EmptyState } from '@/components/common/EmptyState'
import { LoadingState } from '@/components/common/LoadingState'
import { PageError } from '@/components/common/PageError'

describe('EmptyState', () => {
  it('should render with title', () => {
    render(<EmptyState title="No items" />)
    expect(screen.getByText('No items')).toBeInTheDocument()
  })

  it('should render with description', () => {
    render(<EmptyState title="No items" description="Add your first item" />)
    expect(screen.getByText('Add your first item')).toBeInTheDocument()
  })

  it('should render with action button', () => {
    const onClick = vi.fn()
    render(<EmptyState title="No items" action={{ label: 'Add Item', onClick }} />)
    expect(screen.getByText('Add Item')).toBeInTheDocument()
  })

  it('should call action onClick', async () => {
    const onClick = vi.fn()
    render(<EmptyState title="No items" action={{ label: 'Add Item', onClick }} />)

    const button = screen.getByText('Add Item')
    button.click()

    expect(onClick).toHaveBeenCalled()
  })
})

describe('LoadingState', () => {
  it('should render with default text', () => {
    render(<LoadingState />)
    expect(screen.getByText('加载中...')).toBeInTheDocument()
  })

  it('should render with custom text', () => {
    render(<LoadingState text="Loading data..." />)
    expect(screen.getByText('Loading data...')).toBeInTheDocument()
  })
})

describe('PageError', () => {
  it('should render with default message', () => {
    render(<PageError />)
    expect(screen.getByText('出错了')).toBeInTheDocument()
    expect(screen.getByText('加载失败，请重试')).toBeInTheDocument()
  })

  it('should render with custom message', () => {
    render(<PageError title="Error" message="Something went wrong" />)
    expect(screen.getByText('Error')).toBeInTheDocument()
    expect(screen.getByText('Something went wrong')).toBeInTheDocument()
  })

  it('should render retry button when onRetry is provided', () => {
    const onRetry = vi.fn()
    render(<PageError onRetry={onRetry} />)
    expect(screen.getByText('重试')).toBeInTheDocument()
  })

  it('should call onRetry when retry button is clicked', () => {
    const onRetry = vi.fn()
    render(<PageError onRetry={onRetry} />)

    const button = screen.getByText('重试')
    button.click()

    expect(onRetry).toHaveBeenCalled()
  })
})

import { vi } from 'vitest'
