# Define the global profile path at $PSHOME\Profile.ps1
$globalProfile = "$PSHOME\Profile.ps1"

# Ensure the profile script exists
if (!(Test-Path -Path $globalProfile)) {
    New-Item -ItemType File -Path $globalProfile -Force
}

# Artifactory Repository Registration Configuration
$repoConfig = @"
# Register Artifactory NuGet Repository for All Users and Hosts

# Define repository parameters
\$parameters = @{

    Name               = "Artifactory"
    SourceLocation     = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"
    PublishLocation    = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"
    InstallationPolicy = "Trusted"
    Verbose            = \$True
}

# Ensure TLS 1.2 is enabled
Write-Host "Ensuring TLS1.2 is configured for use"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Ensure the minimum required NuGet package provider is installed
Write-Host "Ensuring minimum NuGet package provider is installed"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Register the repository if not already registered
if (!(Get-PSRepository -Name \$parameters.Name -ErrorAction SilentlyContinue)) {
    Write-Host "Registering PowerShell Repository \$parameters.Name (\$parameters.SourceLocation)"
    Register-PSRepository @parameters 
} else {
    Write-Host "Repository '\$parameters.Name' is already registered."
}

# Optimize PowerShell startup performance
Write-Host 'Configuring PSModuleAnalysisCachePath for faster module analysis'
\$env:PSModuleAnalysisCachePath = 'C:\PSModuleAnalysisCachePath\ModuleAnalysisCache'
[Environment]::SetEnvironmentVariable('PSModuleAnalysisCachePath', \$env:PSModuleAnalysisCachePath, "Machine")
New-Item -Path \$env:PSModuleAnalysisCachePath -ItemType 'File' -Force | Out-Null

# Display the registered repositories
Get-PSRepository
"@

# Append the repository configuration to the global profile
Set-Content -Path $globalProfile -Value $repoConfig

# Load the profile immediately
. $globalProfile

# Verify repository registration
Get-PSRepository
