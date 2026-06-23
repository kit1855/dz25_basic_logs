#!/bin/bash
echo "=== Check logs on log-server ==="
ssh log "tail -n 5 /var/log/rsyslog/web/nginx_access.log 2>/dev/null || echo 'No logs yet'"
