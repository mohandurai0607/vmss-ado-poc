# ==========================
# Ensure TLS 1.2 is Enabled
# ==========================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# ==========================
# Define NuGet CLI Source from JFrog
# ==========================
$NuGetExePath = "$env:ProgramFiles\NuGet\nuget.exe"
$NuGetFolderPath = "$env:ProgramFiles\NuGet"
$NuGetFromJFrogUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/nuget/windows/nuget.exe"

# Check if NuGet CLI exists, otherwise download from JFrog
if (!(Test-Path $NuGetExePath)) {
    Write-Host "NuGet CLI not found. Downloading from JFrog..."
    
    # Ensure directory exists
    New-Item -ItemType Directory -Path $NuGetFolderPath -Force | Out-Null

    # Download nuget.exe from JFrog
    Invoke-WebRequest -Uri $NuGetFromJFrogUrl -OutFile $NuGetExePath
    Write-Host "NuGet CLI downloaded successfully."
} else {
    Write-Host "NuGet CLI is already installed."
}

# ==========================
# Add NuGet CLI to System PATH
# ==========================
$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
if ($CurrentPath -notlike "*$NuGetFolderPath*") {
    Write-Host "Adding NuGet CLI to System PATH..."
    [System.Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$NuGetFolderPath", "Machine")
} else {
    Write-Host "NuGet CLI is already in the System PATH."
}
# Reload PATH for current session
$env:Path += ";$NuGetFolderPath"

# ==========================
# Configure JFrog Artifactory as a System-Wide NuGet Source
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

# Ensure NuGet Config File Exists
if (!(Test-Path $NuGetConfigPath)) {
    Write-Host "NuGet config file not found. Creating a new one."
    New-Item -ItemType File -Path $NuGetConfigPath -Force | Out-Null
}

# Remove Existing NuGet Source (if already exists)
if (& $NuGetExePath sources list -ConfigFile $NuGetConfigPath | Select-String -Pattern $NuGetSourceName) {
    Write-Host "Removing existing NuGet source: $NuGetSourceName"
    & $NuGetExePath sources Remove -Name $NuGetSourceName -ConfigFile $NuGetConfigPath
}

# Add JFrog Artifactory as a System-Wide NuGet Source
Write-Host "Adding JFrog Artifactory NuGet Source: $NuGetSourceName"
& $NuGetExePath sources Add -Name $NuGetSourceName -Source $NuGetSourceUrl -ConfigFile $NuGetConfigPath

# Verify NuGet Sources
Write-Host "Listing all registered system-wide NuGet sources:"
& $NuGetExePath sources List -ConfigFile $NuGetConfigPath

Write-Host "NuGet CLI installation and repository registration completed successfully!"




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
