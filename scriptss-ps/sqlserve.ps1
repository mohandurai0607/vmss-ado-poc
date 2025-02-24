
$SqlServerModuleVersion = "21.1.18235"

# Check if the module is already installed
$module = Get-Module -ListAvailable -Name SqlServer

if ($module -and ($module.Version -eq $SqlServerModuleVersion)) {
    Write-Host "SqlServer module version $SqlServerModuleVersion is already installed."
} else {
    # Ensure NuGet provider is available
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host "Installing NuGet provider..."
        Install-PackageProvider -Name NuGet -Force
    }

    # Install the specific version of the SqlServer module
    Write-Host "Installing SqlServer module version $SqlServerModuleVersion..."
    Install-Module -Name SqlServer -RequiredVersion $SqlServerModuleVersion -AllowClobber -Force

    # Import the module
    Import-Module SqlServer

    # Verify installation
    if (Get-Module -ListAvailable -Name SqlServer) {
        Write-Host "SqlServer module version $SqlServerModuleVersion installed successfully."
    } else {
        Write-Host "Failed to install the SqlServer module. Please check for errors."
    }
}

# Test Invoke-Sqlcmd availability
if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
    Write-Host "`nInvoke-Sqlcmd is now available for use."
} else {
    Write-Host "`nInvoke-Sqlcmd is still not recognized. Try restarting PowerShell and re-running the script."
}
