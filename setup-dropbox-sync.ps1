#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up Claude Code config sync via Dropbox symlink

.DESCRIPTION
    This script moves ~/.claude to Dropbox and creates a symlink,
    enabling Claude Code settings to sync across multiple computers.

.PARAMETER SourceOfTruth
    If specified, this computer's .claude folder becomes the source.
    Use this on the FIRST computer only.

.PARAMETER LinkOnly
    If specified, only creates the symlink (assumes Dropbox already has the config).
    Use this on the SECOND and THIRD computers.

.EXAMPLE
    # On first computer (Work PC - source of truth):
    .\setup-claude-sync.ps1 -SourceOfTruth

    # On other computers (Laptop, Home PC):
    .\setup-claude-sync.ps1 -LinkOnly
#>

param(
    [switch]$SourceOfTruth,
    [switch]$LinkOnly
)

$ErrorActionPreference = "Stop"

# Paths
$claudeLocal = "$env:USERPROFILE\.claude"
$dropboxConfig = "$env:USERPROFILE\Dropbox\STT\claude-config"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Claude Code Sync Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if VS Code is running
$vscodeProcesses = Get-Process -Name "Code" -ErrorAction SilentlyContinue
if ($vscodeProcesses) {
    Write-Host "[ERROR] VS Code is still running!" -ForegroundColor Red
    Write-Host "Please close VS Code completely and run this script again.`n" -ForegroundColor Yellow
    exit 1
}

# Check Developer Mode (required for symlinks without admin)
$devMode = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
if (-not $devMode) {
    Write-Host "[WARNING] Developer Mode is not enabled." -ForegroundColor Yellow
    Write-Host "Symlinks may require Administrator privileges.`n" -ForegroundColor Yellow
}

# Check if already a symlink
if (Test-Path $claudeLocal) {
    $item = Get-Item $claudeLocal -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "[INFO] ~/.claude is already a symlink!" -ForegroundColor Green
        Write-Host "Target: $($item.Target)`n" -ForegroundColor Gray
        exit 0
    }
}

# Validate parameters
if (-not $SourceOfTruth -and -not $LinkOnly) {
    Write-Host "Please specify a mode:`n" -ForegroundColor Yellow
    Write-Host "  -SourceOfTruth  : Use this computer's config as the master (FIRST computer only)"
    Write-Host "  -LinkOnly       : Link to existing Dropbox config (OTHER computers)`n"
    Write-Host "Example:" -ForegroundColor Gray
    Write-Host "  .\setup-claude-sync.ps1 -SourceOfTruth`n" -ForegroundColor Gray
    exit 1
}

if ($SourceOfTruth -and $LinkOnly) {
    Write-Host "[ERROR] Cannot use both -SourceOfTruth and -LinkOnly" -ForegroundColor Red
    exit 1
}

# Check Dropbox folder exists
$dropboxRoot = "$env:USERPROFILE\Dropbox"
if (-not (Test-Path $dropboxRoot)) {
    Write-Host "[ERROR] Dropbox folder not found at: $dropboxRoot" -ForegroundColor Red
    Write-Host "Please install Dropbox and sign in first.`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Dropbox folder found" -ForegroundColor Green

# SOURCE OF TRUTH MODE
if ($SourceOfTruth) {
    Write-Host "`n[MODE] Source of Truth - Moving config to Dropbox`n" -ForegroundColor Cyan

    # Check local .claude exists
    if (-not (Test-Path $claudeLocal)) {
        Write-Host "[ERROR] No ~/.claude folder found. Run Claude Code first to create it." -ForegroundColor Red
        exit 1
    }

    # Create Dropbox destination
    Write-Host "[1/4] Creating Dropbox folder..." -ForegroundColor White
    New-Item -ItemType Directory -Path $dropboxConfig -Force | Out-Null
    Write-Host "       Created: $dropboxConfig" -ForegroundColor Gray

    # Move contents
    Write-Host "[2/4] Moving contents to Dropbox..." -ForegroundColor White
    $items = Get-ChildItem -Path $claudeLocal -Force
    foreach ($item in $items) {
        Move-Item -Path $item.FullName -Destination $dropboxConfig -Force
        Write-Host "       Moved: $($item.Name)" -ForegroundColor Gray
    }

    # Remove empty folder
    Write-Host "[3/4] Removing empty local folder..." -ForegroundColor White
    Remove-Item $claudeLocal -Force

    # Create symlink
    Write-Host "[4/4] Creating symlink..." -ForegroundColor White
    New-Item -ItemType SymbolicLink -Path $claudeLocal -Target $dropboxConfig | Out-Null
}

# LINK ONLY MODE
if ($LinkOnly) {
    Write-Host "`n[MODE] Link Only - Creating symlink to existing Dropbox config`n" -ForegroundColor Cyan

    # Check Dropbox config exists
    if (-not (Test-Path $dropboxConfig)) {
        Write-Host "[ERROR] Dropbox config not found at: $dropboxConfig" -ForegroundColor Red
        Write-Host "Please run with -SourceOfTruth on your main computer first.`n" -ForegroundColor Yellow
        Write-Host "Or wait for Dropbox to sync.`n" -ForegroundColor Yellow
        exit 1
    }

    # Backup and remove local
    if (Test-Path $claudeLocal) {
        Write-Host "[1/2] Removing local .claude folder..." -ForegroundColor White
        $backupPath = "$env:USERPROFILE\.claude-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Host "       Backing up to: $backupPath" -ForegroundColor Gray
        Move-Item $claudeLocal $backupPath -Force
    }

    # Create symlink
    Write-Host "[2/2] Creating symlink..." -ForegroundColor White
    New-Item -ItemType SymbolicLink -Path $claudeLocal -Target $dropboxConfig | Out-Null
}

# Verify
Write-Host "`n----------------------------------------" -ForegroundColor Gray
Write-Host "[VERIFICATION]" -ForegroundColor Cyan
$result = Get-Item $claudeLocal -Force | Select-Object FullName, LinkType, Target
Write-Host "Path:     $($result.FullName)" -ForegroundColor White
Write-Host "LinkType: $($result.LinkType)" -ForegroundColor $(if ($result.LinkType -eq "SymbolicLink") { "Green" } else { "Red" })
Write-Host "Target:   $($result.Target)" -ForegroundColor White

if ($result.LinkType -eq "SymbolicLink") {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  SUCCESS! Symlink created." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "`nYou can now open VS Code.`n" -ForegroundColor White

    if ($SourceOfTruth) {
        Write-Host "NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Wait for Dropbox to sync (green checkmark)"
        Write-Host "2. On other computers, run:"
        Write-Host "   .\setup-claude-sync.ps1 -LinkOnly`n" -ForegroundColor Gray
    }
} else {
    Write-Host "`n[ERROR] Symlink creation failed!" -ForegroundColor Red
    exit 1
}
