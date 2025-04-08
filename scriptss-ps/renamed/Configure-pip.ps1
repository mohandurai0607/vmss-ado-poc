
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

$globalPipPath = "C:\ProgramData\pip\pip.ini"

Describe "pip.ini Configuration Validation (Global)" {

    Context "Global pip.ini File Check" {
        It "Should exist at $globalPipPath" {
            Test-Path $globalPipPath | Should -BeTrue
        }
    }

    Context "Artifactory Configuration Check" {
        $content = Get-Content $globalPipPath -Raw

        It "Should contain index-url pointing to Artifactory" {
            $content | Should -Match "index-url\s*=\s*https:\/\/.*artifactory"
        }

        It "Should contain trusted-host for Artifactory" {
            $content | Should -Match "trusted-host\s*=\s*prod\.artifactory\.nfcu\.net"
        }

        It "Should NOT contain pypi.org" {
            $content | Should -Not -Match "pypi\.org"
        }
    }
}

