# # # # Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# # # # # Define paths
# # # # $apachePath = "C:\Program Files\Apache"
# # # # $mavenPath = "$apachePath\Maven"

# # # # Write-Host "Set TLS1.2"
# # # # # Ensure TLS1.2 is used
# # # # [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# # # # # Remove any existing Maven installation if exists
# # # # if (Test-Path $mavenPath) {
# # # #     Remove-Item $mavenPath -Recurse -Force
# # # # }

# # # # # Create Apache directory if it does not exist
# # # # if (-not (Test-Path $apachePath)) {
# # # #     New-Item $apachePath -ItemType directory -Force
# # # # }

# # # # # Download Maven
# # # # Write-Host "Downloading Apache Maven 3.9.9 ..."
# # # # $zipPath = "$env:TEMP\maven-3.9.9.zip"
# # # # (New-Object Net.WebClient).DownloadFile('https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/3.9.9/windows/maven-3.9.9.zip', $zipPath)

# # # # # Unpack the zip file
# # # # Write-Host "Unpacking Maven..."
# # # # $unpackDir = "C:\apache-maven"
# # # # 7z x $zipPath -o$unpackDir | Out-Null

# # # # # Verify unpacking and correct directory structure
# # # # $mavenExtractedPath = Get-ChildItem $unpackDir | Where-Object { $_.Name -like "apache-maven-*" } | Select-Object -First 1

# # # # if ($mavenExtractedPath -ne $null) {
# # # #     Write-Host "Moving extracted Maven files to $mavenPath..."
# # # #     [IO.Directory]::Move($mavenExtractedPath.FullName, $mavenPath)
# # # # } else {
# # # #     Write-Host "Extraction failed or the expected directory was not found." -ForegroundColor Red
# # # #     exit 1
# # # # }

# # # # # Clean up temporary files
# # # # Remove-Item $unpackDir -Recurse -Force
# # # # Remove-Item $zipPath -Force

# # # # # Set environment variables
# # # # [Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
# # # # [Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# # # # # Add Maven to system PATH
# # # # function Add-Path {
# # # #     param (
# # # #         [string]$Path
# # # #     )
# # # #     $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
# # # #     if ($currentPath -notlike "*$Path*") {
# # # #         [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", "Machine")
# # # #     }
# # # # }

# # # # Add-Path "$mavenPath\bin"

# # # # # Make the path changes effective in the current session
# # # # function Add-SessionPath {
# # # #     param (
# # # #         [string]$Path
# # # #     )
# # # #     $env:Path += ";$Path"
# # # # }

# # # # Add-SessionPath "$mavenPath\bin"

# # # # # Check Maven installation
# # # # mvn --version

# # # # Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green

# # # Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# # # # Define paths
# # # $apachePath = "C:\Program Files\Apache"
# # # $mavenPath = "$apachePath\Maven"
# # # $tempExtractPath = "$env:TEMP\apache-maven-temp"

# # # Write-Host "Setting TLS1.2"
# # # [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# # # # Clean up previous installations if they exist
# # # if (Test-Path $mavenPath) {
# # #     Remove-Item $mavenPath -Recurse -Force
# # # }

# # # if (-not (Test-Path $apachePath)) {
# # #     New-Item $apachePath -ItemType directory -Force
# # # }

# # # # Download Maven
# # # Write-Host "Downloading Apache Maven 3.9.9 ..."
# # # $zipPath = "$env:TEMP\maven-3.9.9.zip"
# # # (New-Object Net.WebClient).DownloadFile('https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/3.9.9/windows/maven-3.9.9.zip', $zipPath)

# # # # Unpack the zip file
# # # Write-Host "Unpacking Maven..."
# # # if (Test-Path $tempExtractPath) {
# # #     Remove-Item $tempExtractPath -Recurse -Force
# # # }
# # # New-Item $tempExtractPath -ItemType directory -Force

