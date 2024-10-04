# Set the Maven version you want to install
$mavenVersion = "3.9.4"
$mavenUrl = "https://archive.apache.org/dist/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"

# Download the Maven zip file
$downloadPath = "$env:TEMP\apache-maven-$mavenVersion-bin.zip"
Invoke-WebRequest -Uri $mavenUrl -OutFile $downloadPath

# Specify the directory to extract Maven
$installDir = "C:\Tools\Maven"
Expand-Archive -Path $downloadPath -DestinationPath $installDir -Force

# Set Maven Environment Variables
$env:M2_HOME = "$installDir\apache-maven-$mavenVersion"
$env:Path = "$env:M2_HOME\bin;$env:Path"

# Optionally, permanently set environment variables (requires admin rights)
[System.Environment]::SetEnvironmentVariable("M2_HOME", "$installDir\apache-maven-$mavenVersion", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", "$env:M2_HOME\bin;$env:Path", [System.EnvironmentVariableTarget]::Machine)

# Verify installation
mvn -version
