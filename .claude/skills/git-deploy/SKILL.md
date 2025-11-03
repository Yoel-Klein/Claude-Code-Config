---
name: git-deploy
description: Automatically commits code changes, pushes to GitHub, and deploys to production server after Claude completes coding tasks (project)
---

# Git Deploy Workflow - Minimal Output Mode

You have just completed code changes. Commit, push, and deploy with minimal output.

## Instructions

Simply run the auto-deploy script which handles everything automatically:

```bash
bash .claude/skills/git-deploy/auto-deploy.sh
```

**That's it!** The script will:
- Analyze changes
- Generate smart commit message
- Stage and commit
- Push to GitHub
- Deploy if backend changed
- Output only one line:
  - `✅ Success: <commit message> (<hash>) → Deployed to production`
  - `✅ Success: <commit message> (<hash>) → No deployment needed`
  - `❌ Failed: <error reason>`

## Important
- Do NOT run manual git commands
- Do NOT show intermediate progress
- The script handles everything silently