# # # # Extracting the zip file to a temp directory
# # # 7z x $zipPath -o$tempExtractPath | Out-Null

# # # # Check for the extracted folder and move it to the desired location
# # # $mavenExtractedPath = Get-ChildItem $tempExtractPath | Where-Object { $_.PSIsContainer -and $_.Name -match "maven" } | Select-Object -First 1
# # # if ($mavenExtractedPath) {
# # #     Write-Host "Moving Maven to $mavenPath..."
# # #     Move-Item $mavenExtractedPath.FullName $mavenPath
# # # } else {
# # #     Write-Host "Maven extraction failed. No extracted folder found." -ForegroundColor Red
# # #     exit 1
# # # }

# # # # Clean up temp files
# # # Remove-Item $tempExtractPath -Recurse -Force
# # # Remove-Item $zipPath -Force

# # # # Set environment variables
# # # [Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
# # # [Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# # # # Add Maven to system PATH
# # # function Add-Path {
# # #     param (
# # #         [string]$Path
# # #     )
# # #     $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
# # #     if ($currentPath -notlike "*$Path*") {
# # #         [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", "Machine")
# # #     }
# # # }

# # # Add-Path "$mavenPath\bin"

# # # # Make the path changes effective in the current session
# # # function Add-SessionPath {
# # #     param (
# # #         [string]$Path
# # #     )
# # #     $env:Path += ";$Path"
# # # }

# # # Add-SessionPath "$mavenPath\bin"

# # # # Verify Maven installation
# # # $mavenVersion = &mvn --version 2>&1
# # # if ($mavenVersion -match "Apache Maven") {
# # #     Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green
# # # } else {
# # #     Write-Host "Failed to install Maven. Please check the script and try again." -ForegroundColor Red
# # # }
# # Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# # # Define paths
# # $apachePath = "C:\Program Files\Apache"
# # $mavenPath = "$apachePath\Maven"
# # $tempExtractPath = "$env:TEMP\apache-maven-temp"

# # Write-Host "Setting TLS1.2"
# # [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# # # Clean up previous Maven installation if it exists
# # if (Test-Path $mavenPath) {
# #     Write-Host "Removing existing Maven installation..."
# #     Remove-Item $mavenPath -Recurse -Force
# # }

# # if (-not (Test-Path $apachePath)) {
# #     Write-Host "Creating Apache directory..."
# #     New-Item $apachePath -ItemType directory -Force
# # }

# # # Download Maven zip file
# # Write-Host "Downloading Apache Maven 3.9.9 ..."
# # $zipPath = "$env:TEMP\maven-3.9.9.zip"
# # Invoke-WebRequest -Uri 'https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/3.9.9/windows/maven-3.9.9.zip' -OutFile $zipPath

# # # Check if download was successful
# # if (-not (Test-Path $zipPath)) {
# #     Write-Host "Download failed. The zip file could not be found." -ForegroundColor Red
# #     exit 1
# # }

# # # Unpack the zip file
# # Write-Host "Unpacking Maven..."
# # if (Test-Path $tempExtractPath) {
# #     Write-Host "Removing existing temp extraction directory..."
# #     Remove-Item $tempExtractPath -Recurse -Force
# # }
# # New-Item $tempExtractPath -ItemType directory -Force

# # # Use .NET to extract the zip file
# # Add-Type -AssemblyName System.IO.Compression.FileSystem
# # try {
# #     [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $tempExtractPath)
# #     Write-Host "Extraction completed successfully."
# # } catch {
# #     Write-Host "Extraction failed with error: $_" -ForegroundColor Red
# #     exit 1
# # }

