################################################################################
##  File:  Install-Chrome.ps1
##  Desc:  Install Google Chrome, block auto-update, and allow Selenium Manager URLs
################################################################################

# Install Google Chrome
Install-Binary `
    -Url 'https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi' `
    -ExpectedSignature '607A3EDAA64933E94422FC8F0C80388E0590986C'

# Block Google update service via firewall
Write-Host "Blocking Google update service via firewall..."
New-NetFirewallRule -DisplayName "BlockGoogleUpdate" -Direction Outbound -Action Block `
    -Program "C:\\Program Files (x86)\\Google\\Update\\GoogleUpdate.exe" -Enabled True

# Stop and disable update services
$googleServices = Get-Service -Name "GoogleUpdater*" -ErrorAction SilentlyContinue
if ($googleServices) {
    Stop-Service $googleServices
    $googleServices.WaitForStatus('Stopped', "00:01:00")
    $googleServices | Set-Service -StartupType Disabled
}

# Disable Chrome auto-updates in registry
$regGoogleUpdatePath = "HKLM:\\SOFTWARE\\Policies\\Google\\Update"
$regGoogleUpdateChrome = "HKLM:\\SOFTWARE\\Policies\\Google\\Chrome"
($regGoogleUpdatePath, $regGoogleUpdateChrome) | ForEach-Object {
    New-Item -Path $_ -Force
}

$regGoogleParameters = @(
    @{ Name = "AutoUpdateCheckPeriodMinutes"; Value = 0 },
    @{ Name = "UpdateDefault"; Value = 0 },
    @{ Name = "DisableAutoUpdateChecksCheckboxValue"; Value = 1 },
    @{ Name = "Update{{8A69D345-D564-463C-AFF1-A69D9E530F96}}"; Value = 0 },
    @{ Path = $regGoogleUpdateChrome; Name = "DefaultBrowserSettingEnabled"; Value = 0 }
)

foreach ($param in $regGoogleParameters) {
    if ($param.Path) {
        New-ItemProperty -Path $param.Path -Name $param.Name -Value $param.Value -PropertyType DWord -Force
    } else {
        New-ItemProperty -Path $regGoogleUpdatePath -Name $param.Name -Value $param.Value -PropertyType DWord -Force
    }
}

################################################################################
# Allow Selenium Manager WebDriver Access
################################################################################

Write-Host "Allowing outbound access to Chrome and Edge WebDriver endpoints..."

# Allow ChromeDriver JSON
New-NetFirewallRule -DisplayName "Allow_ChromeDriver_JSON" -Direction Outbound -Action Allow `
    -RemoteAddress "0.0.0.0/0" -RemotePort 443 -Protocol TCP `
    -Description "Allow ChromeDriver metadata access"

# Allow EdgeDriver version check
New-NetFirewallRule -DisplayName "Allow_EdgeDriver_Latest" -Direction Outbound -Action Allow `
    -RemoteAddress "0.0.0.0/0" -RemotePort 443 -Protocol TCP `
    -Description "Allow EdgeDriver version metadata access"

################################################################################
# Verification Section
################################################################################

Write-Host "Verifying firewall rules..."

# Verify allow rule for Chrome
$allowChrome = Get-NetFirewallRule -DisplayName "Allow_ChromeDriver_JSON" -ErrorAction SilentlyContinue
if ($allowChrome -and $allowChrome.Enabled -eq "True") {
    Write-Host "Allow rule for ChromeDriver is enabled."
} else {
    Write-Warning "Allow rule for ChromeDriver not found or not enabled."
}

# Verify allow rule for Edge
$allowEdge = Get-NetFirewallRule -DisplayName "Allow_EdgeDriver_Latest" -ErrorAction SilentlyContinue
if ($allowEdge -and $allowEdge.Enabled -eq "True") {
    Write-Host "Allow rule for EdgeDriver is enabled."
} else {
    Write-Warning "Allow rule for EdgeDriver not found or not enabled."
}
