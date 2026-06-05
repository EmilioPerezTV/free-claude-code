# Setup Firewall rule for Free Claude Code
# Run this with Administrator privileges.

$ErrorActionPreference = "Stop"

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Free Claude Code Firewall Setup ===" -ForegroundColor Cyan

# Check if rule exists
$existing = Get-NetFirewallRule -DisplayName "Free Claude Code 8082" -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Firewall rule already exists. Removing..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName "Free Claude Code 8082" -Force
}

# Create new rule
Write-Host "Creating firewall rule for port 8082..." -ForegroundColor Yellow
try {
    New-NetFirewallRule `
        -DisplayName "Free Claude Code 8082" `
        -Direction Inbound `
        -Action Allow `
        -Protocol TCP `
        -LocalPort 8082 `
        -Profile Any `
        -ErrorAction Stop | Out-Null
    
    Write-Host "✓ Firewall rule created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "The server on port 8082 is now accessible from remote machines." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create firewall rule: $_" -ForegroundColor Red
    exit 1
}

# Verify
$rule = Get-NetFirewallRule -DisplayName "Free Claude Code 8082" -ErrorAction SilentlyContinue
if ($rule) {
    Write-Host "Verified: Rule is active and enabled." -ForegroundColor Green
} else {
    Write-Host "WARNING: Could not verify rule creation." -ForegroundColor Yellow
}
