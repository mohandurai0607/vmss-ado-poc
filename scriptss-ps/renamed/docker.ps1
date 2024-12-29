# Docker Desktop Installation Script for Windows (Zip-based)

# Define Docker Desktop details
$dockerVersion = "24.0.5"  # Replace with the desired Docker version
$dockerZipUrl = "https://download.docker.com/win/static/stable/x86_64/docker-$dockerVersion.zip"

# Set installation paths and temporary file location
#$dockerZipPath = "$env:TEMP\docker-$dockerVersion.zip"
$dockerZipPath = "C:\Software"
$dockerExtractPath = "C:\Program Files\Docker"
$dockerBinPath = "$dockerExtractPath\docker"

# Check if Docker is already installed
Write-Host "Checking if Docker is already installed..."
$dockerCheckCommand = "$dockerBinPath\docker --version"
$dockerInstalled = $false

try {
    Invoke-Expression $dockerCheckCommand | Out-Null
    $dockerInstalled = $true
    Write-Host "Docker is already installed. Version:"
    Invoke-Expression $dockerCheckCommand
} catch {
    Write-Host "Docker is not installed. Proceeding with installation."
}

if ($dockerInstalled) {
    return
}

# Download Docker zip
Write-Host "Downloading Docker version $dockerVersion from $dockerZipUrl..."
Invoke-WebRequest -Uri $dockerZipUrl -OutFile $dockerZipPath -UseBasicParsing
Write-Host "Docker zip downloaded to $dockerZipPath"

# Extract Docker zip
Write-Host "Extracting Docker zip to $dockerExtractPath..."
if (-Not (Test-Path $dockerExtractPath)) {
    New-Item -Path $dockerExtractPath -ItemType Directory | Out-Null
}
Expand-Archive -Path $dockerZipPath -DestinationPath $dockerExtractPath -Force
Write-Host "Docker extracted to $dockerExtractPath"

# Verify installation
Write-Host "Verifying Docker installation..."
try {
    Invoke-Expression $dockerCheckCommand | Out-Null
    Write-Host "Docker installed successfully. Version:"
    Invoke-Expression $dockerCheckCommand
} catch {
    Write-Error "Docker installation failed. Please check the logs or re-run the script."
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
Write-Host "Cleaning up zip file..."
Remove-Item -Path $dockerZipPath -Force
Write-Host "Installation completed successfully!"
