# ==========================
# Ensure TLS 1.2 is Enabled
# ==========================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# ==========================
# Configure JFrog Artifactory as a System-Wide NuGet Source
# ==========================

# Define JFrog Artifactory Source Details
$NuGetSourceName = "Artifactory"
$NuGetSourceUrl = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/v3/nuget-remote/index.json"

# Define Machine-Wide NuGet Config Path
$NuGetConfigDir = "C:\ProgramData\NuGet\Config"
$NuGetConfigPath = "$NuGetConfigDir\NuGet.Config"

# Ensure the Config Directory Exists
if (!(Test-Path $NuGetConfigDir)) {
    Write-Host "Creating NuGet config directory at $NuGetConfigDir"
    New-Item -ItemType Directory -Path $NuGetConfigDir -Force
}

# Remove Existing NuGet Source (if already exists)
if (Test-Path $NuGetConfigPath) {
    if (nuget sources list -ConfigFile $NuGetConfigPath | Select-String -Pattern $NuGetSourceName) {
        Write-Host "Removing existing NuGet source: $NuGetSourceName"
        nuget sources Remove -Name $NuGetSourceName -ConfigFile $NuGetConfigPath
    }
} else {
    Write-Host "NuGet config file not found. Creating a new one."
    New-Item -ItemType File -Path $NuGetConfigPath -Force
}

# Add JFrog Artifactory as a System-Wide NuGet Source
Write-Host "Adding JFrog Artifactory NuGet Source: $NuGetSourceName"
nuget sources Add -Name $NuGetSourceName -Source $NuGetSourceUrl -ConfigFile $NuGetConfigPath

# Verify NuGet Sources
Write-Host "Listing all registered system-wide NuGet sources:"
nuget sources List -ConfigFile $NuGetConfigPath
