# ==========================
# Ensure TLS 1.2 is Enabled
# ==========================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# ==========================
# Configure JFrog Artifactory as a NuGet Source (Machine-Level)
# ==========================

# Define JFrog Artifactory Source Details
$NuGetSourceName = "Artifactory"
$NuGetSourceUrl = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/v3/nuget-remote/index.json"

# Remove Existing NuGet Source (if already exists)
if (nuget sources list | Select-String -Pattern $NuGetSourceName) {
    Write-Host "Removing existing NuGet source: $NuGetSourceName"
    nuget sources Remove -Name $NuGetSourceName
}

# Add NuGet Source (Machine-Level)
Write-Host "Adding NuGet Source: $NuGetSourceName"
nuget sources Add -Name $NuGetSourceName -Source $NuGetSourceUrl -ConfigFile "$env:APPDATA\NuGet\NuGet.Config"

# Verify NuGet Sources
Write-Host "Listing all registered NuGet sources:"
nuget sources List
