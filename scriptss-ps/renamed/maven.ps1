# Define Maven tool from the manifest
$mavenTool = Get-ManifestTool -Name "Maven"
$installArgs = $($mavenTool.installArgs, "/DIR=$($mavenTool.installPath)")

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
$mavenUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/maven/$mavenVersion/windows/maven-$mavenVersion.zip"

# Set up installation paths
$mavenPath = "C:\software\Maven\maven-$mavenVersion"
$mavenArchive = "$mavenPath\maven-$mavenVersion.zip"

# Create directory if it does not exist
if (-Not (Test-Path $mavenPath)) {
    Write-Host "Creating directory $mavenPath"
    New-Item -Path $mavenPath -ItemType Directory
} else {
    Write-Host "$mavenPath directory already exists"
}

# Download and install Maven using Install-Binary
Install-Binary `
    -Url $mavenUrl `
    -Type zip `
    -DestinationPath $mavenPath `
    -ErrorAction Stop

# Set M2_HOME environment variable
Write-Host "Setting M2_HOME to: $mavenPath"
[System.Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, [System.EnvironmentVariableTarget]::Machine)

# Add Maven bin folder to the PATH environment variable
$binPath = Join-Path $mavenPath "bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$binPath*") {
    Write-Host "Adding Maven bin to system PATH"
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "Maven bin is already in the system PATH"
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify the installation
Write-Host "Verifying Maven installation..."
$mvnCmd = Join-Path $binPath "mvn.cmd"
if (Test-Path $mvnCmd) {
    & $mvnCmd -version
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to verify Maven installation with exit code $LASTEXITCODE"
    } else {
        Write-Host "Maven installed successfully."
    }
} else {
    Write-Error "Maven executable not found at $mvnCmd. Installation might have failed."
}
