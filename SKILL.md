---
name: bark-notify
description: Monitor Claude Code activity and send Bark push notifications to iPhone when idle for 60 seconds or when action is needed. Use when the user wants notifications for task completion, permission requests, errors, or idle timeout. Also use when user mentions push notifications, Bark, mobile alerts, or wants to be notified when Claude finishes working. Make sure to use this skill whenever working on long-running tasks, background operations, or when the user might step away.
---

# Bark Push Notification

Send Bark push notifications to iPhone when Claude finishes a task or needs permission. Uses Claude Code Hooks for accurate timing.

## How it works (Hooks-based)

Notifications are triggered by **Claude Code Hooks** configured in `~/.claude/settings.json`:

- **`Stop` hook** → fires when Claude completes a turn and waits for user input → sends "Claude 完成" notification
- **`Notification` hook** → fires when Claude needs user action (permission requests) → sends "Claude 等待" notification

This is accurate because hooks fire at the exact moment Claude finishes, not based on file polling.

## Commands

### Send test notification
```bash
~/.claude/skills/bark-notify/scripts/bark-notify.sh notify "Title" "Body"
```

### Optional: Start idle reminder monitor
Reminds you if you haven't responded to Claude for a while (separate from task-done hooks):
```bash
~/.claude/skills/bark-notify/scripts/bark-notify.sh start-monitor
```

### Stop monitor
```bash
~/.claude/skills/bark-notify/scripts/bark-notify.sh stop-monitor
```

### Check status
```bash
~/.claude/skills/bark-notify/scripts/bark-notify.sh status
```

## Configuration

Edit `~/.claude/skills/bark-notify/scripts/config.sh`:

```bash
BARK_BASE_URL="https://api.day.app/YOUR_KEY"  # Bark API URL
BARK_GROUP="ClaudeCode"                        # Push group name
IDLE_TIMEOUT=300                               # Seconds of user inactivity before reminder (monitor only)
```

## Hooks configuration (in ~/.claude/settings.json)

```json
"hooks": {
  "Stop": [
    {
      "matcher": "",
      "hooks": [{"type": "command", "command": "~/.claude/skills/bark-notify/scripts/bark-notify.sh notify 'Claude 完成' '任务已完成，等待您的指示'"}]
    }
  ],
  "Notification": [
    {
      "matcher": "",
      "hooks": [{"type": "command", "command": "~/.claude/skills/bark-notify/scripts/bark-notify.sh notify 'Claude 等待' '需要您的操作'"}]
    }
  ]
}
```

## Notification types

- **Task complete** (`Stop` hook): Claude finished a turn, waiting for your response
- **Permission needed** (`Notification` hook): Claude is blocked waiting for user action
- **Idle reminder** (monitor, optional): You haven't responded for `IDLE_TIMEOUT` seconds
