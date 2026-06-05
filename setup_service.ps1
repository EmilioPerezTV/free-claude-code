# Setup Windows Service for Free Claude Code
# This script downloads nssm, installs it, and creates the service.
# Run this with Administrator privileges.

$ErrorActionPreference = "Stop"

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    exit 1
}

$projectRoot = "C:\Developer\free-claude-code"
$nssmDir = "$projectRoot\tools\nssm"
$nssmExe = "$nssmDir\nssm.exe"

# Try GitHub releases first, fallback to nssm.cc
$nssmUrls = @(
    "https://github.com/nssm/nssm/releases/download/2.24/nssm-2.24-101-g897c7ad.zip",
    "https://nssm.cc/download/nssm-2.24-101-g897c7ad.zip"
)

Write-Host "=== Free Claude Code Service Setup ===" -ForegroundColor Cyan

# Download and extract nssm if not present
if (-not (Test-Path $nssmExe)) {
    Write-Host "Downloading nssm..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $nssmDir | Out-Null
    
    $zipPath = "$nssmDir\nssm.zip"
    $downloaded = $false
    
    foreach ($url in $nssmUrls) {
        Write-Host "Attempting: $url" -ForegroundColor Gray
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -AllowInsecureRedirect -ErrorAction Stop
            Write-Host "Download successful from: $url" -ForegroundColor Green
            $downloaded = $true
            break
        } catch {
            Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Yellow
            continue
        }
    }
    
    if (-not $downloaded) {
        Write-Host "ERROR: Could not download nssm from any source." -ForegroundColor Red
        Write-Host "Manual setup required:" -ForegroundColor Yellow
        Write-Host "1. Download nssm from: https://nssm.cc/download" -ForegroundColor White
        Write-Host "2. Extract to: $nssmDir" -ForegroundColor White
        Write-Host "3. Ensure nssm.exe is at: $nssmExe" -ForegroundColor White
        Write-Host "4. Run this script again" -ForegroundColor White
        exit 1
    }
    
    try {
        Write-Host "Extracting nssm..." -ForegroundColor Yellow
        Expand-Archive -Path $zipPath -DestinationPath $nssmDir -Force
        
        # Find nssm.exe in extracted folder
        $extractedNssm = Get-ChildItem -Path $nssmDir -Recurse -Filter "nssm.exe" | Select-Object -First 1
        if ($extractedNssm) {
            Copy-Item -Path $extractedNssm.FullName -Destination $nssmExe -Force
            Write-Host "nssm extracted to $nssmExe" -ForegroundColor Green
        } else {
            throw "Could not find nssm.exe in extracted files"
        }
        
        Remove-Item -Path $zipPath -Force
    } catch {
        Write-Host "ERROR: Failed to extract nssm: $_" -ForegroundColor Red
        exit 1
    }
}

# Create/update service
$serviceName = "FreeClaudeCode"
$psExe = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$scriptPath = "$projectRoot\start_server.ps1"
$appDir = $projectRoot

Write-Host "Creating service: $serviceName" -ForegroundColor Yellow

# Remove existing service if present
$existing = & sc.exe query $serviceName 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Service already exists, stopping it..." -ForegroundColor Yellow
    & sc.exe stop $serviceName | Out-Null
    Start-Sleep -Seconds 2
    & sc.exe delete $serviceName | Out-Null
    Write-Host "Old service removed." -ForegroundColor Green
}

# Create service
& $nssmExe install $serviceName "$psExe" "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install service" -ForegroundColor Red
    exit 1
}

# Configure service
& $nssmExe set $serviceName AppDirectory "$appDir"
& $nssmExe set $serviceName AppStdout "$appDir\logs\service.log"
& $nssmExe set $serviceName AppStderr "$appDir\logs\service.log"
& $nssmExe set $serviceName Start SERVICE_AUTO_START
& $nssmExe set $serviceName Type SERVICE_WIN32_OWN_PROCESS

Write-Host "Service configured." -ForegroundColor Green

# Create logs directory
New-Item -ItemType Directory -Force -Path "$appDir\logs" | Out-Null

# Start service
Write-Host "Starting service..." -ForegroundColor Yellow
& sc.exe start $serviceName

Start-Sleep -Seconds 2

# Verify
$status = & sc.exe query $serviceName | Select-String "STATE"
if ($status) {
    Write-Host "Service Status: $status" -ForegroundColor Green
    Write-Host "✓ Service created and started successfully!" -ForegroundColor Green
} else {
    Write-Host "Could not verify service status. Check manually with: sc query FreeClaudeCode" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Service is running. Access the application at:" -ForegroundColor Cyan
Write-Host "  Local:  http://127.0.0.1:8082/admin" -ForegroundColor White
Write-Host "  Remote: http://<host-ip>:8082/admin" -ForegroundColor White

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  sc query FreeClaudeCode         - Check service status" -ForegroundColor Gray
Write-Host "  sc stop FreeClaudeCode          - Stop service" -ForegroundColor Gray
Write-Host "  sc start FreeClaudeCode         - Start service" -ForegroundColor Gray
Write-Host "  Get-Content $appDir\logs\service.log -Tail 20    - View recent logs" -ForegroundColor Gray
