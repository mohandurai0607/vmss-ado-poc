Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# Define paths
$apachePath = "C:\Program Files\Apache"
$mavenPath = "$apachePath\Maven"

Write-Host "Set TLS1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

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
7z x $zipPath -o"$env:TEMP\apache-maven" | Out-Null

# Locate the extracted folder
$mavenExtractedPath = Get-ChildItem "$env:TEMP\apache-maven" | Where-Object { $_.PSIsContainer } | Select-Object -First 1
[IO.Directory]::Move($mavenExtractedPath.FullName, $mavenPath)

# Clean up
Remove-Item "$env:TEMP\apache-maven" -Recurse -Force
Remove-Item $zipPath -Force

# Set environment variables
[Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
[Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# Add Maven to system PATH
Add-Path "$mavenPath\bin"
Add-SessionPath "$mavenPath\bin"

# Verify installation
mvn --version

Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green
