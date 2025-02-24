$SqlServerModuleVersion = "21.1.18235"

# Check if NuGet provider is installed; if not, install it
$nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not $nuget) {
    Write-Host "NuGet provider is not installed. Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force -Confirm:$false
} else {
    Write-Host "NuGet provider is already installed."
}

# Uninstall all installed versions of the SqlServer module if present
$installedModules = Get-Module -ListAvailable -Name SqlServer
if ($installedModules) {
    Write-Host "Uninstalling existing SqlServer module versions..."
    foreach ($mod in $installedModules) {
        Uninstall-Module -Name SqlServer -AllVersions -Force -Confirm:$false
    }
}

# Install the specific version of the SqlServer module without prompting
Write-Host "Installing SqlServer module version $SqlServerModuleVersion..."
Install-Module -Name SqlServer -RequiredVersion $SqlServerModuleVersion -AllowClobber -Force -Confirm:$false

# Import the module
Import-Module SqlServer -Force

# Verify installation
if (Get-Module -ListAvailable -Name SqlServer | Where-Object { $_.Version -eq $SqlServerModuleVersion }) {
    Write-Host "SqlServer module version $SqlServerModuleVersion installed successfully."
} else {
    Write-Host "Failed to install the SqlServer module. Please check for errors."
}

# Test Invoke-Sqlcmd availability
if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
    Write-Host "`nInvoke-Sqlcmd is now available for use."
} else {
    Write-Host "`nInvoke-Sqlcmd is still not recognized. Try restarting PowerShell and re-running the script."
}
