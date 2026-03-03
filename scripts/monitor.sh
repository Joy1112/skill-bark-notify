#!/bin/bash
# Bark notification background monitor daemon
source "$(dirname "$0")/config.sh"

HISTORY_FILE="$HOME/.claude/history.jsonl"
last_size=0
notified=false

update_activity() { date +%s > "$ACTIVITY_FILE"; }

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

get_status_type() {
    python3 -c "
import json, sys
try:
    line = open(sys.argv[1]).readlines()[-1]
    print(json.loads(line).get('type', ''))
except: print('')
" "$HISTORY_FILE" 2>/dev/null
}

log "Monitor started (IDLE_TIMEOUT=${IDLE_TIMEOUT}s)"
update_activity

while true; do
    if [ -f "$HISTORY_FILE" ]; then
        current_size=$(stat -c%s "$HISTORY_FILE" 2>/dev/null || stat -f%z "$HISTORY_FILE" 2>/dev/null)
        if [ "$current_size" != "$last_size" ]; then
            update_activity
            last_size=$current_size
            notified=false
        fi
    fi

    if ! $notified && [ -f "$ACTIVITY_FILE" ]; then
        idle_time=$(( $(date +%s) - $(cat "$ACTIVITY_FILE") ))
        if [ $idle_time -ge $IDLE_TIMEOUT ]; then
            status_type=$(get_status_type)
            case "$status_type" in
                *permission*)   send_bark_notification "Claude waiting" "Need authorization" ;;
                *complete*|*done*) send_bark_notification "Claude done" "Task completed" ;;
                *error*|*rate*) send_bark_notification "Claude error" "Check session" ;;
                *)              send_bark_notification "Claude idle" "Idle ${IDLE_TIMEOUT}s+" ;;
            esac
            log "Notified: ${status_type:-idle}"
            notified=true
        fi
    fi

    sleep 10
done
