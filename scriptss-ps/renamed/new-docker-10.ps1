# Define Docker download details
$dockerVersion = "27.4.1"  # Replace with the desired version
$dockerUrl = "https://download.docker.com/win/static/stable/x86_64/docker-$dockerVersion.zip"

# Define installation paths
$customPath = "C:\Tools\Docker"
$dockerZipPath = "$env:TEMP\docker-$dockerVersion.zip"
$dockerExtractPath = "$customPath\$dockerVersion"

# Download Docker ZIP file
Write-Host "Downloading Docker version $dockerVersion from $dockerUrl..."
try {
    Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerZipPath -UseBasicParsing
    Write-Host "Docker ZIP downloaded to $dockerZipPath."
} catch {
    throw "Failed to download Docker ZIP from $dockerUrl. Error: $_"
}

# Extract the ZIP file
Write-Host "Extracting Docker ZIP to $dockerExtractPath..."
try {
    if (-Not (Test-Path $customPath)) {
        New-Item -ItemType Directory -Path $customPath | Out-Null
    }
    Expand-Archive -Path $dockerZipPath -DestinationPath $dockerExtractPath -Force
    Remove-Item $dockerZipPath
    Write-Host "Docker extracted to $dockerExtractPath."
} catch {
    throw "Failed to extract Docker ZIP. Error: $_"
}

# Verify Docker binaries
$dockerPath = "$dockerExtractPath\docker\docker.exe"
$dockerdPath = "$dockerExtractPath\docker\dockerd.exe"

if (-not (Test-Path $dockerPath)) {
    throw "docker.exe not found at $dockerPath. Please check the download and extraction steps."
}
if (-not (Test-Path $dockerdPath)) {
    throw "dockerd.exe not found at $dockerdPath. Please check the download and extraction steps."
}

Write-Host "Docker binaries downloaded and extracted successfully to $dockerExtractPath."

# Install Docker CE
Write-Host "Installing Docker CE..."
$instScriptUrl = "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1"
$instScriptPath = "$customPath\install-docker-ce.ps1"

# Download the installation script
try {
    Invoke-WebRequest -Uri $instScriptUrl -OutFile $instScriptPath -UseBasicParsing
    Write-Host "Docker installation script downloaded to $instScriptPath."
} catch {
    throw "Failed to download Docker installation script from $instScriptUrl. Error: $_"
}

# Verify the installation script exists
if (-not (Test-Path $instScriptPath)) {
    throw "Docker installation script not found at $instScriptPath."
}

# Run the installation script with debugging
Write-Host "Running Docker installation script with paths:"
Write-Host "  DockerPath: $dockerPath"
Write-Host "  DockerDPath: $dockerdPath"

try {
    & $instScriptPath -DockerPath $dockerPath -DockerDPath $dockerdPath
    if ($LASTEXITCODE -ne 0) {
        throw "Docker installation failed with exit code $LASTEXITCODE."
    }
    Write-Host "Docker installation completed successfully."
} catch {
    throw "Failed to run Docker installation script. Error: $_"
}

# Update environment variables
Write-Host "Updating PATH environment variable to include Docker binaries..."
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$dockerExtractPath\docker*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$dockerExtractPath\docker", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "PATH updated to include: $dockerExtractPath."
} else {
    Write-Host "PATH already includes: $dockerExtractPath."
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify Docker installation
Write-Host "Verifying Docker installation..."
try {
    $dockerVersionOutput = & "$dockerPath" --version
    $dockerdVersionOutput = & "$dockerdPath" --version
    Write-Host "Docker installed successfully. Version: $dockerVersionOutput"
    Write-Host "Docker daemon installed successfully. Version: $dockerdVersionOutput"
} catch {
    throw "Docker installation failed. Please check the environment variables and paths."
}


& "C:\Tools\Docker\install-docker-ce.ps1" -DockerPath "C:\Tools\Docker\27.4.1\docker\docker.exe" -DockerDPath "C:\Tools\Docker\27.4.1\docker\dockerd.exe"
