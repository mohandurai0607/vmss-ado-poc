# Fetch Venafi tool details from the manifest
$venafiTool = Get-ManifestTool -Name "Venafi"
$venafiVersion = $venafiTool.defaultVersion
$installArgs = $($venafiTool.installArgs, "/DIR=$($venafiTool.installPath)")

# Validate source is artifactory
if ($venafiTool.source -ne "artifactory") {
    throw "Unable to install Venafi. The specified source, '$($venafiTool.source)', is not supported."
}

# Validate the tool exists in the manifest
if ($null -eq $venafiTool) {
    throw "Failed to get the tool 'Venafi' from the manifest file. Verify the tool exists in the manifest or check the logs for additional error messages."
}

$venafiUrl = "https://prod.artifactory.nfcu.net:443/artifactory/cicd-generic-release-local/venafi/$venafiVersion/windows/Venafi-$venafiVersion.zip"

# Set installation path and ZIP file location
$venafiPath = $venafiTool.installPath
$venafiArchive = "$venafiPath\Venafi-$venafiVersion.zip"

# Check if Venafi is already installed
if (Test-Path $venafiPath) {
    Write-Host "Venafi version $venafiVersion is already installed at $venafiPath. No action will be taken."
    return
}

# Create installation directory if it does not exist
if (-Not (Test-Path $venafiPath)) {
    Write-Host "Creating Venafi directory: $venafiPath"
    New-Item -Path $venafiPath -ItemType Directory
}

# Download Venafi ZIP
Write-Host "Downloading Venafi version $venafiVersion from $venafiUrl"
Install-Binary `
    -Url $venafiUrl `
    -Type zip `
    -Destination $venafiArchive `
    -InstallArgs $installArgs
    -ErrorAction Stop

# Extract the ZIP file to the installation directory
Write-Host "Extracting Venafi ZIP to $venafiPath"
Expand-Archive -Path $venafiArchive -DestinationPath $venafiPath -Force
Remove-Item $venafiArchive

# Verify Venafi installation
Write-Host "Verifying Venafi installation..."
if (Test-Path "$venafiPath\bin") {
    Write-Host "Venafi installation completed successfully at $venafiPath."
} else {
    Write-Error "Venafi installation failed. Directory not found: $venafiPath\bin"
    exit 1
}

# Optional: Run Venafi tests
$venafiTestsPath = "C:\image\tests\Venafi.Tests.ps1"
if (Test-Path $venafiTestsPath) {
    Write-Host "Running Venafi tests from $venafiTestsPath"
    Invoke-Pester $venafiTestsPath
} else {
    Write-Host "Test file not found: $venafiTestsPath. Skipping tests."
}
