# Claude Code Configuration

Centralized Claude Code configuration for syncing across **all projects** and **all computers**.

## Two Types of Configuration

| Type | Location | Purpose | Sync Method |
|------|----------|---------|-------------|
| **Project-level** | `.claude/` in project | Agents, skills, MCP servers | Git + Symlink |
| **User-level** | `~/.claude/` | Settings, credentials, history | Dropbox + Symlink |

---

## 🖥️ Multi-Computer Sync (User-Level)

Sync your Claude Code user settings, credentials, conversation history, and plugins across multiple computers using Dropbox.

### What Gets Synced

```
~/.claude/
├── settings.json        # Model, permissions, enabled plugins
├── credentials.json     # OAuth credentials
├── history.jsonl        # Command history
├── plans/               # Planning scratch files
├── todos/               # Todo lists
├── projects/            # Conversation history per project
└── plugins/             # Installed plugins
```

### Setup

**On your FIRST computer (source of truth):**
```powershell
# Run as Administrator after closing VS Code
.\setup-dropbox-sync.ps1 -SourceOfTruth
```

**On SECOND and THIRD computers (after Dropbox syncs):**
```powershell
# Run as Administrator after closing VS Code
.\setup-dropbox-sync.ps1 -LinkOnly
```

### Requirements
- Windows Developer Mode: ON (Settings → For Developers)
- Dropbox installed and synced
- Close VS Code before running

### Workflow
1. Work on Computer A
2. Close VS Code
3. Wait for Dropbox to sync (seconds)
4. Open VS Code on Computer B
5. Everything is there - settings, history, conversations

---

## 📁 Multi-Project Sync (Project-Level)

Share the same `.claude` folder (agents, skills, MCP servers) across all your projects using symlinks.

### Directory Structure

```
C:\MCP-Config\
├── .claude\
│   ├── agents\              # Custom agents
│   ├── skills\              # Custom skills
│   ├── settings.json        # Project settings
│   └── settings.local.json  # Machine-specific overrides
├── setup-symlink.bat        # Windows setup
├── setup-symlink.sh         # Unix/Mac setup
└── setup-dropbox-sync.ps1   # Multi-computer sync
```

### Setup in Each Project

**Windows (as Administrator):**
```batch
cd C:\Projects\YourProject
C:\MCP-Config\setup-symlink.bat
```

**Unix/Mac/Git Bash:**
```bash
cd ~/Projects/YourProject
bash /c/MCP-Config/setup-symlink.sh
```

### Add to .gitignore in Projects

```gitignore
.claude/
```

---

## ⚙️ Current Configuration

### User Settings (`~/.claude/settings.json`)
```json
{
  "model": "opus",
  "alwaysThinkingEnabled": true,
  "permissions": { "defaultMode": "bypassPermissions" },
  "includeCoAuthoredBy": false,
  "enabledPlugins": {
    "pyright-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true
  }
}
```

### MCP Servers (`.mcp.json`)
- `context7` - Documentation lookup
- `chrome-devtools` - Browser automation

### Native Plugins (LSP)
- `pyright-lsp` - Python/FastAPI
- `typescript-lsp` - TypeScript/React

---

## 🔧 Scripts Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `setup-dropbox-sync.ps1 -SourceOfTruth` | Move ~/.claude to Dropbox | First computer only |
| `setup-dropbox-sync.ps1 -LinkOnly` | Link to Dropbox config | Other computers |
| `setup-symlink.bat` | Link project .claude to central | Each project (Windows) |
| `setup-symlink.sh` | Link project .claude to central | Each project (Unix) |

---

## 🛠️ Troubleshooting

### "Access Denied" on Windows
Run PowerShell/CMD as Administrator, or enable Developer Mode.

### Symlink Not Working
```powershell
# Check if it's a symlink
Get-Item "$env:USERPROFILE\.claude" | Select-Object LinkType, Target
```

### Dropbox Conflict
If you see "Conflicted Copy" files, you had VS Code open on multiple computers. The original file is preserved - just delete the conflicted copy.

---

## 📝 Change Log

| Date | Change |
|------|--------|
| 2026-01-11 | Added Dropbox sync script for multi-computer setup |
| 2026-01-11 | Renamed repo from MCP-Config to Claude-Code-Config |
| 2025-10-XX | Initial setup with project symlink scripts |

---

**Computers:** Work PC, Laptop, Home PC
**Dropbox Path:** `~/Dropbox/STT/claude-config`
**GitHub:** [Yoel-Klein/Claude-Code-Config](https://github.com/Yoel-Klein/Claude-Code-Config)
