# Fetch kubelogin tool details from the manifest
$kubeloginTool = Get-ManifestTool -Name "kubelogin"
$installArgs = $($kubeloginTool.installArgs, "/DIR=$($kubeloginTool.installPath)")

# Verify the tool's source is from Artifactory
if ($kubeloginTool.source -ne "artifactory") {
    throw "Unable to install kubelogin. The specified source, '$($kubeloginTool.source)', is not supported."
}

# Ensure the tool exists in the manifest
if ($null -eq $kubeloginTool) {
    throw "Failed to get the tool 'kubelogin' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

# Dynamically fetch the kubelogin version from the manifest
$kubeloginVersion = $kubeloginTool.defaultVersion
$url = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/kubelogin/$kubeloginVersion/windows/kubelogin.exe"

# Define the installation path and installation file path
$installPath = "C:\Program Files\kubelogin"
$kubeloginExePath = "$installPath\kubelogin.exe"
$tempKubeloginPath = "$env:TEMP\kubelogin.exe"

# Create installation directory if it doesn't exist
if (-Not (Test-Path $installPath)) {
    Write-Host "Creating installation directory: $installPath"
    New-Item -Path $installPath -ItemType Directory -Force
}

# Download the kubelogin executable using Invoke-WebRequest
Write-Host "Downloading kubelogin version $kubeloginVersion from $url"
Invoke-WebRequest -Uri $url -OutFile $tempKubeloginPath -ErrorAction Stop

# Move the downloaded file to the installation directory
Write-Host "Installing kubelogin to $installPath"
Move-Item -Path $tempKubeloginPath -Destination $kubeloginExePath -Force

# Validate the installation directory
if (-Not (Test-Path $kubeloginExePath)) {
    throw "kubelogin installation failed. The required binary file is missing in the installation directory."
}

# Update the PATH environment variable for kubelogin
Write-Host "Updating PATH environment variable for kubelogin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$installPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", [System.EnvironmentVariableTarget]::Machine)
}

# Verify kubelogin installation
Write-Host "Verifying kubelogin installation..."
try {
    $kubeloginVersionOutput = & "$kubeloginExePath" --version
    Write-Host "kubelogin installed successfully: $kubeloginVersionOutput"
} catch {
    throw "Failed to verify kubelogin installation. Error: $_"
}

Write-Host "kubelogin installation completed successfully."


-----------------------------------

# Dynamically fetch the kubelogin version from the manifest
$kubeloginVersion = v0.1.4
$url = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/kubelogin/$kubeloginVersion/windows/kubelogin.exe"

# Define the installation path and installation file path
$installPath = "C:\Program Files\kubelogin"
$kubeloginExePath = "$installPath\kubelogin.exe"
$tempKubeloginPath = "$env:TEMP\kubelogin.exe"

# Create installation directory if it doesn't exist
if (-Not (Test-Path $installPath)) {
    Write-Host "Creating installation directory: $installPath"
    New-Item -Path $installPath -ItemType Directory -Force
}

# Download the kubelogin executable using Invoke-WebRequest
Write-Host "Downloading kubelogin version $kubeloginVersion from $url"
Invoke-WebRequest -Uri $url -OutFile $tempKubeloginPath -ErrorAction Stop

# Move the downloaded file to the installation directory
Write-Host "Installing kubelogin to $installPath"
Move-Item -Path $tempKubeloginPath -Destination $kubeloginExePath -Force

# Validate the installation directory
if (-Not (Test-Path $kubeloginExePath)) {
    throw "kubelogin installation failed. The required binary file is missing in the installation directory."
}

# Update the PATH environment variable for kubelogin
Write-Host "Updating PATH environment variable for kubelogin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$installPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", [System.EnvironmentVariableTarget]::Machine)
}

# Verify kubelogin installation
Write-Host "Verifying kubelogin installation..."
try {
    $kubeloginVersionOutput = & "$kubeloginExePath" --version
    Write-Host "kubelogin installed successfully: $kubeloginVersionOutput"
} catch {
    throw "Failed to verify kubelogin installation. Error: $_"
}

Write-Host "kubelogin installation completed successfully."
#---------------

Describe "kubelogin" {
    $kubeloginToolManifest = Get-ManifestTool -Name "kubelogin"

    $targetVersion = "v$($kubeloginToolManifest.defaultVersion)"
    $kubeloginPath = "C:\Program Files\kubelogin\kubelogin.exe"

    Context "kubelogin installation" {
        It "kubelogin executable should exist in $kubeloginPath" {
            Test-Path $kubeloginPath | Should -Be $true
        }
    }

    Context "kubelogin version" {
        It "kubelogin version should match manifest version $($kubeloginToolManifest.defaultVersion)" -TestCases $targetVersion {
            $versionOutput = (cmd /c "kubelogin --version")
            $versionMatch = $versionOutput -match "v([\d\.]+)/"

            if ($versionMatch) {
                $extractedVersion = "v" + $matches[1]
                $extractedVersion | Should -Be $targetVersion
            } else {
                throw "Failed to extract kubelogin version. Output: $versionOutput"
            }
        }
    }

    Context "kubelogin functionality" {
        It "kubelogin should return a valid help message" {
            $helpOutput = (cmd /c "kubelogin --help")
            $helpOutput | Should -Match "Usage: kubelogin"
        }

        It "kubelogin should execute successfully with exit code 0" {
            $process = Start-Process -FilePath $kubeloginPath -ArgumentList "--help" -NoNewWindow -PassThru -Wait
            $process.ExitCode | Should -Be 0
        }
    }

    Context "kubelogin environment variables" {
        It "KUBECONFIG should be set if present" {
            if ($env:KUBECONFIG) {
                $env:KUBECONFIG | Should -Not -BeNullOrEmpty
                Write-Host "KUBECONFIG is set to: $env:KUBECONFIG"
            } else {
                Write-Host "KUBECONFIG is not set, skipping test."
            }
        }

        It "KUBECTL_CACHE_DIR should be set if present" {
            if ($env:KUBECTL_CACHE_DIR) {
                $env:KUBECTL_CACHE_DIR | Should -Not -BeNullOrEmpty
                Write-Host "KUBECTL_CACHE_DIR is set to: $env:KUBECTL_CACHE_DIR"
            } else {
                Write-Host "KUBECTL_CACHE_DIR is not set, skipping test."
            }
        }
    }
}

# Run Pester test
Invoke-Pester C:\image\tests\kubelogin.Tests.ps1
