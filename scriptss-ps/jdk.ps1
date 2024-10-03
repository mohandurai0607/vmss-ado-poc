# Set JDK path and software path variables
$installerPath = "C:\software\java"
$installerFile = "jdk-21_windows-x64_bin.exe"
$outFile = Join-Path $installerPath $installerFile

Write-Host "Setting TLS1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check if JDK directory exists; create it if not
if (-Not (Test-Path $installerPath)) {
    Write-Host "Creating installer directory: $installerPath"
    New-Item -Path $installerPath -ItemType Directory
}

# Set URI source variable for the installer file
$source = 'https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/jdk/Oracle/windows/21.0.2/jdk-21_windows-x64_bin.exe'

# Download the installer
Write-Host "Downloading Java installer from: $source"
Invoke-WebRequest -Uri $source -OutFile $outFile

# Verify the installer was downloaded
if (-Not (Test-Path $outFile)) {
    Write-Host "Failed to download the installer. Check the URL and network."
    exit 1
}

# Run the installer silently
Write-Host "Running Java installer..."
Start-Process -FilePath $outFile -ArgumentList "/s" -Wait

# After installation, Java should be listed in 'Add/Remove Programs'

# Optionally, set JAVA_HOME manually if required
$javaHomePath = "C:\Program Files\Java\jdk-21"
Write-Host "Setting JAVA_HOME to: $javaHomePath"
[System.Environment]::SetEnvironmentVariable('JAVA_HOME_21_X64', $javaHomePath, [System.EnvironmentVariableTarget]::Machine)

# Verify the installation
Write-Host "Verifying Java installation..."
java -version
