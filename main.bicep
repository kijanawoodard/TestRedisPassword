targetScope = 'subscription'

param resourceGroupName string

param location string

param principalId string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module test_redis_pwd 'test-redis-pwd/test-redis-pwd.bicep' = {
  name: 'test-redis-pwd'
  scope: rg
  params: {
    location: location
    userPrincipalId: principalId
  }
}

output test_redis_pwd_AZURE_CONTAINER_REGISTRY_NAME string = test_redis_pwd.outputs.AZURE_CONTAINER_REGISTRY_NAME

output test_redis_pwd_AZURE_CONTAINER_REGISTRY_ENDPOINT string = test_redis_pwd.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT

output test_redis_pwd_AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID string = test_redis_pwd.outputs.AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID

output test_redis_pwd_AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN string = test_redis_pwd.outputs.AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN

output test_redis_pwd_AZURE_CONTAINER_APPS_ENVIRONMENT_ID string = test_redis_pwd.outputs.AZURE_CONTAINER_APPS_ENVIRONMENT_ID

output test_redis_pwd_volumes_redis_0 string = test_redis_pwd.outputs.volumes_redis_0