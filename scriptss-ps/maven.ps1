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
Invoke-WebRequest -Uri $mavenUrl -OutFile $downloadPath

# Specify the directory to extract Maven
$installDir = "C:\software\Maven"
Expand-Archive -Path $downloadPath -DestinationPath $installDir -Force

# Set Maven Environment Variables
$env:M2_HOME = "$installDir\maven-$mavenVersion"
$env:Path = "$env:M2_HOME\bin;$env:Path"

# Optionally, permanently set environment variables (requires admin rights)
[System.Environment]::SetEnvironmentVariable("M2_HOME", "$installDir\maven-$mavenVersion", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", "$env:M2_HOME\bin;$env:Path", [System.EnvironmentVariableTarget]::Machine)

# Refresh environment variables for the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Verify installation by calling mvn from the new path
Start-Process "mvn" -ArgumentList "-version" -NoNewWindow -Wait
