
$sqlServerTool = Get-ManifestTool -Name "SqlServer"
if ($null -eq $sqlServerTool) {
    throw "Failed to get the tool 'SqlServer' from the manifest. Verify it exists or check the logs."
}

if ($sqlServerTool.source -ne "artifactory") {
    throw "Unable to install SqlServer. The specified source, '$($sqlServerTool.source)', is not supported."
}

$SqlServerModuleVersion = $sqlServerTool.defaultVersion
Write-Host "Using SqlServer module version: $SqlServerModuleVersion"

$moduleUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/pwsh/Windows/sqlserver.$SqlServerModuleVersion.nupkg"
Write-Host "Module download URL: $moduleUrl"

$nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not $nuget) {
    Write-Host "NuGet provider is not installed. Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force -Confirm:$false
} else {
    Write-Host "NuGet provider is already installed."
}

$installedModules = Get-Module -ListAvailable -Name SqlServer
if ($installedModules) {
    Write-Host "Uninstalling existing SqlServer module versions..."
    foreach ($mod in $installedModules) {
        Uninstall-Module -Name SqlServer -AllVersions -Force -Confirm:$false
    }
}

$tempFile = Join-Path $env:TEMP "sqlserver.$SqlServerModuleVersion.nupkg"
Write-Host "Downloading SqlServer module package..."
Invoke-WebRequest -Uri $moduleUrl -OutFile $tempFile -UseBasicParsing

$moduleTargetPath = "C:\Program Files\WindowsPowerShell\Modules\SqlServer\$SqlServerModuleVersion"
if (-not (Test-Path $moduleTargetPath)) {
    Write-Host "Creating module folder at: $moduleTargetPath"
    New-Item -ItemType Directory -Path $moduleTargetPath -Force | Out-Null
}

$zipFile = "$tempFile.zip"
Rename-Item -Path $tempFile -NewName $zipFile -Force
Write-Host "Extracting module package..."
Expand-Archive -Path $zipFile -DestinationPath $moduleTargetPath -Force

Remove-Item $zipFile -Force

Write-Host "Importing the SqlServer module..."
Import-Module SqlServer -Force

if (Get-Module -ListAvailable -Name SqlServer | Where-Object { $_.Version -eq $SqlServerModuleVersion }) {
    Write-Host "SqlServer module version $SqlServerModuleVersion installed successfully."
} else {
    Write-Host "Failed to install the SqlServer module. Please check for errors."
}

if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
    Write-Host "`nInvoke-Sqlcmd is now available for use."
} else {
    Write-Host "`nInvoke-Sqlcmd is still not recognized. Try restarting PowerShell and re-running the script."
}

------------------ to test 

$SqlServerModuleVersion = "21.1.18235"
Write-Host "Using SqlServer module version: $SqlServerModuleVersion"

$moduleUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/pwsh/Windows/sqlserver.$SqlServerModuleVersion.nupkg"
Write-Host "Module download URL: $moduleUrl"

$nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not $nuget) {
    Write-Host "NuGet provider is not installed. Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force -Confirm:$false
} else {
    Write-Host "NuGet provider is already installed."
}

$installedModules = Get-Module -ListAvailable -Name SqlServer
if ($installedModules) {
    Write-Host "Uninstalling existing SqlServer module versions..."
    foreach ($mod in $installedModules) {
        Uninstall-Module -Name SqlServer -AllVersions -Force -Confirm:$false
    }
}

$tempFile = Join-Path $env:TEMP "sqlserver.$SqlServerModuleVersion.nupkg"
Write-Host "Downloading SqlServer module package..."
Invoke-WebRequest -Uri $moduleUrl -OutFile $tempFile -UseBasicParsing

$moduleTargetPath = "C:\Program Files\WindowsPowerShell\Modules\SqlServer\$SqlServerModuleVersion"
if (-not (Test-Path $moduleTargetPath)) {
    Write-Host "Creating module folder at: $moduleTargetPath"
    New-Item -ItemType Directory -Path $moduleTargetPath -Force | Out-Null
}

$zipFile = "$tempFile.zip"
Rename-Item -Path $tempFile -NewName $zipFile -Force
Write-Host "Extracting module package..."
Expand-Archive -Path $zipFile -DestinationPath $moduleTargetPath -Force

Remove-Item $zipFile -Force

Write-Host "Importing the SqlServer module..."
Import-Module SqlServer -Force

if (Get-Module -ListAvailable -Name SqlServer | Where-Object { $_.Version -eq $SqlServerModuleVersion }) {
    Write-Host "SqlServer module version $SqlServerModuleVersion installed successfully."
} else {
    Write-Host "Failed to install the SqlServer module. Please check for errors."
}

if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
    Write-Host "`nInvoke-Sqlcmd is now available for use."
} else {
    Write-Host "`nInvoke-Sqlcmd is still not recognized. Try restarting PowerShell and re-running the script."
}

