@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param userPrincipalId string

param tags object = { }

resource test_redis_pwd_mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: take('test_redis_pwd_mi-${uniqueString(resourceGroup().id)}', 128)
  location: location
  tags: tags
}

resource test_redis_pwd_acr 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: take('testredispwdacr${uniqueString(resourceGroup().id)}', 50)
  location: location
  sku: {
    name: 'Basic'
  }
  tags: tags
}

resource test_redis_pwd_acr_test_redis_pwd_mi_AcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(test_redis_pwd_acr.id, test_redis_pwd_mi.id, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d'))
  properties: {
    principalId: test_redis_pwd_mi.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalType: 'ServicePrincipal'
  }
  scope: test_redis_pwd_acr
}

resource test_redis_pwd_law 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: take('testredispwdlaw-${uniqueString(resourceGroup().id)}', 63)
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
  tags: tags
}

resource test_redis_pwd 'Microsoft.App/managedEnvironments@2025-01-01' = {
  name: take('testredispwd${uniqueString(resourceGroup().id)}', 24)
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: test_redis_pwd_law.properties.customerId
        sharedKey: test_redis_pwd_law.listKeys().primarySharedKey
      }
    }
    workloadProfiles: [
      {
        name: 'consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
  tags: tags
}

resource aspireDashboard 'Microsoft.App/managedEnvironments/dotNetComponents@2024-10-02-preview' = {
  name: 'aspire-dashboard'
  properties: {
    componentType: 'AspireDashboard'
  }
  parent: test_redis_pwd
}

resource test_redis_pwd_storageVolume 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: take('testredispwdstoragevolume${uniqueString(resourceGroup().id)}', 24)
  kind: 'StorageV2'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    largeFileSharesState: 'Enabled'
  }
  tags: tags
}

resource storageVolumeFileService 'Microsoft.Storage/storageAccounts/fileServices@2024-01-01' = {
  name: 'default'
  parent: test_redis_pwd_storageVolume
}

resource shares_volumes_redis_0 'Microsoft.Storage/storageAccounts/fileServices/shares@2024-01-01' = {
  name: take('sharesvolumesredis0-${uniqueString(resourceGroup().id)}', 63)
  properties: {
    enabledProtocols: 'SMB'
    shareQuota: 1024
  }
  parent: storageVolumeFileService
}

resource managedStorage_volumes_redis_0 'Microsoft.App/managedEnvironments/storages@2025-01-01' = {
  name: take('managedstoragevolumesredis${uniqueString(resourceGroup().id)}', 24)
  properties: {
    azureFile: {
      accountName: test_redis_pwd_storageVolume.name
      accountKey: test_redis_pwd_storageVolume.listKeys().keys[0].value
      accessMode: 'ReadWrite'
      shareName: shares_volumes_redis_0.name
    }
  }
  parent: test_redis_pwd
}

output volumes_redis_0 string = managedStorage_volumes_redis_0.name

output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = test_redis_pwd_law.name

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = test_redis_pwd_law.id

output AZURE_CONTAINER_REGISTRY_NAME string = test_redis_pwd_acr.name

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = test_redis_pwd_acr.properties.loginServer

output AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID string = test_redis_pwd_mi.id

output AZURE_CONTAINER_APPS_ENVIRONMENT_NAME string = test_redis_pwd.name

output AZURE_CONTAINER_APPS_ENVIRONMENT_ID string = test_redis_pwd.id

output AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN string = test_redis_pwd.properties.defaultDomain