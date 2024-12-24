# Fetch Ant tool details from the manifest
$antTool = Get-ManifestTool -Name "Ant"
$installArgs = $($antTool.installArgs, "/DIR=$($antTool.installPath)")

# Verify the tool's source is from Artifactory
if ($antTool.source -ne "artifactory") {
    throw "Unable to install Ant. The specified source, '$($antTool.source)', is not supported."
}

# Ensure the tool exists in the manifest
if ($null -eq $antTool) {
    throw "Failed to get the tool 'Ant' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Dynamically construct the Artifactory URL for the specific version of Ant
$antVersion = $antTool.defaultVersion
$url = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-build-agent-local/apache-ant/windows/apache-ant-$($antVersion).zip"

# Define the installation path and extracted directory
$antPath = "C:\apache-ant"
$antZipPath = "$antPath\apache-ant.zip"
$antExtractedPath = "$antPath\apache-ant-$($antVersion)"

# Create installation directory if it doesn't exist
if (-Not (Test-Path $antPath)) {
    New-Item -Path $antPath -ItemType Directory -Force
}

# Download the ZIP file
Write-Host "Downloading Apache Ant version $antVersion from $url"
Invoke-WebRequest -Uri $url -OutFile $antZipPath

# Extract the ZIP file
Write-Host "Extracting Apache Ant to $antExtractedPath"
Expand-Archive -Path $antZipPath -DestinationPath $antPath -Force

# Verify the extraction
if (-Not (Test-Path "$antExtractedPath\bin\ant.bat")) {
    throw "Ant installation failed. The required binary file is missing in the installation directory."
}

# Set environment variables for Ant
Write-Host "Setting ANT_HOME and updating PATH environment variable"
[Environment]::SetEnvironmentVariable('ANT_HOME', $antExtractedPath, [EnvironmentVariableTarget]::Machine)
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$antExtractedPath\bin*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$antExtractedPath\bin", [System.EnvironmentVariableTarget]::Machine)
}

# Verify Ant installation
Write-Host "Verifying Ant installation..."
try {
    $antVersionOutput = & "$antExtractedPath\bin\ant.bat" -version
    Write-Host "Apache Ant installed successfully: $antVersionOutput"
} catch {
    throw "Failed to verify Apache Ant installation. Error: $_"
}
