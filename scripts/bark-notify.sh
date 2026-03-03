#!/bin/bash
# Bark notification controller
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

case "$1" in
    notify)
        result=$(send_bark_notification "${2:-Claude}" "${3:-Notification}")
        echo "Sent (HTTP $result)"
        ;;
    start-monitor)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Already running (PID: $(cat "$PID_FILE"))"
            exit 0
        fi
        nohup "$SCRIPT_DIR/monitor.sh" > /dev/null 2>&1 &
        echo $! > "$PID_FILE"
        echo "Started (PID: $!)"
        ;;
    stop-monitor)
        if [ -f "$PID_FILE" ]; then
            pid=$(cat "$PID_FILE")
            kill "$pid" 2>/dev/null
            rm -f "$PID_FILE"
            echo "Stopped (PID: $pid)"
        else
            echo "Not running"
        fi
        ;;
    status)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Running (PID: $(cat "$PID_FILE"))"
            [ -f "$ACTIVITY_FILE" ] && echo "Idle: $(( $(date +%s) - $(cat "$ACTIVITY_FILE") ))s"
            echo "Timeout: ${IDLE_TIMEOUT}s"
            [ -f "$LOG_FILE" ] && echo "---" && tail -5 "$LOG_FILE"
        else
            echo "Not running"
            rm -f "$PID_FILE"
        fi
        ;;
    *)
        echo "Usage: $0 {notify|start-monitor|stop-monitor|status}"
        ;;
esac
