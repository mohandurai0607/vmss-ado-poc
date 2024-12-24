# Fetch 7-Zip tool details from the manifest
$zipTool = Get-ManifestTool -Name "7-Zip"
$installArgs = $($zipTool.installArgs, "/DIR=$($zipTool.installPath)")

# Verify the tool's source is from Artifactory
if ($zipTool.source -ne "artifactory") {
    throw "Unable to install 7-Zip. The specified source, '$($zipTool.source)', is not supported."
}

# Ensure the tool exists in the manifest
if ($null -eq $zipTool) {
    throw "Failed to get the tool '7-Zip' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Dynamically construct the Artifactory URL for the specific version of 7-Zip
$zipVersion = $zipTool.defaultVersion
$url = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-build-agent-local/7-zip/windows/7-zip-$($zipVersion).exe"

# Define the installation path and installation file path
$installPath = "C:\Program Files\7-Zip"
$zipInstallPath = "$installPath\7-zip-$($zipVersion).exe"

# Create installation directory if it doesn't exist
if (-Not (Test-Path $installPath)) {
    Write-Host "Creating installation directory: $installPath"
    New-Item -Path $installPath -ItemType Directory -Force
}

# Download the 7-Zip installer using Invoke-WebRequest
Write-Host "Downloading 7-Zip version $zipVersion from $url"
Invoke-WebRequest -Uri $url -OutFile $zipInstallPath -ErrorAction Stop

# Install 7-Zip using silent install
Write-Host "Installing 7-Zip version $zipVersion"
Start-Process -FilePath $zipInstallPath -ArgumentList "/S" -Wait

# Validate the installation directory
if (-Not (Test-Path "$installPath\7z.exe")) {
    throw "7-Zip installation failed. The required binary file is missing in the installation directory."
}

# Update the PATH environment variable for 7-Zip
Write-Host "Updating PATH environment variable for 7-Zip"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$installPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", [System.EnvironmentVariableTarget]::Machine)
}

# Verify 7-Zip installation
Write-Host "Verifying 7-Zip installation..."
try {
    $zipVersionOutput = & "$installPath\7z.exe" --help
    Write-Host "7-Zip installed successfully: $zipVersionOutput"
} catch {
    throw "Failed to verify 7-Zip installation. Error: $_"
}

# Optional cleanup of the installer (if needed)
Remove-Item -Path $zipInstallPath -Force
