# ============================
# Define Python & pip Variables
# ============================

$pythonTool = Get-ManifestTool -Name "Python"

# Validate Python Tool
if ($null -eq $pythonTool) {
    throw "Failed to get the tool 'Python' from the manifest file. Verify the tool exists in the manifest."
}

if ($pythonTool.source -ne "artifactory") {
    throw "Unable to install Python. The specified source, '$($pythonTool.source)', is not supported."
}
# Set Python version
$pythonVersion = $pythonTool.defaultVersion

# Define JFrog Artifactory URLs
$jfrogBaseUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows"
$pythonZipUrl = "$jfrogBaseUrl/$pythonVersion/python-$pythonVersion.zip"
$getPipUrl = "$jfrogBaseUrl/get-pip.py"

# Define custom installation directory
$installDir = "C:\cicd-tools\$pythonVersion\python-$pythonVersion"

# Create the installation directory if it doesn't exist
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

Write-Host "Downloading Python $pythonVersion zip from JFrog..."
# Download the Python ZIP from JFrog
$zipFile = "$env:TEMP\python.zip"
Invoke-WebRequest -Uri $pythonZipUrl -OutFile $zipFile

Write-Host "Extracting Python to $installDir..."
# Extract the ZIP archive (using .NET's ZipFile class)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installDir)

# Clean up the downloaded ZIP file
Remove-Item $zipFile

# Modify the _pth file to enable site packages (required for pip)
$pthFile = Get-ChildItem -Path $installDir -Filter "*._pth" | Select-Object -First 1
if ($pthFile) {
    Write-Host "Enabling site packages in $($pthFile.Name)..."
    (Get-Content $pthFile.FullName) |
        ForEach-Object { if ($_ -match "^#import site") { "import site" } else { $_ } } |
        Set-Content $pthFile.FullName
}

# Download get-pip.py from JFrog
Write-Host "Downloading get-pip.py from JFrog..."
$pipScript = "$env:TEMP\get-pip.py"
Invoke-WebRequest -Uri $getPipUrl -OutFile $pipScript

# Use the installed Python to run get-pip.py and install pip
Write-Host "Installing pip..."
& "$installDir\python.exe" $pipScript

# Remove the get-pip.py script after installation
Remove-Item $pipScript

# Define paths to add (both Python directory and its Scripts subfolder)
$pythonScriptsPath = "$installDir\Scripts"
$pathsToAdd = @($installDir, $pythonScriptsPath)

# Update the current user's PATH environment variable
$oldUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
foreach ($path in $pathsToAdd) {
    if ($oldUserPath -notlike "*$path*") {
        Write-Host "Adding $path to the User PATH..."
        $oldUserPath += ";" + $path
    }
}
[Environment]::SetEnvironmentVariable("Path", $oldUserPath, "User")

# Update the system PATH environment variable (requires Admin privileges)
$oldSystemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
foreach ($path in $pathsToAdd) {
    if ($oldSystemPath -notlike "*$path*") {
        Write-Host "Adding $path to the System PATH..."
        $oldSystemPath += ";" + $path
    }
}
[Environment]::SetEnvironmentVariable("Path", $oldSystemPath, "Machine")

Write-Host "Installation complete. Python $pythonVersion and pip are installed in $installDir"

----- test use



$pythonTool = "Python"
# Set Python version
$pythonVersion = "3.12.8" 

# Define JFrog Artifactory URLs
$jfrogBaseUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/python/windows"
$pythonZipUrl = "$jfrogBaseUrl/$pythonVersion/python-$pythonVersion.zip"
$getPipUrl = "$jfrogBaseUrl/get-pip.py"

# Define custom installation directory
$installDir = "C:\cicd-tools\$pythonVersion\python-$pythonVersion"

# Create the installation directory if it doesn't exist
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

Write-Host "Downloading Python $pythonVersion zip from JFrog..."
# Download the Python ZIP from JFrog
$zipFile = "$env:TEMP\python.zip"
Invoke-WebRequest -Uri $pythonZipUrl -OutFile $zipFile

Write-Host "Extracting Python to $installDir..."
# Extract the ZIP archive (using .NET's ZipFile class)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installDir)

# Clean up the downloaded ZIP file
Remove-Item $zipFile

# Modify the _pth file to enable site packages (required for pip)
$pthFile = Get-ChildItem -Path $installDir -Filter "*._pth" | Select-Object -First 1
if ($pthFile) {
    Write-Host "Enabling site packages in $($pthFile.Name)..."
    (Get-Content $pthFile.FullName) |
        ForEach-Object { if ($_ -match "^#import site") { "import site" } else { $_ } } |
        Set-Content $pthFile.FullName
}

# Download get-pip.py from JFrog
Write-Host "Downloading get-pip.py from JFrog..."
$pipScript = "$env:TEMP\get-pip.py"
Invoke-WebRequest -Uri $getPipUrl -OutFile $pipScript

# Use the installed Python to run get-pip.py and install pip
Write-Host "Installing pip..."
& "$installDir\python.exe" $pipScript

# Remove the get-pip.py script after installation
Remove-Item $pipScript

# Define paths to add (both Python directory and its Scripts subfolder)
$pythonScriptsPath = "$installDir\Scripts"
$pathsToAdd = @($installDir, $pythonScriptsPath)

# Update the current user's PATH environment variable
$oldUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
foreach ($path in $pathsToAdd) {
    if ($oldUserPath -notlike "*$path*") {
        Write-Host "Adding $path to the User PATH..."
        $oldUserPath += ";" + $path
    }
}
[Environment]::SetEnvironmentVariable("Path", $oldUserPath, "User")

# Update the system PATH environment variable (requires Admin privileges)
$oldSystemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
foreach ($path in $pathsToAdd) {
    if ($oldSystemPath -notlike "*$path*") {
        Write-Host "Adding $path to the System PATH..."
        $oldSystemPath += ";" + $path
    }
}
[Environment]::SetEnvironmentVariable("Path", $oldSystemPath, "Machine")

Write-Host "Installation complete. Python $pythonVersion and pip are installed in $installDir"

# Verify installation
Write-Host "Verifying Python and pip installation..."
$pythonCheck = & "$installDir\python.exe" --version
$pipCheck = & "$installDir\python.exe" -m pip --version

Write-Host "✔ Python Version: $pythonCheck"
Write-Host "✔ pip Version: $pipCheck"

