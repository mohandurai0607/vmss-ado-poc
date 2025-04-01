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

# Create installation directory (without checking existence)
Write-Host "Creating installation directory: $kubeloginPath"
New-Item -Path $kubeloginPath -ItemType Directory -Force

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

# Update the PATH environment variable and refresh it in the current session
Write-Host "Updating PATH environment variable for kubelogin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$kubeloginPath", [System.EnvironmentVariableTarget]::Machine)

# Refresh PATH in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

Write-Host "kubelogin installation completed successfully."

# Run Pester test
Invoke-Pester C:\image\tests\Kubelogin.Tests.ps1


#---------------

# Describe "kubelogin installation" {

#     # Fetch kubelogin version from the manifest
#     $kubeloginToolManifest = Get-ManifestTool -Name "Kubelogin"

#     Context "kubelogin executable validation" {
#         It "kubelogin.exe should exist" {
#             $kubeloginPath = Get-Command kubelogin.exe -ErrorAction SilentlyContinue
#             $kubeloginPath | Should -Not -Be $null
#         }
#     }

#     Context "kubelogin version check" {
#         It "kubelogin should return a valid version" {
#             $versionOutput = & kubelogin.exe --version
#             $versionOutput | Should -Not -BeNullOrEmpty
#         }
#     }
# }
#------------------
# BeforeAll {
#     # Fetch kubelogin tool details from the manifest
#     $kubeloginTool = Get-ManifestTool -Name "Kubelogin"

#     # Ensure the tool exists in the manifest
#     if ($null -eq $kubeloginTool) {
#         throw "Failed to get the tool 'kubelogin' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
#     }

#     # Define the expected installation path
#     $softwarePath = "C:\software"
#     $kubeloginPath = Join-Path $softwarePath "kubelogin_windows_$($kubeloginTool.defaultVersion)"
#     $kubeloginExePath = Join-Path $kubeloginPath "kubelogin.exe"

#     # Make sure the variable is globally available
#     Set-Variable -Name "kubeloginExePath" -Value $kubeloginExePath -Scope Global
# }

# Describe "kubelogin Installation Validation" {
#     # Fetch kubelogin tool details from the manifest
#     $kubeloginTool = Get-ManifestTool -Name "Kubelogin"

#     Context "kubelogin executable validation" {
#         It "kubelogin.exe should exist in the expected directory" {
#             Test-Path kubelogin.exe | Should -Be $true
#         }
#     }

#     Context "kubelogin version check" {
#         It "kubelogin should return a valid version output" {
#             $versionOutput = & kubelogin.exe --version
#             $versionOutput | Should -Not -BeNullOrEmpty
#         }
#     }
# }

#_________


Describe "kubelogin Installation Validation" {
    Context "kubelogin executable validation" {
        It "kubelogin.exe should be accessible in the system PATH" {
            $kubeloginExists = Get-Command kubelogin.exe -ErrorAction SilentlyContinue
            $kubeloginExists | Should -Not -BeNullOrEmpty
        }
    }

    Context "kubelogin version check" {
        It "kubelogin should return a valid version output" {
            $versionOutput = & kubelogin.exe --version
            $versionOutput | Should -Not -BeNullOrEmpty
        }
    }
}



