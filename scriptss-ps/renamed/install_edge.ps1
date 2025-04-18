$edgeInstallerUrl = "https://msedgesetup.azureedge.net/latest/MicrosoftEdgeEnterpriseX64.msi"
$installerPath = "$env:TEMP\MicrosoftEdgeEnterpriseX64.msi"

if (-not (Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")) {
    Write-Host "Downloading Edge..."
    Invoke-WebRequest -Uri $edgeInstallerUrl -OutFile $installerPath
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$installerPath`" /quiet /norestart"
    Remove-Item $installerPath -Force
}

$edgeExePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$edgeVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($edgeExePath).ProductVersion
$majorVersion = $edgeVersion.Split('.')[0]

$driverPath = "C:\SeleniumWebDrivers\EdgeDriver"
New-Item -Path $driverPath -ItemType Directory -Force | Out-Null

$latestDriverVersion = Invoke-RestMethod "https://msedgedriver.azureedge.net/LATEST_RELEASE_$majorVersion"
$driverUrl = "https://msedgedriver.azureedge.net/$latestDriverVersion/edgedriver_win64.zip"
$driverZip = "$env:TEMP\edgedriver.zip"

Write-Host "Downloading WebDriver v$latestDriverVersion..."
Invoke-WebRequest -Uri $driverUrl -OutFile $driverZip
Expand-Archive -Path $driverZip -DestinationPath $driverPath -Force
Remove-Item $driverZip -Force

Write-Host "Configuring system environment variables..."
$env:Path += ";$driverPath"
[Environment]::SetEnvironmentVariable("Path", "$($env:Path);$driverPath", "Machine")
[Environment]::SetEnvironmentVariable("EdgeWebDriver", $driverPath, "Machine")

if (-not (Get-Module -Name Selenium -ListAvailable)) {
    Install-Module -Name Selenium -Force -Scope CurrentUser
}

Import-Module Selenium
$edgeOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
$edgeService = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateDefaultService($driverPath)
$driver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeService, $edgeOptions)

Write-Host "Success! Edge version: $edgeVersion"
Write-Host "WebDriver path: $driverPath\msedgedriver.exe"

$driver.Navigate().GoToUrl("https://www.google.com")
Start-Sleep -Seconds 3
$driver.Quit()
