#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Undoes Dropbox sync and cleans up Claude Code cache files

.DESCRIPTION
    This script:
    1. Removes the Dropbox symlink if it exists
    2. Copies essential files back from Dropbox to local ~/.claude
    3. Cleans up cache/temp files (saves ~110MB)
    4. Optionally deletes the Dropbox sync folder

.EXAMPLE
    .\cleanup-dropbox-sync.ps1
#>

$ErrorActionPreference = "Stop"

# Paths
$claudeLocal = "$env:USERPROFILE\.claude"
$dropboxConfig = "$env:USERPROFILE\Dropbox\STT\claude-config"

# Folders to DELETE (cache/temp - not needed for sync)
$foldersToDelete = @(
    "file-history",      # 107MB+ of file change history
    "shell-snapshots",   # Shell state snapshots
    "debug",             # Debug logs
    "paste-cache",       # Paste cache
    "statsig",           # Telemetry/analytics
    "telemetry",         # More telemetry
    "plugins/cache",     # Plugin cache (regenerates)
    ".anthropic"         # Anthropic cache
)

# Files to DELETE
$filesToDelete = @(
    "stats-cache.json"   # Stats cache
)

# Folders to KEEP (essential for sync)
$foldersToKeep = @(
    "projects",          # Conversation history
    "plans",             # Planning files
    "todos",             # Todo lists
    "plugins"            # Plugin configs (not cache)
)

# Files to KEEP
$filesToKeep = @(
    "settings.json",         # User settings
    ".credentials.json",     # Login credentials
    "credentials.json",      # Alt credentials location
    "history.jsonl",         # Command history
    "mcp.json",              # MCP config
    "statusline.js",         # Statusline script
    "config.json"            # Config
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Claude Code Cleanup Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if VS Code is running
$vscodeProcesses = Get-Process -Name "Code" -ErrorAction SilentlyContinue
if ($vscodeProcesses) {
    Write-Host "[ERROR] VS Code is still running!" -ForegroundColor Red
    Write-Host "Please close VS Code completely and run this script again.`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] VS Code is closed" -ForegroundColor Green

# Detect current state
$isSymlink = $false
$sourceFolder = $null

if (Test-Path $claudeLocal) {
    $item = Get-Item $claudeLocal -Force
    if ($item.LinkType -eq "SymbolicLink") {
        $isSymlink = $true
        $sourceFolder = $item.Target
        Write-Host "[DETECTED] ~/.claude is a SYMLINK to: $sourceFolder" -ForegroundColor Yellow
    } else {
        Write-Host "[DETECTED] ~/.claude is a regular folder" -ForegroundColor Gray
        $sourceFolder = $claudeLocal
    }
} else {
    Write-Host "[DETECTED] ~/.claude does not exist" -ForegroundColor Gray
}

# Check Dropbox folder
$hasDropbox = Test-Path $dropboxConfig
if ($hasDropbox) {
    $dropboxSize = (Get-ChildItem $dropboxConfig -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "[DETECTED] Dropbox config exists: $dropboxConfig ($([math]::Round($dropboxSize, 2)) MB)" -ForegroundColor Yellow
}

Write-Host ""

# Step 1: Handle symlink
if ($isSymlink) {
    Write-Host "[1/4] Removing symlink..." -ForegroundColor White
    Remove-Item $claudeLocal -Force
    Write-Host "       Symlink removed" -ForegroundColor Gray

    # Create fresh folder
    New-Item -ItemType Directory -Path $claudeLocal -Force | Out-Null
    Write-Host "       Created fresh ~/.claude folder" -ForegroundColor Gray

    # Copy from Dropbox if available
    if ($hasDropbox) {
        Write-Host "       Copying files from Dropbox..." -ForegroundColor Gray
        Get-ChildItem $dropboxConfig -Force | ForEach-Object {
            Copy-Item $_.FullName -Destination $claudeLocal -Recurse -Force
            Write-Host "         Copied: $($_.Name)" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "[1/4] No symlink to remove (skipping)" -ForegroundColor Gray
}

# Step 2: Calculate size before cleanup
Write-Host "`n[2/4] Analyzing files to clean..." -ForegroundColor White
$totalSaved = 0

foreach ($folder in $foldersToDelete) {
    $path = Join-Path $claudeLocal $folder
    if (Test-Path $path) {
        $size = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        $fileCount = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
        Write-Host "       $folder : $sizeMB MB ($fileCount files)" -ForegroundColor Gray
        $totalSaved += $size
    }
}

foreach ($file in $filesToDelete) {
    $path = Join-Path $claudeLocal $file
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        Write-Host "       $file : $([math]::Round($size / 1KB, 2)) KB" -ForegroundColor Gray
        $totalSaved += $size
    }
}

Write-Host "`n       Total to clean: $([math]::Round($totalSaved / 1MB, 2)) MB" -ForegroundColor Yellow

# Step 3: Delete cache folders and files
Write-Host "`n[3/4] Cleaning cache files..." -ForegroundColor White

foreach ($folder in $foldersToDelete) {
    $path = Join-Path $claudeLocal $folder
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "       Deleted: $folder" -ForegroundColor Gray
    }
}

foreach ($file in $filesToDelete) {
    $path = Join-Path $claudeLocal $file
    if (Test-Path $path) {
        Remove-Item $path -Force -ErrorAction SilentlyContinue
        Write-Host "       Deleted: $file" -ForegroundColor Gray
    }
}

Write-Host "       Cache cleanup complete!" -ForegroundColor Green

# Step 4: Delete Dropbox folder
if ($hasDropbox) {
    Write-Host "`n[4/4] Dropbox cleanup..." -ForegroundColor White

    $response = Read-Host "       Delete Dropbox sync folder? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Remove-Item $dropboxConfig -Recurse -Force
        Write-Host "       Deleted: $dropboxConfig" -ForegroundColor Gray

        # Also try to remove parent if empty
        $parentFolder = Split-Path $dropboxConfig -Parent
        if ((Get-ChildItem $parentFolder -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
            Remove-Item $parentFolder -Force -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "       Skipped (Dropbox folder kept)" -ForegroundColor Gray
    }
} else {
    Write-Host "`n[4/4] No Dropbox folder to clean (skipping)" -ForegroundColor Gray
}

# Final summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  CLEANUP COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Show what's left
Write-Host "`nRemaining in ~/.claude:" -ForegroundColor White
$remaining = Get-ChildItem $claudeLocal -Force -ErrorAction SilentlyContinue
foreach ($item in $remaining) {
    $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
    Write-Host "  $type $($item.Name)" -ForegroundColor Gray
}

$finalSize = (Get-ChildItem $claudeLocal -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "`nTotal size: $([math]::Round($finalSize, 2)) MB" -ForegroundColor Cyan
Write-Host "Space saved: $([math]::Round($totalSaved / 1MB, 2)) MB`n" -ForegroundColor Green

Write-Host "You can now open VS Code.`n" -ForegroundColor White
