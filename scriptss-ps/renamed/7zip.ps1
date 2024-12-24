# Define the 7-Zip tool details
$toolName = "7-Zip"
$toolVersion = "21.07"  # Replace with the desired version
$toolSource = "artifactory"  # Replace if required
$toolBaseUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local"
$toolFileName = "7z-$toolVersion.zip"

# Construct the download URL
$url = "$toolBaseUrl/7zip/windows/$toolFileName"

# Define the installation path and extracted directory
$installPath = "C:\Program Files\7-Zip"
$downloadPath = "$installPath\$toolFileName"

# Validate the source
if ($toolSource -ne "artifactory") {
    throw "Unable to install $toolName. The specified source, '$toolSource', is not supported."
}

# Create installation directory if it doesn't exist
if (-Not (Test-Path $installPath)) {
    New-Item -Path $installPath -ItemType Directory -Force
}

# Download the ZIP file
Write-Host "Downloading $toolName version $toolVersion from $url"
Invoke-WebRequest -Uri $url -OutFile $downloadPath

# Extract the ZIP file
Write-Host "Extracting $toolName to $installPath"
Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force

# Verify the extraction
if (-Not (Test-Path "$installPath\7z.exe")) {
    throw "$toolName installation failed. The required binary file is missing in the installation directory."
}

# Set environment variables for 7-Zip
Write-Host "Updating PATH environment variable for $toolName"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$installPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", [System.EnvironmentVariableTarget]::Machine)
}

# Verify 7-Zip installation
Write-Host "Verifying $toolName installation..."
try {
    $versionOutput = & "$installPath\7z.exe" --help
    Write-Host "$toolName installed successfully: $versionOutput"
} catch {
    throw "Failed to verify $toolName installation. Error: $_"
}
