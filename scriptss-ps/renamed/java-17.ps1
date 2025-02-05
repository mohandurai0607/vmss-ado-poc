# Define Java tool from the manifest
$javaTool = Get-ManifestTool -Name "Java"
$installArgs = $($javaTool.installArgs, "/DIR=$($javaTool.installPath)")

# Verify the tool's source is from Artifactory
if ($javaTool.source -ne "artifactory") {
    throw "Unable to install Java. The specified source, '$($javaTool.source)', is not supported."
}

# Ensure the tool exists in the manifest
if ($null -eq $javaTool) {
    throw "Failed to get the tool 'Java' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Dynamically construct the Artifactory URL for Java 17
$javaVersion = "17" ## here updated the version
$javaUrl = "https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/jdk/Oracle/windows/$javaVersion/jdk-$javaVersion.zip"

# Set up installation paths
$javaRootPath = "C:\software\java"
$javaPath = Join-Path $javaRootPath "java-$javaVersion"

# Check if Java is already installed
if (Test-Path $javaPath) {
    Write-Host "Java version $javaVersion already installed at $javaPath. No action will be taken."
    return
}

# Download the Java ZIP file
$zipFilePath = "$env:TEMP\jdk-$javaVersion.zip"
Write-Host "Downloading Java version $javaVersion from $javaUrl"
Invoke-WebRequest -Uri $javaUrl -OutFile $zipFilePath -UseBasicParsing
Write-Host "Java ZIP downloaded to $zipFilePath"

# Extract the ZIP file
Write-Host "Extracting Java ZIP to $javaPath"
if (-Not (Test-Path $javaPath)) {
    New-Item -ItemType Directory -Path $javaPath | Out-Null
}
Expand-Archive -Path $zipFilePath -DestinationPath $javaPath -Force
Remove-Item $zipFilePath

# Set environment variables
Write-Host "Setting JAVA_HOME and PATH environment variables"
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, [EnvironmentVariableTarget]::Machine)

$javaBinPath = Join-Path $javaPath "bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$javaBinPath*") {
    Write-Host "Adding Java bin to system PATH"
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$javaBinPath", [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "Java bin is already in the system PATH"
}

# Refresh the environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify Java installation
Write-Host "Verifying Java installation..."
if (Get-Command java -ErrorAction SilentlyContinue) {
    java -version
} else {
    Write-Error "Java installation failed. Please check the environment variables and paths."
}
