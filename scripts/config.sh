#!/bin/bash
# Bark Notification Config
# Modify these values and restart monitor to apply changes.

# ===== User Configuration =====
BARK_BASE_URL="https://api.day.app/uRHAbz386q4D5NmAwkPTsf"
BARK_GROUP="ClaudeCode"
IDLE_TIMEOUT=60

# ===== Internal Paths =====
SKILL_DIR="$HOME/.claude/skills/bark-notify"
PID_FILE="$SKILL_DIR/monitor.pid"
ACTIVITY_FILE="$SKILL_DIR/last_activity"
LOG_FILE="$SKILL_DIR/monitor.log"

# ===== Functions =====
get_project_name() {
    basename "${CLAUDE_PROJECT_PATH:-$(pwd)}"
}

urlencode() {
    python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

send_bark_notification() {
    local title="$1" body="$2"
    local project=$(get_project_name)
    local et=$(urlencode "$title")
    local eb=$(urlencode "[$project] $body")
    curl -s "${BARK_BASE_URL}/${et}/${eb}?group=${BARK_GROUP}" \
        -o /dev/null -w "%{http_code}" 2>&1
}
