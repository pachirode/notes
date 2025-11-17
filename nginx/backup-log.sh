#!/bin/env bash

NGINX_BASE_DIR="/usr/local/nginx"
LOG_DIR="$NGINX_BASE_DIR/logs"
BACKUP_DIR="$NGINX_BASE_DIR/backup"
ACCESS_LOG="access.log"
ERROR_LOG="error.log"
NGINX_PID_FILE="$LOG_DIR/nginx.pid"
RETENTION_DAYS=7
WORKER_USER="nginx"
WORKER_GROUP="nginx"

mkdir -p "$BACKUP_DIR/access" "$BACKUP_DIR/error"

BACKUP_DATE=$(date -d "yesterday" +%Y%m%d)
BACKUP_ACCESS="$BACKUP_DIR/access/${BACKUP_DATE}-$ACCESS_LOG"
BACKUP_ERROR="$BACKUP_DIR/error/${BACKUP_DATE}-$ERROR_LOG"

[ -f "$LOG_DIR/$ACCESS_LOG" ] && mv -v "$LOG_DIR/$ACCESS_LOG" "$BACKUP_ACCESS"
[ -f "$LOG_DIR/$ERROR_LOG" ] && mv -v "$LOG_DIR/$ERROR_LOG" "$BACKUP_ERROR"

# 重新打开日志
if [ -f "$NGINX_PID_FILE" ]; then
    NGINX_PID=$(cat "$NGINX_PID_FILE")
    ps -p "$NGINX_PID" >/dev/null 2>&1 && kill -USR1 "$NGINX_PID"
fi

# 清理旧日志
find "$BACKUP_DIR/access" -type f -mtime +$RETENTION_DAYS -name "*.log" -exec rm -v {} \;
find "$BACKUP_DIR/error" -type f -mtime +$RETENTION_DAYS -name "*.log" -exec rm -v {} \;

