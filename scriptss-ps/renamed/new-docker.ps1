# Define Docker tool from the manifest
$dockerTool = Get-ManifestTool -Name "Docker"

# Validate the tool's source
if ($null -eq $dockerTool) {
    throw "Failed to get the tool 'Docker' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

if ($dockerTool.source -ne "artifactory") {
    throw "Unable to install Docker. The specified source, '$($dockerTool.source)', is not supported."
}

# Retrieve version and construct URL
$dockerVersion = $dockerTool.defaultVersion
$dockerUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/docker/windows/$dockerVersion/docker-$dockerVersion.zip"

# Set installation paths and temporary file location
$dockerZipPath = "$env:TEMP\docker-$dockerVersion.zip"
$dockerExtractPath = "C:\Program Files\Docker"
$dockerBinPath = "$dockerExtractPath"

# Download Docker zip
Write-Host "Downloading Docker version $dockerVersion from $dockerUrl..."
try {
    Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerZipPath -UseBasicParsing
    Write-Host "Docker zip downloaded to $dockerZipPath"
} catch {
    Write-Error "Failed to download Docker ZIP from $dockerUrl. Error: $_"
    exit 1
}

# Extract Docker zip
Write-Host "Extracting Docker zip to $dockerExtractPath..."
try {
    if (-Not (Test-Path $dockerExtractPath)) {
        New-Item -Path $dockerExtractPath -ItemType Directory | Out-Null
    }
    Expand-Archive -Path $dockerZipPath -DestinationPath $dockerExtractPath -Force
    Write-Host "Docker extracted to $dockerExtractPath"
} catch {
    Write-Error "Failed to extract Docker ZIP. Error: $_"
    exit 1
}

# Verify the binary exists
if (-Not (Test-Path "$dockerBinPath\docker.exe")) {
    Write-Error "Docker executable not found in $dockerBinPath. Extraction may have failed."
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
