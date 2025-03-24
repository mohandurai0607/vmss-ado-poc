# ==========================
# Ensure the script is running as Administrator
# ==========================
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "This script must be run as Administrator. Restarting with elevated privileges..."
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting PowerShell repository configuration for all users and hosts..."

# ==========================
# Ensure TLS 1.2 is Enabled
# ==========================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# ==========================
# Unregister Default PowerShell Gallery
# ==========================
$DefaultGallery = "PSGallery"

if (Get-PSRepository -Name $DefaultGallery -ErrorAction SilentlyContinue) {
    Write-Host "Unregistering default PowerShell gallery '$DefaultGallery'..."
    Unregister-PSRepository -Name $DefaultGallery
    Write-Host "Default PowerShell gallery '$DefaultGallery' has been unregistered."
} else {
    Write-Host "Default PowerShell gallery '$DefaultGallery' is not registered."
}

# ==========================
# Register Artifactory NuGet Repository for All Users
# ==========================
$RepoName = "Artifactory"
$RepoSource = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"
$RepoPublish = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"

# Ensure NuGet package provider is installed
Write-Host "Ensuring NuGet package provider is installed..."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers

# Register the new repository
Write-Host "Registering PowerShell Repository '$RepoName'..."
Register-PSRepository -Name $RepoName -SourceLocation $RepoSource -PublishLocation $RepoPublish -InstallationPolicy Trusted

# ==========================
# Persist Configuration in Global Profile (All Users & Hosts)
# ==========================
$GlobalProfilePath = "$PSHOME\Profile.ps1"

# Ensure the profile script exists
if (!(Test-Path -Path $GlobalProfilePath)) {
    New-Item -ItemType File -Path $GlobalProfilePath -Force | Out-Null
}

# Define the repository configuration script content
$RepoConfig = @"
# ==========================
# PowerShell Repository Configuration for All Users
# ==========================
Write-Host "Ensuring TLS1.2 is enabled..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Define repository parameters
`$RepoName = "$RepoName"
`$RepoSource = "$RepoSource"
`$RepoPublish = "$RepoPublish"

# Ensure NuGet package provider is installed
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers

# Unregister Default PowerShell Gallery if exists
if (Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue) {
    Write-Host "Unregistering default PowerShell gallery 'PSGallery'..."
    Unregister-PSRepository -Name "PSGallery"
    Write-Host "Default PowerShell gallery 'PSGallery' has been unregistered."
}

# Register the repository if not already registered
if (!(Get-PSRepository -Name `$RepoName -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Name `$RepoName -SourceLocation `$RepoSource -PublishLocation `$RepoPublish -InstallationPolicy Trusted
} else {
    Write-Host "Repository '`$RepoName' is already registered."
}
"@

# Append to Global Profile
Add-Content -Path $GlobalProfilePath -Value $RepoConfig -Force

Write-Host "PowerShell repository configuration added to $GlobalProfilePath"
Write-Host "PowerShell repository setup completed successfully."


# # ==========================
# # Ensure the script is running as Administrator
# # ==========================
# $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
# $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
# $IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# if (-not $IsAdmin) {
#     Write-Host "This script must be run as Administrator. Restarting with elevated privileges..."
#     Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
#     exit
# }

# Write-Host "Starting PowerShell repository registration for all users and hosts..."

# # ==========================
# # Ensure TLS 1.2 is Enabled
# # ==========================
# Write-Host "Ensuring TLS1.2 is configured for use..."
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# # ==========================
# # Register Artifactory NuGet Repository for All Users
# # ==========================
# $RepoName = "Artifactory"
# $RepoSource = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"
# $RepoPublish = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"

# # Ensure NuGet package provider is installed
# Write-Host "Ensuring NuGet package provider is installed..."
# Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers

# Write-Host "Registering PowerShell Repository '$RepoName'..."
# Register-PSRepository -Name $RepoName -SourceLocation $RepoSource -PublishLocation $RepoPublish -InstallationPolicy Trusted

# # ==========================
# # Persist Configuration in Global Profile (All Users & Hosts)
# # ==========================
# $GlobalProfilePath = "$PSHOME\Profile.ps1"

# # Ensure the profile script exists
# if (!(Test-Path -Path $GlobalProfilePath)) {
#     New-Item -ItemType File -Path $GlobalProfilePath -Force | Out-Null
# }

# # Define the repository configuration script content
# $RepoConfig = @"
# # ==========================
# # PowerShell Repository Configuration for All Users
# # ==========================
# Write-Host "Ensuring TLS1.2 is enabled..."
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# # Define repository parameters
# `$RepoName = "$RepoName"
# `$RepoSource = "$RepoSource"
# `$RepoPublish = "$RepoPublish"

# # Ensure NuGet package provider is installed
# Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers

# # Register the repository if not already registered
# if (!(Get-PSRepository -Name `$RepoName -ErrorAction SilentlyContinue)) {
#     Register-PSRepository -Name `$RepoName -SourceLocation `$RepoSource -PublishLocation `$RepoPublish -InstallationPolicy Trusted
# } else {
#     Write-Host "Repository '`$RepoName' is already registered."
# }
# "@

# # Append to Global Profile
# Add-Content -Path $GlobalProfilePath -Value $RepoConfig -Force

# Write-Host "PowerShell repository configuration added to $GlobalProfilePath"
