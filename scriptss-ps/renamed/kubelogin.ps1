# # Fetch kubelogin tool details from the manifest
# $kubeloginTool = Get-ManifestTool -Name "kubelogin"
# $installArgs = $($kubeloginTool.installArgs, "/DIR=$($kubeloginTool.installPath)")

# # Verify the tool's source is from Artifactory
# if ($kubeloginTool.source -ne "artifactory") {
#     throw "Unable to install kubelogin. The specified source, '$($kubeloginTool.source)', is not supported."
# }

# # Ensure the tool exists in the manifest
# if ($null -eq $kubeloginTool) {
#     throw "Failed to get the tool 'kubelogin' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
# }

# # Dynamically fetch the kubelogin version from the manifest
# $kubeloginVersion = $kubeloginTool.defaultVersion
# $url = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/kubelogin/$kubeloginVersion/windows/kubelogin.exe"

# # Define the installation path and installation file path
# $installPath = "C:\Program Files\kubelogin"
# $kubeloginExePath = "$installPath\kubelogin.exe"
# $tempKubeloginPath = "$env:TEMP\kubelogin.exe"

# # Create installation directory if it doesn't exist
# if (-Not (Test-Path $installPath)) {
#     Write-Host "Creating installation directory: $installPath"
#     New-Item -Path $installPath -ItemType Directory -Force
# }

# # Download the kubelogin executable using Invoke-WebRequest
# Write-Host "Downloading kubelogin version $kubeloginVersion from $url"
# Invoke-WebRequest -Uri $url -OutFile $tempKubeloginPath -ErrorAction Stop

# # Move the downloaded file to the installation directory
# Write-Host "Installing kubelogin to $installPath"
# Move-Item -Path $tempKubeloginPath -Destination $kubeloginExePath -Force

# # Validate the installation directory
# if (-Not (Test-Path $kubeloginExePath)) {
#     throw "kubelogin installation failed. The required binary file is missing in the installation directory."
# }

# # Update the PATH environment variable for kubelogin
# Write-Host "Updating PATH environment variable for kubelogin"
# $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
# if ($currentPath -notlike "*$installPath*") {
#     [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", [System.EnvironmentVariableTarget]::Machine)
# }

# # Verify kubelogin installation
# Write-Host "Verifying kubelogin installation..."
# try {
#     $kubeloginVersionOutput = & "$kubeloginExePath" --version
#     Write-Host "kubelogin installed successfully: $kubeloginVersionOutput"
# } catch {
#     throw "Failed to verify kubelogin installation. Error: $_"
# }

# Write-Host "kubelogin installation completed successfully."


-----------------------------------
# Fetch kubelogin tool details from the manifest
$kubeloginTool = Get-ManifestTool -Name "Kubelogin"

# Ensure the tool exists in the manifest
if ($null -eq $kubeloginTool) {
    throw "Failed to get the tool 'kubelogin' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Verify the tool's source is from Artifactory
if ($kubeloginTool.source -ne "artifactory") {
    throw "Unable to install kubelogin. The specified source, '$($kubeloginTool.source)', is not supported."
}

# Fetch the kubelogin version from the manifest
$kubeloginVersion = $kubeloginTool.defaultVersion

# Define paths
$softwarePath = "C:\software"
$kubeloginPath = Join-Path $softwarePath "kubelogin_windows_$kubeloginVersion"
$downloadUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/kubelogin/$kubeloginVersion/windows/kubelogin.exe"
$kubeloginExePath = Join-Path $kubeloginPath "kubelogin.exe"

# Create the directory if it doesn't exist
if (-Not (Test-Path $kubeloginPath)) {
    Write-Host "Creating installation directory: $kubeloginPath"
    New-Item -Path $kubeloginPath -ItemType Directory -Force
}

# Download kubelogin
Write-Host "Downloading kubelogin version $kubeloginVersion from Artifactory"
$archivePath = Invoke-DownloadWithRetry $downloadUrl

# Move the downloaded file to the installation directory
Write-Host "Installing kubelogin to $kubeloginPath"
Move-Item -Path $archivePath -Destination $kubeloginExePath -Force

# Validate installation
if (-Not (Test-Path $kubeloginExePath)) {
    throw "kubelogin installation failed. The required binary file is missing in the installation directory."
}

# Update the PATH environment variable
Write-Host "Updating PATH environment variable for kubelogin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$kubeloginPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$kubeloginPath", [System.EnvironmentVariableTarget]::Machine)
}

# Verify installation
Write-Host "Verifying kubelogin installation..."
try {
    $kubeloginVersionOutput = & "$kubeloginExePath" --version
    Write-Host "kubelogin installed successfully: $kubeloginVersionOutput"
} catch {
    throw "Failed to verify kubelogin installation. Error: $_"
}

Write-Host "kubelogin installation completed successfully."


#---------------

Describe "kubelogin installation" {

    # Fetch kubelogin version from the manifest
    $kubeloginToolManifest = Get-ManifestTool -Name "Kubelogin"
    $targetVersion = "v$($kubeloginToolManifest.defaultVersion)"

    Context "kubelogin executable validation" {
        It "kubelogin.exe should exist somewhere on the system" {
            $kubeloginPath = Get-Command kubelogin.exe -ErrorAction SilentlyContinue
            $kubeloginPath | Should -Not -Be $null
        }
    }

    Context "kubelogin version check" {
        It "kubelogin version should match manifest version" {
            $versionOutput = & kubelogin.exe --version
            if ($versionOutput -match "v\d+\.\d+\.\d+") {
                $extractedVersion = $matches[0]
            } else {
                $extractedVersion = "UNKNOWN"
            }
            $extractedVersion | Should -BeExactly $targetVersion
        }
    }
}


