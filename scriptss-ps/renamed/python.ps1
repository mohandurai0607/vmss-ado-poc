# Define Python tool from the manifest
$pythonTool = Get-ManifestTool -Name "Python"

# Validate the tool's source
if ($null -eq $pythonTool) {
    throw "Failed to get the tool 'Python' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

if ($pythonTool.source -ne "artifactory") {
    throw "Unable to install Python. The specified source, '$($pythonTool.source)', is not supported."
}

# Retrieve version and construct URL
$pythonVersion = $pythonTool.defaultVersion
$pythonUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows/$pythonVersion/python-$pythonVersion.zip"

# Set up installation paths
$pythonPath = "C:\cicd-tools"
$subPath = "$pythonPath\$pythonVersion"
$pythonBasePath = "$subPath\python-$pythonVersion"

# Check if Python is already installed
if (Test-Path $pythonBasePath) {
    Write-Host "Python version $pythonVersion already installed at $pythonBasePath. No action will be taken."
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
    if (-Not (Test-Path $subPath)) {
        New-Item -ItemType Directory -Path $subPath | Out-Null
    }
    Expand-Archive -Path $zipFilePath -DestinationPath $pythonBasePath -Force
    Remove-Item $zipFilePath
    Write-Host "Python extracted to $pythonBasePath."
} catch {
    Write-Error "Failed to extract Python ZIP. Error: $_"
    exit 1
}

# Verify if python.exe exists
Write-Host "Checking if python.exe exists in the extracted directory..."
if (-Not (Test-Path "$pythonBasePath\python.exe")) {
    Write-Error "python.exe not found in $pythonBasePath. Please verify the extracted files."
    exit 1
}

# Set environment variables
Write-Host "Setting PATH and proxy environment variables..."
$cloudProxy = "http://cloudproxy.nfcu.net:8080"
[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)

$pythonBinPath = $pythonBasePath
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
    $pythonVersionOutput = & "$pythonBasePath\python.exe" -V
    Write-Host "Python installed successfully. Version: $pythonVersionOutput"
} catch {
    Write-Error "Python installation failed. Please check the environment variables and paths."
    exit 1
}


#-------------test

# Define Python tool and version
$pythonTool = "Python"
$pythonVersion = "3.12.8"  # Specify the desired version
$pythonUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows/$pythonVersion/python-$pythonVersion.zip"

# Set up installation paths
$pythonPath = "C:\cicd-tools\python"
$subPath = "$pythonPath\$pythonVersion"
$pythonBasePath = "$subPath\python-$pythonVersion"


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
    if (-Not (Test-Path $subPath)) {
        New-Item -ItemType Directory -Path $subPath | Out-Null
    }
    Expand-Archive -Path $zipFilePath -DestinationPath $subPath -Force
    Remove-Item $zipFilePath
    Write-Host "Python extracted to $pythonBasePath."
} catch {
    Write-Error "Failed to extract Python ZIP. Error: $_"
    exit 1
}

# Set environment variables
Write-Host "Setting PATH and proxy environment variables..."
$cloudProxy = "http://cloudproxy.nfcu.net:8080"
[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $cloudProxy, [System.EnvironmentVariableTarget]::Machine)

# Adjust bin path (assume the executable is directly in $pythonBasePath)
$pythonBinPath = $pythonBasePath
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
    $pythonVersionOutput = & "$pythonBasePath\python.exe" -V
    Write-Host "Python installed successfully. Version: $pythonVersionOutput"
} catch {
    Write-Error "Python installation failed. Please check the environment variables and paths."
    exit 1
}
