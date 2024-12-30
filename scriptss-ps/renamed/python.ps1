# Define Python tool from the manifest
$pythonTool = Get-ManifestTool -Name "Python"

# Verify the tool's source is from Artifactory
if ($pythonTool.source -ne "artifactory") {
    throw "Unable to install Python. The specified source, '$($pythonTool.source)', is not supported."
}

# Ensure the tool exists in the manifest
if ($null -eq $pythonTool) {
    throw "Failed to get the tool 'Python' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Dynamically construct the Artifactory URL for the specific version of Python
$pythonVersion = # version
$pythonUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows/$pythonVersion/python-$pythonVersion.zip"

# Set up installation paths
$pythonPath = "C:\cicd-tools\python"
$subPath = "$pythonPath\$pythonVersion"

# Check if Python is already installed
if (Test-Path $subPath) {
    Write-Host "Python version $pythonVersion already installed at $subPath. No action will be taken."
    return
}

# Download the Python ZIP file
$zipFilePath = "$env:TEMP\python-$pythonVersion.zip"
Write-Host "Downloading Python version $pythonVersion from $pythonUrl..."
try {
    Invoke-WebRequest -Uri $pythonUrl -OutFile $zipFilePath -UseBasicParsing
    Write-Host "Python ZIP downloaded to $zipFilePath."
} catch {
    Write-Error "Failed to download Python ZIP from $pythonUrl. Error: $_"
    exit 1
}

# Extract the ZIP file
Write-Host "Extracting Python ZIP to $subPath..."
try {
    if (-Not (Test-Path $pythonPath)) {
        New-Item -ItemType Directory -Path $pythonPath | Out-Null
    }
    Expand-Archive -Path $zipFilePath -DestinationPath $subPath -Force
    Remove-Item $zipFilePath
    Write-Host "Python extracted to $subPath."
} catch {
    Write-Error "Failed to extract Python ZIP. Error: $_"
    exit 1
}

# Set environment variables
Write-Host "Setting PATH and proxy environment variables..."
$cloudProxy = "http://cloudproxy.nfcu.net:8080"
[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)

$pythonBinPath = Join-Path $subPath "Scripts"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$pythonBinPath*") {
    Write-Host "Adding Python bin to system PATH..."
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$pythonBinPath", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "Python bin is already in the system PATH."
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify Python installation
Write-Host "Verifying Python installation..."
try {
    $pythonVersionOutput = & "$pythonBinPath\python.exe" -V
    Write-Host "Python installed successfully. Version: $pythonVersionOutput"
} catch {
    Write-Error "Python installation failed. Please check the environment variables and paths."
    exit 1
}

#-------------test
# Define Python tool from the manifest
$pythonTool = "Python"
# Dynamically construct the Artifactory URL for the specific version of Python
$pythonVersion = # version
$pythonUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows/$pythonVersion/python-$pythonVersion.zip"

# Set up installation paths
$pythonPath = "C:\cicd-tools\python"
$subPath = "$pythonPath\$pythonVersion"

# Check if Python is already installed
if (Test-Path $subPath) {
    Write-Host "Python version $pythonVersion already installed at $subPath. No action will be taken."
    return
}

# Download the Python ZIP file
$zipFilePath = "$env:TEMP\python-$pythonVersion.zip"
Write-Host "Downloading Python version $pythonVersion from $pythonUrl..."
try {
    Invoke-WebRequest -Uri $pythonUrl -OutFile $zipFilePath -UseBasicParsing
    Write-Host "Python ZIP downloaded to $zipFilePath."
} catch {
    Write-Error "Failed to download Python ZIP from $pythonUrl. Error: $_"
    exit 1
}

# Extract the ZIP file
Write-Host "Extracting Python ZIP to $subPath..."
try {
    if (-Not (Test-Path $pythonPath)) {
        New-Item -ItemType Directory -Path $pythonPath | Out-Null
    }
    Expand-Archive -Path $zipFilePath -DestinationPath $subPath -Force
    Remove-Item $zipFilePath
    Write-Host "Python extracted to $subPath."
} catch {
    Write-Error "Failed to extract Python ZIP. Error: $_"
    exit 1
}

# Set environment variables
Write-Host "Setting PATH and proxy environment variables..."
$cloudProxy = "http://cloudproxy.nfcu.net:8080"
[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)

$pythonBinPath = Join-Path $subPath "Scripts"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$pythonBinPath*") {
    Write-Host "Adding Python bin to system PATH..."
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$pythonBinPath", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "Python bin is already in the system PATH."
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify Python installation
Write-Host "Verifying Python installation..."
try {
    $pythonVersionOutput = & "$pythonBinPath\python.exe" -V
    Write-Host "Python installed successfully. Version: $pythonVersionOutput"
} catch {
    Write-Error "Python installation failed. Please check the environment variables and paths."
    exit 1
}


