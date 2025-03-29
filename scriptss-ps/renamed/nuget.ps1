# ==========================
# Ensure TLS 1.2 is Enabled (Additive)
# ==========================
Write-Host "Ensuring TLS1.2 is enabled for current session..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# ==========================
# Configure JFrog Artifactory as Machine-Wide NuGet Source
# ==========================
$NuGetSourceName = "Artifactory"
$NuGetSourceUrl = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/v3/nuget/index.json"

# Correct machine-wide config location per Microsoft documentation
$NuGetConfigPath = "C:\Program Files (x86)\NuGet\Config\NuGet.config"

# Remove existing public NuGet feed if present
Write-Host "Checking for public NuGet feed..."
$publicFeed = dotnet nuget list source --configfile $NuGetConfigPath | Where-Object { $_ -match "nuget.org" }
if ($publicFeed) {
    Write-Host "Removing public NuGet feed..."
    dotnet nuget remove source "nuget.org" --configfile $NuGetConfigPath
}

# Add Artifactory as machine-wide source
Write-Host "Configuring Artifactory as machine-wide NuGet source..."
dotnet nuget add source $NuGetSourceUrl --name $NuGetSourceName --configfile $NuGetConfigPath

Write-Host "NuGet configuration completed successfully!"

_____ Tets file-----------------

BeforeAll {
    # Define expected NuGet configuration values
    $ExpectedSourceName = "Artifactory"
    $PublicFeedNames = @("nuget.org", "Microsoft Visual Studio Offline Packages")
}

Describe "NuGet Configuration Validation" {
    Context "Current User Configuration" {
        It "Should contain Artifactory in sources" {
            $sources = dotnet nuget list source
            $sources -match $ExpectedSourceName | Should -Not -BeNullOrEmpty
        }

        It "Should not list public NuGet sources" {
            $sources = dotnet nuget list source
            $publicSources = $sources -match ($PublicFeedNames -join '|')
            $publicSources | Should -BeNullOrEmpty
        }
    }
}


# #=---------------
# # ==========================
# # Ensure TLS 1.2 is Enabled
# # ==========================
# Write-Host "Ensuring TLS1.2 is configured for use..."
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# # ==========================
# # Configure JFrog Artifactory as a NuGet Source using .NET CLI for All Users and All Hosts
# # ==========================
# $NuGetSourceName = "Artifactory"
# $NuGetSourceUrl = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/v3/nuget/index.json"

# # Ensure the Config Directory Exists for All Users
# $NuGetConfigDir = "C:\ProgramData\NuGet\Config"
# $NuGetConfigPath = "$NuGetConfigDir\NuGet.Config"
# if (!(Test-Path $NuGetConfigDir)) {
#     Write-Host "Creating NuGet config directory at $NuGetConfigDir"
#     New-Item -ItemType Directory -Path $NuGetConfigDir -Force | Out-Null
# }

# # Ensure NuGet Config File Exists and Has a Valid Structure
# if (!(Test-Path $NuGetConfigPath) -or [string]::IsNullOrWhiteSpace((Get-Content $NuGetConfigPath -Raw))) {
#     Write-Host "NuGet config file not found or invalid. Creating a valid one."
#     @"
# <?xml version="1.0" encoding="utf-8"?>
# <configuration>
#     <packageSources>
#     </packageSources>
# </configuration>
# "@ | Set-Content -Path $NuGetConfigPath -Encoding UTF8 -Force
# }

# # Check if the NuGet source already exists
# $ExistingSource = dotnet nuget list source --configfile $NuGetConfigPath | Select-String -Pattern $NuGetSourceName

# if ($ExistingSource) {
#     Write-Host "Removing existing NuGet source: $NuGetSourceName"
#     dotnet nuget remove source $NuGetSourceName --configfile $NuGetConfigPath
# }

# # Add JFrog Artifactory as a NuGet Source for All Users
# Write-Host "Adding JFrog Artifactory NuGet Source: $NuGetSourceName for All Users"
# dotnet nuget add source $NuGetSourceUrl --name $NuGetSourceName --configfile $NuGetConfigPath --store-password-in-clear-text

# # Register the source for the current user and all hosts
# Write-Host "Registering NuGet source for the current user"
# dotnet nuget add source $NuGetSourceUrl --name $NuGetSourceName --store-password-in-clear-text

# # Verify NuGet Sources for All Users
# Write-Host "Listing all registered NuGet sources for All Users:"
# dotnet nuget list source --configfile $NuGetConfigPath

# # Verify NuGet Sources for Current User
# Write-Host "Listing all registered NuGet sources for Current User:"
# dotnet nuget list source

# Write-Host "NuGet configuration for All Users and All Hosts completed successfully!"