# # # Check for the extracted folder
# # $mavenExtractedPath = Get-ChildItem $tempExtractPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
# # if ($mavenExtractedPath -and (Test-Path $mavenExtractedPath.FullName)) {
# #     Write-Host "Maven extracted successfully to $($mavenExtractedPath.FullName). Moving to $mavenPath..."
# #     Move-Item $mavenExtractedPath.FullName $mavenPath
# # } else {
# #     Write-Host "Extraction failed or the expected directory was not found." -ForegroundColor Red
# #     Write-Host "Contents of the temp extraction directory:" -ForegroundColor Yellow
# #     Get-ChildItem $tempExtractPath | ForEach-Object { Write-Host $_.FullName }
# #     exit 1
# # }

# # # Clean up temp files
# # Write-Host "Cleaning up temporary files..."
# # # Remove-Item $tempExtractPath -Recurse -Force
# # # Remove-Item $zipPath -Force

# # # Set environment variables
# # Write-Host "Setting environment variables..."
# # [Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
# # [Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# # # Add Maven to system PATH
# # Write-Host "Adding Maven to system PATH..."
# # function Add-Path {
# #     param (
# #         [string]$Path
# #     )
# #     $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
# #     if ($currentPath -notlike "*$Path*") {
# #         [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", "Machine")
# #     }
# # }
# # Add-Path "$mavenPath\bin"

# # # Make the path changes effective in the current session
# # Write-Host "Adding Maven to session PATH..."
# # function Add-SessionPath {
# #     param (
# #         [string]$Path
# #     )
# #     $env:Path += ";$Path"
# # }
# # Add-SessionPath "$mavenPath\bin"

# # # Verify Maven installation
# # $mavenVersion = &mvn --version 2>&1
# # if ($mavenVersion -match "Apache Maven") {
# #     Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green
# # } else {
# #     Write-Host "Failed to install Maven. Please check the script and try again." -ForegroundColor Red
# # }
# Write-Host "Installing Apache Maven 3.9.9 ..." -ForegroundColor Cyan

# # Define paths
# $apachePath = "C:\Program Files\Apache"
# $mavenPath = "$apachePath\Maven"
# $tempExtractPath = "$env:TEMP\apache-maven-temp"

# Write-Host "Setting TLS1.2"
# [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

# # Clean up previous Maven installation if it exists
# if (Test-Path $mavenPath) {
#     Write-Host "Removing existing Maven installation..."
#     Remove-Item $mavenPath -Recurse -Force
# }

# if (-not (Test-Path $apachePath)) {
#     Write-Host "Creating Apache directory..."
#     New-Item $apachePath -ItemType directory -Force
# }

# # Download Maven zip file
# Write-Host "Downloading Apache Maven 3.9.9 ..."
# $zipPath = "$env:TEMP\maven-3.9.9.zip"
# Invoke-WebRequest -Uri 'https://prod.artifactory.nfcu.net/artifactory/cicd-generic-release-local/maven/3.9.9/windows/maven-3.9.9.zip' -OutFile $zipPath

# # Check if download was successful
# if (-not (Test-Path $zipPath)) {
#     Write-Host "Download failed. The zip file could not be found." -ForegroundColor Red
#     exit 1
# }

# # Unpack the zip file
# Write-Host "Unpacking Maven..."
# if (Test-Path $tempExtractPath) {
#     Write-Host "Removing existing temp extraction directory..."
#     Remove-Item $tempExtractPath -Recurse -Force
# }
# New-Item $tempExtractPath -ItemType directory -Force

# # Use .NET to extract the zip file
# Add-Type -AssemblyName System.IO.Compression.FileSystem
# try {
#     [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $tempExtractPath)
#     Write-Host "Extraction completed successfully."
# } catch {
#     Write-Host "Extraction failed with error: $_" -ForegroundColor Red
#     exit 1
# }

