################################################################################
##  File:   Install-Edge.ps1
##  Desc:   Install Microsoft Edge browser and Edge WebDriver
################################################################################

# Download and install latest Microsoft Edge Stable (Enterprise Offline Installer)
Install-Binary `
    -Url 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/3ec8a11b-d9d4-4685-84e6-1b9a9f3ae6ad/MicrosoftEdgeEnterpriseX64.msi'

# Block Edge update services
Write-Host "Blocking Microsoft Edge auto-update..."
$regEdgeUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
New-Item -Path $regEdgeUpdatePath -Force

$regEdgeParams = @(
    @{ Name = "AutoUpdateCheckPeriodMinutes"; Value = 0 },
    @{ Name = "UpdateDefault"; Value = 0 },
    @{ Name = "DisableAutoUpdateChecksCheckboxValue"; Value = 1 }
)

$regEdgeParams | ForEach-Object {
    New-ItemProperty -Path $regEdgeUpdatePath -Name $_.Name -Value $_.Value -PropertyType DWord -Force
}

# Install Edge WebDriver
Write-Host "Installing Edge WebDriver..."
$edgeDriverPath = "$($env:SystemDrive)\SeleniumWebDrivers\EdgeDriver"
if (-not (Test-Path -Path $edgeDriverPath)) {
    New-Item -Path $edgeDriverPath -ItemType Directory -Force
}

# Get local Edge version
$edgeExePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edgeExePath)) {
    $edgeExePath = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
}

[version]$edgeVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($edgeExePath).ProductVersion
$edgeVersionString = "$($edgeVersion.Major).$($edgeVersion.Minor).$($edgeVersion.Build).$($edgeVersion.Revision)"
$edgeMajorVersion = $edgeVersion.Major

Write-Host "Detected Microsoft Edge version: $edgeVersionString"

# Build Edge WebDriver URL
$edgeDriverDownloadUrl = "https://msedgedriver.azureedge.net/$edgeVersionString/edgedriver_win64.zip"

Write-Host "Downloading Edge WebDriver from $edgeDriverDownloadUrl..."
$edgeDriverZipPath = Invoke-DownloadWithRetry $edgeDriverDownloadUrl

Write-Host "Extracting Edge WebDriver..."
Expand-7ZipArchive -Path $edgeDriverZipPath -DestinationPath $edgeDriverPath -ExtractMethod "e"

# Set environment variable
Write-Host "Setting EdgeWebDriver environment variable..."
[Environment]::SetEnvironmentVariable("EdgeWebDriver", $edgeDriverPath, "Machine")
