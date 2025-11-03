# MCP Configuration Setup - COMPLETE ✅

## What Was Done

✅ **Created** `C:\MCP-Config\` directory
✅ **Moved** your `.claude` configuration from the project to `C:\MCP-Config\.claude`
✅ **Initialized** Git repository in `C:\MCP-Config`
✅ **Created** setup scripts for creating symlinks (`setup-symlink.bat` and `setup-symlink.sh`)
✅ **Wrote** comprehensive README with instructions
✅ **Updated** project `.gitignore` to exclude `.claude/`
✅ **Committed** initial version to Git

## What You Need to Do Next

### 1. Create Symlink in This Project (REQUIRES ADMIN)

The `.claude` folder has been **removed** from your project. You need to create a symlink to the centralized config:

**Option A: Run the project-specific script (RECOMMENDED)**
```batch
Right-click: setup-claude-symlink.bat
Select: "Run as administrator"
```

**Option B: Run the central script manually**
```batch
Right-click PowerShell or CMD
Select: "Run as administrator"
cd C:\Projects\STT\A Skytek SMS Platform
C:\MCP-Config\setup-symlink.bat
```

**To verify the symlink worked:**
```batch
dir .claude
```
You should see: `.claude [C:\MCP-Config\.claude]`

---

### 2. Create GitHub Repository

```bash
# Go to GitHub.com and create a new repository called "MCP-Config" (or similar)
# Then run these commands:

cd C:\MCP-Config
git remote add origin https://github.com/YOUR-USERNAME/MCP-Config.git
git branch -M main
git push -u origin main
```

**Important**: Update the GitHub URL in `.gitignore` comment (line 26 of project .gitignore)

---

### 3. Remove .claude from Git History (Optional but Recommended)

Since you previously committed `.claude/` to your project repo, you should remove it from Git history:

```bash
cd "C:\Projects\STT\A Skytek SMS Platform"

# Remove .claude from Git tracking
git rm -r --cached .claude

# Commit the change
git add .gitignore
git commit -m "Remove .claude folder (now using centralized config via symlink)"

# Push to remote
git push
```

---

### 4. Set Up on Other Computers

When you work on another computer:

1. **Clone the MCP config repo:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/MCP-Config.git C:\MCP-Config
   ```

2. **Clone your project as usual:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/your-project.git
   ```

3. **Create the symlink (as Administrator):**
   ```batch
   cd your-project
   C:\MCP-Config\setup-symlink.bat
   ```

---

## File Structure

```
C:\MCP-Config\
├── .claude\
│   ├── mcp.json               # Your MCP servers (chrome-devtools, context7)
│   ├── settings.json          # Global settings
│   ├── settings.local.json    # Machine-specific (not synced)
│   ├── skills\                # Your git-deploy skill
│   └── mcp-profiles\          # ai-dev, chrome-only, full, minimal, etc.
├── .git\                      # Git repository
├── .gitignore                 # Excludes settings.local.json
├── README.md                  # Full documentation
├── setup-symlink.bat          # Windows setup script
├── setup-symlink.sh           # Unix/Mac setup script
└── SETUP_COMPLETE.md          # This file

C:\Projects\STT\A Skytek SMS Platform\
├── .claude -> C:\MCP-Config\.claude  # Symlink (after you create it)
├── .gitignore                 # Updated to exclude .claude/
├── setup-claude-symlink.bat   # Helper script (delete after using)
└── [rest of your project]
```

---

## Benefits You'll See

✅ **One config to rule them all**: Change MCP settings once, affects all projects
✅ **Git sync**: Push from one computer, pull on another
✅ **Clean repos**: No more `.claude/` in project Git history
✅ **Easy setup**: New projects just need one script run
✅ **Flexible**: Can still override per-project if needed

---

## Troubleshooting

### "Access Denied" when creating symlink
- You need Administrator privileges
- Right-click script and "Run as administrator"

### Symlink shows as a file, not a folder
- This is normal on Windows
- Claude Code will treat it as a folder
- Use `dir .claude` to see the symlink target

### MCP servers not loading after symlink
1. Restart Claude Code
2. Check symlink points to correct location: `dir .claude`
3. Verify `C:\MCP-Config\.claude\mcp.json` exists and is valid JSON

### Changes not syncing to other computers
```bash
cd C:\MCP-Config
git pull  # Get latest
# Make changes
git add .
git commit -m "Updated MCP config"
git push  # Share with other computers
```

---

## Current MCP Configuration

Your centralized config includes:

**MCP Servers:**
- `chrome-devtools` → `C:\Projects\chrome-devtools-mcp\server.py`
- `context7` → `npx @upstash/context7-mcp@latest`

**MCP Profiles:**
- `minimal` - No MCP servers (0 tokens)
- `chrome-only` - Chrome DevTools only
- `context7-only` - Context7 only
- `ai-dev` - Both servers
- `full` - All available servers

**Skills:**
- `git-deploy` - Automated deployment skill for Skytek SMS Platform

---

## Next Session Checklist

Before your next coding session:

- [ ] Create symlink (run setup-claude-symlink.bat as Admin)
- [ ] Verify symlink works (`dir .claude` shows symlink)
- [ ] Test Claude Code loads with MCP servers
- [ ] Push MCP-Config to GitHub
- [ ] Remove .claude from project Git history
- [ ] Update other projects with symlinks

---

**Questions?** Check `C:\MCP-Config\README.md` for full documentation.

---

**Created**: October 28, 2025
**Status**: ✅ Setup complete - awaiting symlink creation and GitHub push