# # Check for the extracted folder
# $mavenExtractedPath = Get-ChildItem $tempExtractPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
# if ($mavenExtractedPath -and (Test-Path $mavenExtractedPath.FullName)) {
#     Write-Host "Maven extracted successfully to $($mavenExtractedPath.FullName). Moving to $mavenPath..."
#     Move-Item $mavenExtractedPath.FullName $mavenPath
# } else {
#     Write-Host "Extraction failed or the expected directory was not found." -ForegroundColor Red
#     Write-Host "Contents of the temp extraction directory:" -ForegroundColor Yellow
#     Get-ChildItem $tempExtractPath | ForEach-Object { Write-Host $_.FullName }
#     exit 1
# }

# # Clean up temp files
# Write-Host "Cleaning up temporary files..."
# Remove-Item $tempExtractPath -Recurse -Force
# Remove-Item $zipPath -Force

# # Set environment variables
# Write-Host "Setting environment variables..."
# [Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
# [Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# # Add Maven to system PATH
# Write-Host "Adding Maven to system PATH..."
# $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
# if ($currentPath -notlike "*$mavenPath\bin*") {
#     [Environment]::SetEnvironmentVariable("Path", "$currentPath;$mavenPath\bin", "Machine")
# }

# # Make the path changes effective in the current session
# Write-Host "Adding Maven to session PATH..."
# $env:Path += ";$mavenPath\bin"

# # Verify Maven installation
# $mavenVersion = &mvn --version 2>&1
# if ($mavenVersion -match "Apache Maven") {
#     Write-Host "Apache Maven 3.9.9 installed successfully" -ForegroundColor Green
# } else {
#     Write-Host "Failed to install Maven. Please check the script and try again." -ForegroundColor Red
# }

# # Final output of environment variables for verification
# Write-Host "Current environment variables:"
# Get-ChildItem Env: | Where-Object { $_.Name -like "*MAVEN*" -or $_.Name -like "*M2*" -or $_.Name -like "*Path*" } | ForEach-Object { Write-Host "$($_.Name): $($_.Value)" }
Write-Host "Installing Apache Maven..." -ForegroundColor Cyan

# Define paths
$tempExtractPath = "C:\apache-maven-temp"
$apachePath = "C:\Program Files\Apache"
$mavenPath = "$apachePath\Maven"

# Create Apache directory if it doesn't exist
if (-not (Test-Path $apachePath)) {
    Write-Host "Creating Apache directory..."
    New-Item $apachePath -ItemType directory -Force
}

# Check if the temp extraction path exists
if (Test-Path $tempExtractPath) {
    Write-Host "Copying files from $tempExtractPath to $mavenPath..."
    # Remove existing Maven installation if it exists
    if (Test-Path $mavenPath) {
        Write-Host "Removing existing Maven installation..."
        Remove-Item $mavenPath -Recurse -Force
    }
    
    # Copy all files and folders from temp extraction path to Maven path
    Copy-Item "$tempExtractPath\*" -Destination $mavenPath -Recurse

    Write-Host "Files copied successfully."
} else {
    Write-Host "Extraction path $tempExtractPath not found." -ForegroundColor Red
    exit 1
}

# Clean up temp extraction directory
Write-Host "Cleaning up temporary files..."
Remove-Item $tempExtractPath -Recurse -Force

# Set environment variables
Write-Host "Setting environment variables..."
[Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
[Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")

# Add Maven to system PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$mavenPath\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$mavenPath\bin", "Machine")
}

# Make the path changes effective in the current session
Write-Host "Adding Maven to session PATH..."
$env:Path += ";$mavenPath\bin"

# Verify Maven installation
$mavenVersion = &mvn --version 2>&1
if ($mavenVersion -match "Apache Maven") {
    Write-Host "Apache Maven installed successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to install Maven. Please check the script and try again." -ForegroundColor Red
}

# Final output of environment variables for verification
Write-Host "Current environment variables:"
Get-ChildItem Env: | Where-Object { $_.Name -like "*MAVEN*" -or $_.Name -like "*M2*" -or $_.Name -like "*Path*" } | ForEach-Object { Write-Host "$($_.Name): $($_.Value)" }
