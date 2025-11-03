# Git Deploy Skill

Autonomously commit, sync, and deploy code changes with intelligent monitoring.

## Objective

Execute git operations (commit, pull, push) with minimal token usage and smart deployment verification.

## Execution Steps

### 1. Check for Changes
```bash
git status --short
```
- If no changes: Output "No changes to deploy" and EXIT
- Continue if changes exist

### 2. Analyze Changed Files
```bash
git diff --stat
```
**Determine deployment impact:**
- **Auto-push (restart needed):** `backend/**/*.py`, `backend/requirements.txt`, `.github/workflows/*.yml`
- **Ask user (no restart):** `static/**`, `*.md`, `docs/**`

### 3. Stage All Changes
```bash
git add .
```

### 4. Generate Commit Message
- Review staged changes: `git diff --cached --stat`
- Generate concise message (max 72 chars): `type: description`
- **Types:** `feat:`, `fix:`, `refactor:`, `cleanup:`, `docs:`
- Commit:
```bash
git commit -m "message"
```

### 5. Sync with Remote
```bash
git pull --rebase
```
- If conflicts: Output "❌ Merge conflicts - manual resolution needed" and EXIT
- Continue if successful

### 6. Push Decision
- **If backend changes:** Push automatically
- **If only frontend/docs:** Ask user: "Push to remote? (triggers deployment)"
- If user says no: EXIT

### 7. Push to Remote
```bash
git push
```
- If push fails: Output "❌ Push failed: [error]" and EXIT
- Continue if successful

### 8. Monitor Deployment (if pushed)
Output: `🚀 Deploying...`

**Poll health endpoint:**
```bash
for i in {1..12}; do
  if curl -f -m 5 https://skyteksms.com/health 2>/dev/null; then
    echo "up:$i"
    exit 0
  fi
  sleep 5
done
echo "timeout"
```

**Report based on result:**
- Success: `✅ Server is up ([time]s)` where time = attempt * 5
- Timeout: `❌ Server not responding after 60s - check logs`

## Output Format

### SUCCESS (Fast Deployment)
```
✅ fix: update SMS validation
🚀 Deploying...
✅ Server is up (20s)
```

### SUCCESS (Slow Deployment)
```
✅ feat: add webhook handler
🚀 Deploying...
✅ Server is up (55s)
```

### SUCCESS (Local Only)
```
✅ docs: update README
(committed locally)
```

### FAILURE
```
❌ Server not responding after 60s - check logs
```

## Critical Rules

1. **NO verbose output** - Single line status only
2. **NO streaming** - Suppress git/curl output
3. **Smart auto-push** - Backend changes push automatically
4. **Verify deployment** - Always check health after push
5. **Exact timing** - Report actual deployment duration
6. **Handle errors** - Report and exit cleanly on failures

## Token Optimization

- Use `--stat` instead of full diffs
- Suppress all command stderr/stdout except status
- Single-line progress updates only
- No explanations unless error occurs

## Setup Instructions

### Option 1: Shared Config (Recommended)

1. Copy this file to: `C:\MCP-Config\.claude\skills\git-deploy.md`
2. In project root, create `.claude` file pointing to shared config:
   ```
   C:/MCP-Config/.claude
   ```

### Option 2: Local Config

1. Copy to: `<project>/.claude/skills/git-deploy.md`
2. Restart VS Code

## Why This Skill?

- ⚡ **5-second polling** (adaptive, not fixed wait)
- 📊 **Exact timing** ("Server is up (20s)" instead of "deployed")
- 🎯 **Smart auto-push** (backend = auto, frontend = ask)
- 💰 **Token efficient** (minimal output, no verbose logs)
- ✅ **Error handling** (clean exits on conflicts/failures)
