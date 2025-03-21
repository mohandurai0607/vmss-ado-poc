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
$NuGetConfigPath = "C:\ProgramData\NuGet\Config\NuGet.Config"

# Remove Existing NuGet Source (if already exists)
if (nuget sources list -ConfigFile $NuGetConfigPath | Select-String -Pattern $NuGetSourceName) {
    Write-Host "Removing existing NuGet source: $NuGetSourceName"
    nuget sources Remove -Name $NuGetSourceName -ConfigFile $NuGetConfigPath
}

# Add JFrog Artifactory as a System-Wide NuGet Source
Write-Host "Adding JFrog Artifactory NuGet Source: $NuGetSourceName"
nuget sources Add -Name $NuGetSourceName -Source $NuGetSourceUrl -ConfigFile $NuGetConfigPath

# Verify NuGet Sources
Write-Host "Listing all registered system-wide NuGet sources:"
nuget sources List -ConfigFile $NuGetConfigPath
