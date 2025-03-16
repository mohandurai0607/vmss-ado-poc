# ==========================
# Configure PowerShell for All Users & Hosts (One-Time Setup)
# ==========================

# Ensure the script is running as Administrator
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "This script must be run as Administrator. Restarting with elevated privileges..."
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting PowerShell environment configuration for all users..."

# ==========================
# Ensure TLS 1.2 is Enabled
# ==========================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# ==========================
# Register Artifactory NuGet Repository for All Users
# ==========================

# Define repository parameters
$parameters = @{
    Name               = "Artifactory"
    SourceLocation     = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"
    PublishLocation    = "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"
    InstallationPolicy = "Trusted"
    Verbose            = $True
}

# Ensure the minimum required NuGet package provider is installed
Write-Host "Ensuring minimum NuGet package provider is installed..."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Register the repository if not already registered
if (!(Get-PSRepository -Name $parameters.Name -ErrorAction SilentlyContinue)) {
    Write-Host "Registering PowerShell Repository $($parameters.Name) ($($parameters.SourceLocation))..."
    Register-PSRepository @parameters 
} else {
    Write-Host "Repository '$($parameters.Name)' is already registered."
}

# ==========================
# Optimize PowerShell Startup Performance (All Users)
# ==========================

Write-Host "Configuring PSModuleAnalysisCachePath for faster module analysis..."

# Define the PSModuleAnalysisCachePath
$PSModuleAnalysisCachePath = "C:\PSModuleAnalysisCachePath\ModuleAnalysisCache"

# Set the environment variable permanently for all users
[System.Environment]::SetEnvironmentVariable("PSModuleAnalysisCachePath", $PSModuleAnalysisCachePath, "Machine")

# Make the variable available in the current session
$env:PSModuleAnalysisCachePath = $PSModuleAnalysisCachePath

# Ensure the directory exists
if (!(Test-Path -Path $PSModuleAnalysisCachePath)) {
    New-Item -Path $PSModuleAnalysisCachePath -ItemType Directory -Force | Out-Null
}

Write-Host "PowerShell configuration for all users completed successfully."

# Append the repository configuration to the global profile
Set-Content -Path $globalProfile -Value $repoConfig

# Load the profile immediately
. $globalProfile

### --------------------

Describe "PowerShell Repository Configuration" {

    Context "Artifactory Repository Registration" {
        It "Artifactory repository should be registered" {
            $repo = Get-PSRepository -Name "Artifactory" -ErrorAction SilentlyContinue
            $repo | Should -Not -BeNullOrEmpty
        }

        It "Artifactory repository should have correct source URL" {
            $repo = Get-PSRepository -Name "Artifactory" -ErrorAction SilentlyContinue
            $repo.SourceLocation | Should -Be "https://prod.artifactory.nfcu.net/artifactory/api/nuget/cicd-md-local"
        }
    }

    Context "Package Installation Test" {
        It "Should install a test package from the Artifactory repository" {
            Install-Module -Name "Pester" -Repository "Artifactory" -Force -AllowClobber -ErrorAction Stop
            $module = Get-Module -ListAvailable -Name "Pester"
            $module | Should -Not -BeNullOrEmpty
        }
    }

}

# Run Pester test
Invoke-Pester C:\image\tests\Congure-PowershellProfile.Tests.ps1
