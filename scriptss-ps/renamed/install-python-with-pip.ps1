# Define Python tool from the manifest
$pythonTool = Get-ManifestTool -Name "Python"

# Validate the tool's source
if ($null -eq $pythonTool) {
    throw "Failed to get the tool 'Python' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

if ($pythonTool.source -ne "artifactory") {
    throw "Unable to install Python. The specified source, '$($pythonTool.source)', is not supported."
}

# Retrieve version and construct URLs
$pythonVersion = $pythonTool.defaultVersion
$pythonUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows/$pythonVersion/python-$pythonVersion.zip"

# Internal Artifactory URL for get-pip.py
$getPipUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows/get-pip.py"
$getPipFilePath = "$env:TEMP\get-pip.py"

# Set up installation paths
$pythonPath = "C:\cicd-tools"
$subPath = "$pythonPath\$pythonVersion"
$pythonBasePath = "$subPath\python-$pythonVersion"

# Check if Python is already installed
if (Test-Path $pythonBasePath) {
    Write-Host "Python version $pythonVersion already installed at $pythonBasePath. No action will be taken."
} else {
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
}

# Verify if python.exe exists
Write-Host "Checking if python.exe exists in the extracted directory..."
if (-Not (Test-Path "$pythonBasePath\python.exe")) {
    Write-Error "python.exe not found in $pythonBasePath. Please verify the extracted files."
    exit 1
}

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

# =======================
# Install pip if missing
# =======================
Write-Host "Checking if pip is installed..."
$checkPip = & "$pythonBasePath\python.exe" -m pip --version 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "pip is not installed. Attempting to install pip..."

    # Try using ensurepip
    Write-Host "Running ensurepip..."
    try {
        & "$pythonBasePath\python.exe" -m ensurepip --default-pip
        Write-Host "ensurepip executed successfully."
    } catch {
        Write-Host "ensurepip failed, attempting manual installation..."
    }

    # Verify if pip is now installed
    $checkPip = & "$pythonBasePath\python.exe" -m pip --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        # If pip is still missing, manually install it from internal JFrog Artifactory
        Write-Host "Downloading get-pip.py from Artifactory..."
        try {
            Invoke-WebRequest -Uri $getPipUrl -OutFile $getPipFilePath -UseBasicParsing
            Write-Host "get-pip.py downloaded successfully."

            # Install pip using get-pip.py
            Write-Host "Installing pip..."
            & "$pythonBasePath\python.exe" "$getPipFilePath"

            Write-Host "pip installed successfully."
        } catch {
            Write-Error "Failed to download or install pip manually. Error: $_"
            exit 1
        }
    }
} else {
    Write-Host "pip is already installed."
}

# Upgrade pip to the latest version
Write-Host "Upgrading pip to the latest version..."
& "$pythonBasePath\python.exe" -m pip install --upgrade pip

# ============================
# Add Python Scripts to PATH
# ============================
$pipScriptsPath = "$pythonBasePath\Scripts"

if ($currentPath -notlike "*$pipScriptsPath*") {
    Write-Host "Adding Python Scripts directory to system PATH..."
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$pipScriptsPath", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "Python Scripts directory is already in the system PATH."
}

# Refresh the PATH in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)



Write-Host "Python and pip installation completed successfully."


------------ test --

# ============================
# Pester Tests for Python & pip
# ============================
Describe "Python and pip Installation Validation" {

    Context "Python version check" {
        It "Python should return a valid version output" {
            $pythonVersionOutput = & "$pythonBasePath\python.exe" -V
            $pythonVersionOutput | Should -Match "^Python \d+\.\d+\.\d+"
        }
    }

    Context "pip executable validation" {
        It "pip should be accessible and return a valid version output" {
            $pipVersionOutput = & "$pythonBasePath\python.exe" -m pip --version
            $pipVersionOutput | Should -Match "^pip \d+\.\d+\.\d+"
        }
    }
}
