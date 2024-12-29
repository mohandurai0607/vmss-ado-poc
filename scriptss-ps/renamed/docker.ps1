# Docker Desktop Installation Script for Windows

# Define Docker Desktop details
$dockerToolName = "DockerDesktop"
$dockerVersion = "4.24.0"  # Replace with the desired Docker Desktop version
$dockerUrl = "https://desktop.docker.com/win/stable/$dockerVersion/Docker%20Desktop%20Installer.exe"

# Set installation paths and temporary file location
$dockerInstallerPath = "$env:TEMP\DockerDesktopInstaller.exe"
$dockerBinPath = "C:\Program Files\Docker\Docker\resources\bin"

# Check if Docker Desktop is already installed
Write-Host "Checking if Docker Desktop is already installed..."
$dockerCheckCommand = "docker --version"
$dockerInstalled = $false

try {
    Invoke-Expression $dockerCheckCommand | Out-Null
    $dockerInstalled = $true
    Write-Host "Docker Desktop is already installed. Version:"
    Invoke-Expression $dockerCheckCommand
} catch {
    Write-Host "Docker Desktop is not installed. Proceeding with installation."
}

if ($dockerInstalled) {
    return
}

# Download Docker Desktop installer
Write-Host "Downloading Docker Desktop version $dockerVersion from $dockerUrl..."
Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerInstallerPath -UseBasicParsing
Write-Host "Docker Desktop installer downloaded to $dockerInstallerPath"

# Install Docker Desktop
Write-Host "Starting Docker Desktop installation..."
Start-Process -FilePath $dockerInstallerPath -ArgumentList "/quiet" -Wait

# Verify installation
Write-Host "Verifying Docker Desktop installation..."
try {
    Invoke-Expression $dockerCheckCommand | Out-Null
    Write-Host "Docker Desktop installed successfully. Version:"
    Invoke-Expression $dockerCheckCommand
} catch {
    Write-Error "Docker Desktop installation failed. Please check the logs or re-run the script."
    exit 1
}

# Set environment variables
Write-Host "Updating PATH environment variable to include Docker binary directory..."
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$dockerBinPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$dockerBinPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "PATH updated to include: $dockerBinPath"
} else {
    Write-Host "PATH already includes: $dockerBinPath"
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Clean up installer
Write-Host "Cleaning up installer file..."
Remove-Item -Path $dockerInstallerPath -Force
Write-Host "Installation completed successfully!"
