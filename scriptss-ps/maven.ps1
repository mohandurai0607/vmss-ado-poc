Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# Define paths
$apachePath = "C:\Program Files\Apache"
$mavenPath = "$apachePath\Maven"

Write-Host "Set TLS1.2"
# Ensure TLS1.2 is used
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# Remove any existing Maven installation if exists
if (Test-Path $mavenPath) {
    Remove-Item $mavenPath -Recurse -Force
}

# Create Apache directory if it does not exist
if (-not (Test-Path $apachePath)) {
    New-Item $apachePath -ItemType directory -Force
}

# Download Maven
Write-Host "Downloading Apache Maven 3.9.9 ..."
$zipPath = "$env:TEMP\maven-3.9.9.zip"
(New-Object Net.WebClient).DownloadFile('https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/3.9.9/windows/maven-3.9.9.zip', $zipPath)

# Unpack the zip file
Write-Host "Unpacking Maven..."
7z x $zipPath -oC:\apache-maven | Out-Null

# Move unpacked Maven to the designated path
[IO.Directory]::Move('C:\apache-maven\apache-maven-3.9.9', $mavenPath)

# Clean up temporary files
Remove-Item 'C:\apache-maven' -Recurse -Force
Remove-Item $zipPath -Force

# Set environment variables
[Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
[Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# Add Maven to system PATH
function Add-Path {
    param (
        [string]$Path
    )
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$Path*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", "Machine")
    }
}

Add-Path "$mavenPath\bin"

# Make the path changes effective in the current session
function Add-SessionPath {
    param (
        [string]$Path
    )
    $env:Path += ";$Path"
}

Add-SessionPath "$mavenPath\bin"

# Check Maven installation
mvn --version

Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green
