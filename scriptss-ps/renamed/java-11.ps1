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

# Dynamically construct the Artifactory URL for Java 11
$javaVersion = "11" ## update the version here
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

# Set JAVA_HOME and PATH environment variables
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

# Set BDS_JAVA_HOME for Blackduck
Write-Host "Setting BDS_JAVA_HOME to $javaPath"
[System.Environment]::SetEnvironmentVariable("BDS_JAVA_HOME", $javaPath, [EnvironmentVariableTarget]::Machine)

# Refresh the environment variables in the current session
$env:JAVA_HOME = $javaPath
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$env:BDS_JAVA_HOME = $javaPath

# Verify Java installation
Write-Host "Verifying Java installation..."
if (Get-Command java -ErrorAction SilentlyContinue) {
    java -version
} else {
    Write-Error "Java installation failed. Please check the environment variables and paths."
}

# Verify BDS_JAVA_HOME
Write-Host "Verifying BDS_JAVA_HOME..."
$bdsJavaHome = [System.Environment]::GetEnvironmentVariable("BDS_JAVA_HOME", [EnvironmentVariableTarget]::Machine)
if ($bdsJavaHome -eq $javaPath) {
    Write-Host "BDS_JAVA_HOME is set correctly to: $bdsJavaHome"
} else {
    Write-Error "BDS_JAVA_HOME is not set correctly. Expected: $javaPath, Actual: $bdsJavaHome"
}
