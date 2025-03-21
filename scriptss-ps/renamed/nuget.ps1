# ==========================
# Ensure TLS 1.2 is Enabled
# ==========================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# ==========================
# Download NuGet CLI from JFrog (Temporary Use)
# ==========================
$NuGetExePath = "$env:TEMP\nuget.exe"
$NuGetFromJFrogUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/nuget/windows/nuget.exe"

# Download NuGet.exe if not already present
if (!(Test-Path $NuGetExePath)) {
    Write-Host "Downloading NuGet CLI from JFrog..."
    Invoke-WebRequest -Uri $NuGetFromJFrogUrl -OutFile $NuGetExePath
    Write-Host "NuGet CLI downloaded successfully."
} else {
    Write-Host "NuGet CLI already exists in TEMP."
}

# ==========================
# Configure JFrog Artifactory as a NuGet Source
# ==========================
$NuGetSourceName = "Artifactory"
$NuGetSourceUrl = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/v3/nuget-remote/index.json"

# Define Machine-Wide NuGet Config Path
$NuGetConfigDir = "C:\ProgramData\NuGet\Config"
$NuGetConfigPath = "$NuGetConfigDir\NuGet.Config"

# Ensure the Config Directory Exists
if (!(Test-Path $NuGetConfigDir)) {
    Write-Host "Creating NuGet config directory at $NuGetConfigDir"
    New-Item -ItemType Directory -Path $NuGetConfigDir -Force | Out-Null
}

# Ensure NuGet Config File Exists and Has a Valid Structure
if (!(Test-Path $NuGetConfigPath) -or [string]::IsNullOrWhiteSpace((Get-Content $NuGetConfigPath -Raw))) {
    Write-Host "NuGet config file not found or invalid. Creating a valid one."
    @"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
    </packageSources>
</configuration>
"@ | Set-Content -Path $NuGetConfigPath -Encoding UTF8 -Force
}

# Remove Existing NuGet Source (if already exists)
if (& $NuGetExePath sources list -ConfigFile $NuGetConfigPath | Select-String -Pattern $NuGetSourceName) {
    Write-Host "Removing existing NuGet source: $NuGetSourceName"
    & $NuGetExePath sources Remove -Name $NuGetSourceName -ConfigFile $NuGetConfigPath
}

# Add JFrog Artifactory as a NuGet Source
Write-Host "Adding JFrog Artifactory NuGet Source: $NuGetSourceName"
& $NuGetExePath sources Add -Name $NuGetSourceName -Source $NuGetSourceUrl -ConfigFile $NuGetConfigPath

# Verify NuGet Sources
Write-Host "Listing all registered NuGet sources:"
& $NuGetExePath sources List -ConfigFile $NuGetConfigPath

Write-Host "NuGet configuration completed successfully!"


# # ==========================
# # Ensure TLS 1.2 is Enabled
# # ==========================
# Write-Host "Ensuring TLS1.2 is configured for use..."
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# # ==========================
# # Configure JFrog Artifactory as a System-Wide NuGet Source
# # ==========================

# # Define JFrog Artifactory Source Details
# $NuGetSourceName = "Artifactory"
# $NuGetSourceUrl = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/v3/nuget-remote/index.json"

# # Define Machine-Wide NuGet Config Path
# $NuGetConfigDir = "C:\ProgramData\NuGet\Config"
# $NuGetConfigPath = "$NuGetConfigDir\NuGet.Config"

# # Ensure the Config Directory Exists
# if (!(Test-Path $NuGetConfigDir)) {
#     Write-Host "Creating NuGet config directory at $NuGetConfigDir"
#     New-Item -ItemType Directory -Path $NuGetConfigDir -Force
# }

# # Remove Existing NuGet Source (if already exists)
# if (Test-Path $NuGetConfigPath) {
#     if (nuget sources list -ConfigFile $NuGetConfigPath | Select-String -Pattern $NuGetSourceName) {
#         Write-Host "Removing existing NuGet source: $NuGetSourceName"
#         nuget sources Remove -Name $NuGetSourceName -ConfigFile $NuGetConfigPath
#     }
# } else {
#     Write-Host "NuGet config file not found. Creating a new one."
#     New-Item -ItemType File -Path $NuGetConfigPath -Force
# }

# # Add JFrog Artifactory as a System-Wide NuGet Source
# Write-Host "Adding JFrog Artifactory NuGet Source: $NuGetSourceName"
# nuget sources Add -Name $NuGetSourceName -Source $NuGetSourceUrl -ConfigFile $NuGetConfigPath

# # Verify NuGet Sources
# Write-Host "Listing all registered system-wide NuGet sources:"
# nuget sources List -ConfigFile $NuGetConfigPath
