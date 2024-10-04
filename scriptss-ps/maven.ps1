# # Set the Maven version you want to install
# $mavenVersion = "3.9.4"
# $mavenUrl = "https://archive.apache.org/dist/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"

# # Download the Maven zip file
# $downloadPath = "$env:TEMP\apache-maven-$mavenVersion-bin.zip"
# Invoke-WebRequest -Uri $mavenUrl -OutFile $downloadPath

# # Specify the directory to extract Maven
# $installDir = "C:\Tools\Maven"
# Expand-Archive -Path $downloadPath -DestinationPath $installDir -Force

# # Set Maven Environment Variables
# $env:M2_HOME = "$installDir\apache-maven-$mavenVersion"
# $env:Path = "$env:M2_HOME\bin;$env:Path"

# # Optionally, permanently set environment variables (requires admin rights)
# [System.Environment]::SetEnvironmentVariable("M2_HOME", "$installDir\apache-maven-$mavenVersion", [System.EnvironmentVariableTarget]::Machine)
# [System.Environment]::SetEnvironmentVariable("Path", "$env:M2_HOME\bin;$env:Path", [System.EnvironmentVariableTarget]::Machine)

# # Verify installation
# mvn -version
#------- above is working from offical one ------

# Set the Maven version you want to install
$mavenVersion = "3.9.9"
$mavenUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/maven/$mavenVersion/windows/maven-$mavenVersion.zip"

# Download the Maven zip file
$downloadPath = "$env:TEMP\apache-maven-$mavenVersion.zip"
Write-Host "Downloading Maven from $mavenUrl to $downloadPath"
Invoke-WebRequest -Uri $mavenUrl -OutFile $downloadPath

# Specify the directory to extract Maven
$installDir = "C:\software\Maven"
Write-Host "Extracting Maven to $installDir"
Expand-Archive -Path $downloadPath -DestinationPath $installDir -Force

# Adjust path to the extracted directory (if it's extracted directly into C:\software\Maven without a versioned folder)
$mavenInstallPath = "$installDir"

# Set Maven Environment Variables
$env:M2_HOME = $mavenInstallPath
$env:Path = "$env:M2_HOME\bin;$env:Path"

# Optionally, permanently set environment variables (requires admin rights)
Write-Host "Setting M2_HOME and Path environment variables"
[System.Environment]::SetEnvironmentVariable("M2_HOME", $env:M2_HOME, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", "$env:M2_HOME\bin;$env:Path", [System.EnvironmentVariableTarget]::Machine)

# Refresh environment variables for the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify that mvn.exe exists
$mvnPath = "$env:M2_HOME\bin\mvn.cmd"
if (Test-Path $mvnPath) {
    Write-Host "Maven executable found at $mvnPath"
} else {
    Write-Host "Maven executable not found at $mvnPath"
    exit 1
}

# Verify installation by calling mvn from the new path
Write-Host "Running mvn -version"
& $mvnPath -version
