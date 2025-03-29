# =========================================
# Install pip from JFrog Artifactory
# =========================================

# Define JFrog details
$JFROG_URL = "https://your-jfrog-instance/artifactory/python-local/get-pip.py"
$LOCAL_PIP_PATH = "C:\Temp\get-pip.py"

# Ensure C:\Temp exists
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" | Out-Null
}

# Download get-pip.py from JFrog
Write-Host "Downloading get-pip.py from JFrog..."
Invoke-WebRequest -Uri $JFROG_URL -OutFile $LOCAL_PIP_PATH

# Verify if the file was downloaded
if (!(Test-Path -Path $LOCAL_PIP_PATH)) {
    Write-Host "Error: get-pip.py not found. Check JFrog URL and network access."
    exit 1
}

Write-Host "Successfully downloaded get-pip.py."

# Run get-pip.py to install pip
Write-Host "Installing pip..."
python $LOCAL_PIP_PATH

# Verify pip installation
Write-Host "Verifying pip installation..."
$PipCheck = python -m pip --version
if ($PipCheck) {
    Write-Host "pip installed successfully: $PipCheck"
} else {
    Write-Host "Error: pip installation failed!"
}




# =========================================
# Ensure the script runs with Administrator privileges
# =========================================
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "This script must be run as Administrator. Restarting with elevated privileges..."
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting pip repository configuration for all users..."

# =========================================
# Ensure TLS 1.2 is Enabled
# =========================================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# =========================================
# Configure pip Repository (Unregister PyPI & Register Artifactory)
# =========================================
$pipConfigDir = "C:\ProgramData\pip"
$pipConfigPath = "$pipConfigDir\pip.ini"
$RepoSource = "https://prod.artifactory.nfcu.net/artifactory/api/pypi/pypi/simple"

# Ensure the pip.ini directory exists
if (-Not (Test-Path $pipConfigDir)) {
    New-Item -ItemType Directory -Path $pipConfigDir | Out-Null
}

Write-Host "Configuring pip to use Artifactory and remove PyPI..."

# Write the new pip.ini configuration
@"
[global]
index-url = $RepoSource
no-index = true

[install]
trusted-host = prod.artifactory.nfcu.net
"@ | Set-Content -Path $pipConfigPath -Force

Write-Host "pip repository configuration updated at $pipConfigPath"

# =========================================
# Verify pip Configuration
# =========================================
Write-Host "Verifying pip configuration..."
$ConfigCheck = pip config list
Write-Host "Current pip configuration:"
Write-Host $ConfigCheck

Write-Host "pip repository setup completed successfully."


----------------

# ==============================
# Pester Validation for pip Configuration
# ==============================

BeforeAll {
    $pipConfigPath = "C:\ProgramData\pip\pip.ini"
    $testPackage = "requests"
}

Describe "pip Installation and Configuration Validation" {

    Context "pip Configuration File Validation" {
        It "pip.ini should exist in the expected directory" {
            Test-Path $pipConfigPath | Should -Be $true
        }
    }

    Context "pip Executable Validation" {
        It "pip should be installed and accessible" {
            $pipVersionOutput = & pip --version
            $pipVersionOutput | Should -Not -BeNullOrEmpty
        }
    }

    Context "pip Package Installation Validation" {
        It "pip should install the test package from Artifactory" {
            $installOutput = & pip install $testPackage --no-cache-dir
            $installOutput | Should -Match "Successfully installed"
        }
    }
}
#-------------------- - new one- 

Write-Host "Starting pip repository configuration for all users..."

# =========================================
# Ensure TLS 1.2 is Enabled
# =========================================
Write-Host "Ensuring TLS1.2 is configured for use..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# =========================================
# Configure pip Repository (Unregister PyPI & Register Artifactory)
# =========================================
$pipConfigDir = "C:\ProgramData\pip"
$pipConfigPath = "$pipConfigDir\pip.ini"
$RepoSource = "https://prod.artifactory.nfcu.net/artifactory/api/pypi/pypi/simple"

# Ensure the pip.ini directory exists
if (-Not (Test-Path $pipConfigDir)) {
    New-Item -ItemType Directory -Path $pipConfigDir | Out-Null
}

Write-Host "Configuring pip to use Artifactory and remove PyPI..."

# Write the new pip.ini configuration
@"
[global]
index-url = $RepoSource
no-index = true

[install]
trusted-host = prod.artifactory.nfcu.net
"@ | Set-Content -Path $pipConfigPath -Force

Write-Host "pip repository configuration updated at $pipConfigPath"
Write-Host "pip repository setup completed successfully."

Invoke-Pester C:\image\tests\PipConfig.Tests.ps1

#--- test file

Describe "pip Configuration Validation" {
    
    Context "Pip Configuration" {
        It "Should contain Artifactory in pip sources" {
            $config = pip config get global.index-url
            $config | Should -Match "artifactory"
        }

        It "Should not list PyPI as a source" {
            $config = pip config get global.index-url
            $config | Should -Not -Match "pypi.org"
        }
    }
}

