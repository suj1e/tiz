#!/bin/bash
# 初始化开发 worktrees

set -e

WORKTREES_DIR=".claude/worktrees"
SERVICES=("authsrv" "llmsrv" "usersrv" "contentsrv" "chatsrv" "practicesrv" "quizsrv" "gatewaysrv")

echo "=========================================="
echo "   Tiz Backend Services - Setup Worktrees"
echo "=========================================="
echo ""

# 创建目录
mkdir -p "$WORKTREES_DIR"

# 创建 worktrees
for service in "${SERVICES[@]}"; do
    branch="feature/$service"
    worktree_path="$WORKTREES_DIR/$service"

    if [ -d "$worktree_path" ]; then
        echo "  [skip] $service - worktree already exists"
    else
        # 检查分支是否存在
        if git show-ref --verify --quiet "refs/heads/$branch"; then
            echo "  [create] $service - using existing branch $branch"
            git worktree add "$worktree_path" "$branch"
        else
            echo "  [create] $service - creating new branch $branch"
            git worktree add "$worktree_path" -b "$branch"
        fi
    fi
done

echo ""
echo "=========================================="
echo "   Worktrees Created"
echo "=========================================="
git worktree list
echo ""
echo "To start developing a service:"
echo "  cd .claude/worktrees/<service>"
echo ""
