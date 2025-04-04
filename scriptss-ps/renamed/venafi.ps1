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

# Create installation directory if it does not exist
if (-Not (Test-Path $venafiPath)) {
    Write-Host "Creating Venafi directory: $venafiPath"
    New-Item -Path $venafiPath -ItemType Directory
}

# Download Venafi ZIP
Write-Host "Downloading Venafi version $venafiVersion from $venafiUrl"
Invoke-WebRequest -Uri $venafiUrl -OutFile $venafiArchive

# Extract the ZIP file to the installation directory
Write-Host "Extracting Venafi ZIP to $venafiPath"
Expand-Archive -Path $venafiArchive -DestinationPath $venafiPath -Force
Remove-Item $venafiArchive

# # Verify Venafi installation
# Write-Host "Verifying Venafi installation..."
# $venafiBinary = "$venafiPath\bin\venafi.exe"  # Adjust based on the actual binary name
# if (Test-Path $venafiBinary) {
#     try {
#         $installedVersion = & $venafiBinary --version  # Replace with the actual version command
#         Write-Host "Venafi installed successfully. Version: $installedVersion"
#     } catch {
#         Write-Error "Failed to verify Venafi version. Error: $_"
#     }
# } else {
#     Write-Error "Venafi installation failed. Binary not found: $venafiBinary"
#     exit 1
# }

# Update the PATH environment variable
Write-Host "Updating PATH environment variable to include Venafi binary directory"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*$venafiPath\bin*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$venafiPath\bin", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "PATH updated to include: $venafiPath\bin"
} else {
    Write-Host "PATH already includes: $venafiPath\bin"
}
