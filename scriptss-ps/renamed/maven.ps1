# Define Maven tool from the manifest
$mavenTool = Get-ManifestTool -Name "Maven"

# Verify the tool's source is from Artifactory
if ($mavenTool.source -ne "artifactory") {
    throw "Unable to install Maven. The specified source, '$($mavenTool.source)', is not supported."
}

# Ensure the tool exists in the manifest
if ($null -eq $mavenTool) {
    throw "Failed to get the tool 'Maven' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Dynamically construct the Artifactory URL for the specific version of Maven
$mavenVersion = $mavenTool.defaultVersion
$mavenUrl = "https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/$mavenVersion/windows/maven-$mavenVersion.zip"

# Set up installation paths
$mavenRootPath = "C:\software\Maven"
$mavenPath = Join-Path $mavenRootPath "maven-$mavenVersion"

# Check if Maven is already installed
if (Test-Path $mavenPath) {
    Write-Host "Maven version $mavenVersion already installed at $mavenPath. No action will be taken."
    return
}

# Download the Maven ZIP file
$zipFilePath = "$env:TEMP\maven-$mavenVersion.zip"
Write-Host "Downloading Maven version $mavenVersion from $mavenUrl"
Invoke-WebRequest -Uri $mavenUrl -OutFile $zipFilePath -UseBasicParsing
Write-Host "Maven ZIP downloaded to $zipFilePath"

# Extract the ZIP file
Write-Host "Extracting Maven ZIP to $mavenPath"
if (-Not (Test-Path $mavenRootPath)) {
    New-Item -ItemType Directory -Path $mavenRootPath | Out-Null
}
Expand-Archive -Path $zipFilePath -DestinationPath $mavenRootPath -Force
Remove-Item $zipFilePath

# Ensure extracted folder matches the version-specific folder structure
if (Test-Path "$mavenRootPath\apache-maven-$mavenVersion") {
    Rename-Item -Path "$mavenRootPath\apache-maven-$mavenVersion" -NewName "maven-$mavenVersion"
}

# Set environment variables
Write-Host "Setting M2_HOME and PATH environment variables"
[System.Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, [EnvironmentVariableTarget]::Machine)

$mavenBinPath = Join-Path $mavenPath "bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$mavenBinPath*") {
    Write-Host "Adding Maven bin to system PATH"
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$mavenBinPath", [EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "Maven bin is already in the system PATH"
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify Maven installation
Write-Host "Verifying Maven installation..."
$mvnPath = Join-Path $mavenBinPath "mvn.cmd"
if (Test-Path $mvnPath) {
    Write-Host "Maven executable found at $mvnPath"
    & $mvnPath -version
} else {
    Write-Error "Maven executable not found at $mvnPath. Installation failed."
    exit 1
}


### test purpose machine -------

# Define Maven name and version
$toolName = "Maven"
$mavenVersion = "version"  # Replace with the actual version

# Construct the Artifactory URL
$mavenUrl = "https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/$mavenVersion/windows/maven-$mavenVersion.zip"

# Set up installation paths
$mavenRootPath = "C:\software\$toolName"
$mavenPath = Join-Path $mavenRootPath "$toolName-$mavenVersion"
$mavenBinPath = Join-Path $mavenPath "bin"

# Ensure the Maven root directory exists
if (-Not (Test-Path $mavenRootPath)) {
    New-Item -ItemType Directory -Path $mavenRootPath | Out-Null
}

# Download Maven
$zipFilePath = "$env:TEMP\$toolName-$mavenVersion.zip"
Write-Host "Downloading $toolName version $mavenVersion from $mavenUrl"
Invoke-WebRequest -Uri $mavenUrl -OutFile $zipFilePath -UseBasicParsing

# Extract Maven
Write-Host "Extracting $toolName ZIP to $mavenRootPath"
Expand-Archive -Path $zipFilePath -DestinationPath $mavenRootPath -Force
Remove-Item $zipFilePath

# Set environment variables
Write-Host "Setting M2_HOME and PATH environment variables for $toolName"
[System.Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, [EnvironmentVariableTarget]::Machine)
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$mavenBinPath", [EnvironmentVariableTarget]::Machine)

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify Maven installation
Write-Host "Verifying $toolName installation..."
$mvnPath = Join-Path $mavenBinPath "mvn.cmd"
if (Test-Path $mvnPath) {
    Write-Host "$toolName installed successfully. Version details:"
    & $mvnPath -version
} else {
    throw "$toolName installation failed. Maven executable not found at $mvnPath."
}

