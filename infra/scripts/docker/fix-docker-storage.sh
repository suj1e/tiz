#!/bin/bash

# Docker 存储问题修复脚本
# 解决 overlay 占用系统盘空间的问题
#
# 使用方法:
#   sudo bash fix-docker-storage.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
DATA_DISK_MNT="/opt/dev/dockermnt"
DOCKER_DATA_ROOT="${DATA_DISK_MNT}/docker"
DAEMON_JSON="/etc/docker/daemon.json"
BACKUP_DIR="/tmp/docker-backup-$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Docker 存储问题修复脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查是否以 root 运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 sudo 运行此脚本${NC}"
    echo "使用方法: sudo bash $0"
    exit 1
fi

# 显示当前磁盘使用情况
echo -e "${YELLOW}=== 当前磁盘使用情况 ===${NC}"
df -h | grep -E "Filesystem|/$|/opt|/var"
echo ""

# 显示 Docker 占用情况
echo -e "${YELLOW}=== Docker 存储占用情况 ===${NC}"
if [ -d /var/lib/docker ]; then
    echo -e "系统盘 /var/lib/docker: ${BLUE}$(du -sh /var/lib/docker 2>/dev/null | cut -f1)${NC}"
    if [ -d /var/lib/docker/overlay2 ]; then
        echo -e "  - overlay2: ${BLUE}$(du -sh /var/lib/docker/overlay2 2>/dev/null | cut -f1)${NC}"
    fi
    if [ -d /var/lib/docker/containers ]; then
        echo -e "  - containers: ${BLUE}$(du -sh /var/lib/docker/containers 2>/dev/null | cut -f1)${NC}"
        echo -e "    容器日志总大小: ${BLUE}$(find /var/lib/docker/containers -name "*.log" -exec du -sh {} \; 2>/dev/null | awk '{sum+=$1} END {print sum "K"}')${NC}"
    fi
fi
echo ""

# 询问用户选择
echo -e "${YELLOW}请选择修复方案:${NC}"
echo "  1) 快速修复 - 清理无用资源 + 配置日志限制 (推荐，不影响现有数据)"
echo "  2) 完整修复 - 迁移 Docker 数据目录到数据盘 ${DATA_DISK_MNT}"
echo "  3) 仅清理 - 只清理 Docker 无用资源"
echo ""
read -p "请输入选项 [1-3]: " choice

case $choice in
    1)
        echo -e "${GREEN}执行快速修复...${NC}"
        MODE="quick"
        ;;
    2)
        echo -e "${GREEN}执行完整修复...${NC}"
        MODE="full"
        # 检查数据盘是否存在
        if [ ! -d "$DATA_DISK_MNT" ]; then
            echo -e "${RED}错误: 数据盘挂载点 ${DATA_DISK_MNT} 不存在！${NC}"
            echo "请先确认数据盘已正确挂载。"
            exit 1
        fi
        ;;
    3)
        echo -e "${GREEN}仅清理 Docker 资源...${NC}"
        MODE="clean"
        ;;
    *)
        echo -e "${RED}无效选项，退出${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}=== 检查运行中的容器 ===${NC}"
RUNNING_CONTAINERS=$(docker ps -q)
if [ -n "$RUNNING_CONTAINERS" ]; then
    echo -e "${YELLOW}检测到运行中的容器，将自动停止...${NC}"
    cd /opt/dev/apps/infra 2>/dev/null || cd /root/nexora-infra 2>/dev/null || {
        echo -e "${RED}无法找到 docker-compose.yml 所在目录${NC}"
        echo -e "${YELLOW}请手动停止容器: docker-compose down${NC}"
        read -p "是否继续? [y/N] " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            exit 1
        fi
    }

    if [ -f "docker-compose.yml" ]; then
        docker-compose down
    else
        docker stop $(docker ps -aq) 2>/dev/null || true
    fi
fi

# 清理 Docker 资源
echo ""
echo -e "${YELLOW}=== 清理 Docker 无用资源 ===${NC}"
echo -e "${BLUE}清理构建缓存...${NC}"
docker builder prune -f 2>/dev/null || true

echo -e "${BLUE}清理未使用的镜像...${NC}"
docker image prune -a -f 2>/dev/null || true

echo -e "${BLUE}清理未使用的容器...${NC}"
docker container prune -f 2>/dev/null || true

