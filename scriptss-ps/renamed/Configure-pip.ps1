# =========================================
# Ensure the script runs with Administrator privileges
# =========================================
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "This script must be run as Administrator. Restarting with elevated privileges..."
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting pip repository configuration for all users..."

# =========================================
# Ensure TLS 1.2 is Enabled
# =========================================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# =========================================
# Configure pip Repository (Unregister PyPI & Register Artifactory)
# =========================================
$pipConfigDir = "C:\ProgramData\pip"
$pipConfigPath = "$pipConfigDir\pip.ini"
$RepoSource = "https://prod.artifactory.nfcu.net/artifactory/api/pypi/pypi/simple"

# Ensure the pip.ini directory exists
if (-Not (Test-Path $pipConfigDir)) {
    New-Item -ItemType Directory -Path $pipConfigDir | Out-Null
}

Write-Host "Configuring pip to use Artifactory and remove PyPI..."

# Write the new pip.ini configuration
@"
[global]
index-url = $RepoSource
no-index = true

[install]
trusted-host = prod.artifactory.nfcu.net
"@ | Set-Content -Path $pipConfigPath -Force

Write-Host "pip repository configuration updated at $pipConfigPath"

# =========================================
# Verify pip Configuration
# =========================================
Write-Host "Verifying pip configuration..."
$ConfigCheck = pip config list
Write-Host "Current pip configuration:"
Write-Host $ConfigCheck

Write-Host "pip repository setup completed successfully."
