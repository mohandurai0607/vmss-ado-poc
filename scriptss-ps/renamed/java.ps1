# Define Java tool from the manifest
$javaTool = Get-ManifestTool -Name "JDK"
$installArgs = $($javaTool.installArgs, "/DIR=$($javaTool.installPath)")

# Verify the tool's source is from Artifactory
if ($javaTool.source -ne "artifactory") {
    throw "Unable to install JDK. The specified source, '$($javaTool.source)', is not supported."
}

# Ensure the tool exists in the manifest
if ($null -eq $javaTool) {
    throw "Failed to get the tool 'JDK' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Dynamically construct the Artifactory URL for the specific version of JDK
$javaVersion = $javaTool.defaultVersion
$url = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/jdk/Oracle/windows/$javaVersion/jdk-$javaVersion.zip"

# Set up installation paths
$javaPath = "C:\software\java\jdk-$javaVersion"
$javaArchive = "$javaPath\jdk-$javaVersion.zip"

# Create directory if it does not exist
if (-Not (Test-Path $javaPath)) {
    Write-Host "Creating directory $javaPath"
    New-Item -Path $javaPath -ItemType Directory
} else {
    Write-Host "$javaPath directory already exists"
}

# Download and install JDK using Install-Binary
Install-Binary `
    -Url $url `
    -Type zip `
    -DestinationPath $javaPath `
    -ErrorAction Stop

# Set JAVA_HOME environment variable
Write-Host "Setting JAVA_HOME to: $javaPath"
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', $javaPath, [System.EnvironmentVariableTarget]::Machine)

# Add JDK bin folder to the PATH environment variable
$binPath = Join-Path $javaPath "bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$binPath*") {
    Write-Host "Adding JDK bin to system PATH"
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "JDK bin is already in the system PATH"
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify the installation
Write-Host "Verifying Java installation..."
try {
    & "$binPath\java.exe" -version
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to verify JDK installation with exit code $LASTEXITCODE"
    } else {
        Write-Host "JDK installed successfully."
    }
} catch {
    Write-Error "Java is not installed correctly. Please check the environment variables and paths."
}
