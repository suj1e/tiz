#!/bin/bash
# Nexora 基础设施备份脚本

set -e

echo "=========================================="
echo "   Nexora Infrastructure Backup"
echo "=========================================="
echo ""

# 使用 docker compose 还是 docker-compose
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_DIR"

# 创建备份目录
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backup directory: $BACKUP_DIR"
echo ""

# 备份 MySQL
echo "Backing up MySQL..."
$DOCKER_COMPOSE exec -T mysql mysqldump -u root -pNexora@2026 --all-databases > "$BACKUP_DIR/mysql_all.sql"
echo "  MySQL backup completed"

# 备份 Nacos 配置
echo "Backing up Nacos configuration..."
curl -s -X GET "http://localhost:30006/nacos/v1/cs/configs?export=true&group=&tenant=&appName=" -o "$BACKUP_DIR/nacos_config.zip"
echo "  Nacos configuration backup completed"

# 备份 Redis
echo "Backing up Redis..."
$DOCKER_COMPOSE exec -T redis redis-cli --rdb /data/dump_backup.rdb
$DOCKER_COMPOSE cp nexora-redis:/data/dump_backup.rdb "$BACKUP_DIR/redis_dump.rdb"
echo "  Redis backup completed"

# 备份 Elasticsearch
echo "Backing up Elasticsearch..."
curl -s -u elastic:Nexora@2026 "http://localhost:30003/_snapshot/backup_repo" -X PUT -H 'Content-Type: application/json' -d '{"type":"fs","settings":{"location":"/usr/share/elasticsearch/backup"}}' || true
echo "  Elasticsearch backup location prepared"

echo ""
echo "=========================================="
echo "Backup completed: $BACKUP_DIR"
echo "=========================================="
echo ""
ls -lh "$BACKUP_DIR"
echo ""
