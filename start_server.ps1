# Start the Free Claude Code server in the local Python virtual environment.
# Run from PowerShell in the repository root: .\start_server.ps1

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $projectRoot

Write-Host "Activating virtual environment from $projectRoot\.venv"
. "$projectRoot\.venv\Scripts\Activate.ps1"

Write-Host 'Starting server on http://0.0.0.0:8082'
python server.py
