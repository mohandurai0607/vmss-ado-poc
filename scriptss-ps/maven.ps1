# Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# # Define paths
# $apachePath = "C:\Program Files\Apache"
# $mavenPath = "$apachePath\Maven"

# Write-Host "Set TLS1.2"
# # Ensure TLS1.2 is used
# [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# # Remove any existing Maven installation if exists
# if (Test-Path $mavenPath) {
#     Remove-Item $mavenPath -Recurse -Force
# }

# # Create Apache directory if it does not exist
# if (-not (Test-Path $apachePath)) {
#     New-Item $apachePath -ItemType directory -Force
# }

# # Download Maven
# Write-Host "Downloading Apache Maven 3.9.9 ..."
# $zipPath = "$env:TEMP\maven-3.9.9.zip"
# (New-Object Net.WebClient).DownloadFile('https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/3.9.9/windows/maven-3.9.9.zip', $zipPath)

# # Unpack the zip file
# Write-Host "Unpacking Maven..."
# $unpackDir = "C:\apache-maven"
# 7z x $zipPath -o$unpackDir | Out-Null

# # Verify unpacking and correct directory structure
# $mavenExtractedPath = Get-ChildItem $unpackDir | Where-Object { $_.Name -like "apache-maven-*" } | Select-Object -First 1

# if ($mavenExtractedPath -ne $null) {
#     Write-Host "Moving extracted Maven files to $mavenPath..."
#     [IO.Directory]::Move($mavenExtractedPath.FullName, $mavenPath)
# } else {
#     Write-Host "Extraction failed or the expected directory was not found." -ForegroundColor Red
#     exit 1
# }

# # Clean up temporary files
# Remove-Item $unpackDir -Recurse -Force
# Remove-Item $zipPath -Force

# # Set environment variables
# [Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
# [Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# # Add Maven to system PATH
# function Add-Path {
#     param (
#         [string]$Path
#     )
#     $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
#     if ($currentPath -notlike "*$Path*") {
#         [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", "Machine")
#     }
# }

# Add-Path "$mavenPath\bin"

# # Make the path changes effective in the current session
# function Add-SessionPath {
#     param (
#         [string]$Path
#     )
#     $env:Path += ";$Path"
# }

# Add-SessionPath "$mavenPath\bin"

# # Check Maven installation
# mvn --version

# Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green

Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# Define paths
$apachePath = "C:\Program Files\Apache"
$mavenPath = "$apachePath\Maven"
$tempExtractPath = "$env:TEMP\apache-maven-temp"

Write-Host "Setting TLS1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# Clean up previous installations if they exist
if (Test-Path $mavenPath) {
    Remove-Item $mavenPath -Recurse -Force
}

if (-not (Test-Path $apachePath)) {
    New-Item $apachePath -ItemType directory -Force
}

# Download Maven
Write-Host "Downloading Apache Maven 3.9.9 ..."
$zipPath = "$env:TEMP\maven-3.9.9.zip"
(New-Object Net.WebClient).DownloadFile('https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/3.9.9/windows/maven-3.9.9.zip', $zipPath)

# Unpack the zip file
Write-Host "Unpacking Maven..."
if (Test-Path $tempExtractPath) {
    Remove-Item $tempExtractPath -Recurse -Force
}
New-Item $tempExtractPath -ItemType directory -Force

# Extracting the zip file to a temp directory
7z x $zipPath -o$tempExtractPath | Out-Null

# Check for the extracted folder and move it to the desired location
$mavenExtractedPath = Get-ChildItem $tempExtractPath | Where-Object { $_.PSIsContainer -and $_.Name -match "maven" } | Select-Object -First 1
if ($mavenExtractedPath) {
    Write-Host "Moving Maven to $mavenPath..."
    Move-Item $mavenExtractedPath.FullName $mavenPath
} else {
    Write-Host "Maven extraction failed. No extracted folder found." -ForegroundColor Red
    exit 1
}

# Clean up temp files
Remove-Item $tempExtractPath -Recurse -Force
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

# Verify Maven installation
$mavenVersion = &mvn --version 2>&1
if ($mavenVersion -match "Apache Maven") {
    Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to install Maven. Please check the script and try again." -ForegroundColor Red
}
