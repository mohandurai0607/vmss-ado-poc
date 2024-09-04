param imageGalleryName string = 'devsecopsdevimagegallery01'
param resourceGroupName string = 'test'
param subnetName string = 'CICD-DEV-EUS-VMSS-BUILD-AGENT-SUBNET'
param virtualNetworkName string = 'CICD-DEV-EUS-VNET'
param deploymentTimestamp string = utcNow()

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' existing = {
  name: resourceGroupName
  scope: subscription()
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: virtualNetworkName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'CICD-DEV-IMAGE-BUILDER-ID'
  location: 'Central India'
}

resource managedIdentityRoleAssignmentResourceGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(az.resourceGroup().id, 'contributor-resource-group')
  properties: {
    description: 'Allows Azure Image Builder pipeline to create and modify resources in resource group'
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor
  }
  scope: az.resourceGroup()
}

resource managedIdentityRoleAssignmentNetwork 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(az.resourceGroup().id, 'contributor-network')
  properties: {
    description: 'Allows Azure Image Builder pipeline to connect resources to the VNet'
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor
  }
  scope: vnet
}

resource managedIdentityRoleAssignmentGallery 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(az.resourceGroup().id, 'contributor-gallery')
  properties: {
    description: 'Allows Azure Image Builder pipeline to read the image gallery resources'
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor role
  }
  scope: imageGallery
}

resource imageGallery 'Microsoft.Compute/galleries@2023-07-03' existing = {
  name: imageGalleryName
}

resource image 'Microsoft.Compute/galleries/images@2023-07-03' = {
  name: 'windows-ado-agent'
  location: 'Central India'
  parent: imageGallery
  properties: {
    identifier: {
      sku: '2016-ado-agent'
      offer: 'Windows'
      publisher: 'NFCU'
    }
    hyperVGeneration: 'V2'
    osState: 'Generalized'
    osType: 'Windows'
  }
}

// resource azureImageBuilder 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
//   name: 'CICD-DEV-EUS-VMSS-BUILD-AGENT-${deploymentTimestamp}'
//   location: 'Central India'
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${managedIdentity.id}': {}
//     }
//   }
//   properties: {
//     buildTimeoutInMinutes: 60
//     distribute: [
//       {
//         type: 'SharedImage'
//         galleryImageId: image.id
//         replicationRegions: ['East US']
//         runOutputName: 'windows-vmss-image'
//         storageAccountType: 'Standard_LRS'
//       }
//     ]
//     customize: [
//       {
//         type: 'PowerShell'
//         name: 'InstallNodeJsAndGit'
//         inline: [
//           'Set-ExecutionPolicy Bypass -Scope Process -Force;'
//           '[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;'
//           'iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))'
//           'choco install nodejs -y'
//           'choco install git -y'
//         ]
//       }
//     ]
//     source: {
//       type: 'PlatformImage'
//       offer: 'WindowsServer'
//       publisher: 'MicrosoftWindowsServer'
//       sku: '2016-datacenter-gensecond'
//       version: 'latest'
//     }
//     vmProfile: {
//       vmSize: 'Standard_D2s_v3'
//       osDiskSizeGB: 512
//       vnetConfig: {
//         subnetId: '/subscriptions/3e08e0d6-3d8b-4136-9991-f325b219d169/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/CICD-DEV-EUS-VNET/subnets/CICD-DEV-EUS-VMSS-BUILD-AGENT-SUBNET'
//       }
//     }
//   }
// }
resource azureImageBuilder 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: 'CICD-DEV-EUS-VMSS-BUILD-AGENT-${deploymentTimestamp}'
  location: 'Central India'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 60
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: image.id
        replicationRegions: ['East US']
        runOutputName: 'windows-vmss-image'
        storageAccountType: 'Standard_LRS'
      }
    ]
    customize: [
      {
        type: 'PowerShell'
        name: 'InstallPackagesFromGitHub'
        inline: [
          '$ErrorActionPreference = "Stop";'
          'Write-Host "Downloading install script from GitHub...";'
          'Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mohan0607/adovmss-sysprep/main/install.ps1" -OutFile "C:\\temp\\install.ps1"'
          'Write-Host "Running install script...";'
          'Set-ExecutionPolicy Bypass -Scope Process -Force;'
          'C:\\temp\\install.ps1'
          'if ($LASTEXITCODE -ne 0) { throw "Script execution failed with exit code $LASTEXITCODE"; }'
        ]
      }
    ]
    source: {
      type: 'PlatformImage'
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      sku: '2016-datacenter-gensecond'
      version: 'latest'
    }
    vmProfile: {
      vmSize: 'Standard_D2s_v3'
      osDiskSizeGB: 512
      vnetConfig: {
        subnetId: '/subscriptions/3e08e0d6-3d8b-4136-9991-f325b219d169/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/CICD-DEV-EUS-VNET/subnets/CICD-DEV-EUS-VMSS-BUILD-AGENT-SUBNET'
      }
    }
  }
}