echo -e "${BLUE}清理未使用的卷...${NC}"
docker volume prune -f 2>/dev/null || true

echo -e "${GREEN}清理完成！${NC}"

# 如果只是清理，结束
if [ "$MODE" == "clean" ]; then
    echo ""
    echo -e "${GREEN}=== 清理完成 ===${NC}"
    echo -e "使用以下命令重新启动服务:"
    echo -e "${BLUE}docker-compose up -d${NC}"
    exit 0
fi

# 配置 Docker 守护进程
echo ""
echo -e "${YELLOW}=== 配置 Docker 守护进程 ===${NC}"

# 备份现有配置
if [ -f "$DAEMON_JSON" ]; then
    echo -e "${BLUE}备份现有配置到 ${BACKUP_DIR}/daemon.json${NC}"
    mkdir -p "$BACKUP_DIR"
    cp "$DAEMON_JSON" "$BACKUP_DIR/"
fi

# 创建新的配置
mkdir -p $(dirname "$DAEMON_JSON")

if [ "$MODE" == "full" ]; then
    # 完整修复 - 迁移数据目录
    echo -e "${YELLOW}将迁移 Docker 数据目录到: ${DOCKER_DATA_ROOT}${NC}"

    # 停止 Docker
    echo -e "${BLUE}停止 Docker 服务...${NC}"
    systemctl stop docker

    # 迁移数据
    if [ -d /var/lib/docker ] && [ ! -L /var/lib/docker ]; then
        echo -e "${BLUE}迁移 Docker 数据...${NC}"
        mkdir -p "$DOCKER_DATA_ROOT"
        rsync -aP --delete /var/lib/docker/ "$DOCKER_DATA_ROOT/"

        echo -e "${BLUE}备份原目录到 ${BACKUP_DIR}/docker${NC}"
        mv /var/lib/docker "$BACKUP_DIR/"

        echo -e "${BLUE}创建符号链接...${NC}"
        ln -s "$DOCKER_DATA_ROOT" /var/lib/docker
    fi

    # 创建配置
    cat > "$DAEMON_JSON" <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "data-root": "${DOCKER_DATA_ROOT}",
  "storage-driver": "overlay2"
}
EOF

    # 重启 Docker
    echo -e "${BLUE}重启 Docker 服务...${NC}"
    systemctl daemon-reload
    systemctl start docker

    echo -e "${GREEN}Docker 数据目录已迁移到: ${DOCKER_DATA_ROOT}${NC}"

else
    # 快速修复 - 只配置日志限制
    if [ -f "$DAEMON_JSON" ]; then
        # 检查是否已配置
        if grep -q "max-size" "$DAEMON_JSON" 2>/dev/null; then
            echo -e "${GREEN}日志限制已配置，跳过${NC}"
        else
            # 添加到现有配置
            echo -e "${BLUE}添加日志配置到现有配置...${NC}"
            cat > "$DAEMON_JSON" <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
        fi
    else
        # 创建新配置
        cat > "$DAEMON_JSON" <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
    fi

    # 重启 Docker
    echo -e "${BLUE}重启 Docker 服务...${NC}"
    systemctl daemon-reload
    systemctl restart docker

    echo -e "${GREEN}日志限制已配置！${NC}"
fi

# 验证配置
echo ""
echo -e "${YELLOW}=== 验证 Docker 配置 ===${NC}"
docker info | grep -E "Docker Root Dir|Logging Driver|Storage Driver" || true

# 清理容器日志
echo ""
echo -e "${YELLOW}=== 清理现有容器日志 ===${NC}"
if [ -d /var/lib/docker/containers ]; then
    find /var/lib/docker/containers -name "*.log" -type f -truncate-s +0 2>/dev/null
    echo -e "${GREEN}已清空所有容器日志${NC}"
fi

# 完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  修复完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}磁盘使用情况 (修复后):${NC}"
df -h | grep -E "Filesystem|/$|/opt|/var"
echo ""
echo -e "使用以下命令重新启动服务:"
echo -e "${BLUE}  cd /opt/dev/apps/infra && docker-compose up -d${NC}"
echo ""
echo -e "${YELLOW}后续建议:${NC}"
echo "  1. 定期运行: ${BLUE}docker system prune -a --volumes${NC}"
echo "  2. 监控磁盘: ${BLUE}df -h && du -sh /var/lib/docker/*${NC}"
echo ""
