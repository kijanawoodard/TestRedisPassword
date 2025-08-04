@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param test_redis_pwd_outputs_azure_container_apps_environment_default_domain string

param test_redis_pwd_outputs_azure_container_apps_environment_id string

param test_redis_pwd_outputs_azure_container_registry_endpoint string

param test_redis_pwd_outputs_azure_container_registry_managed_identity_id string

param apiservice_containerimage string

param apiservice_containerport string

resource apiservice 'Microsoft.App/containerApps@2025-02-02-preview' = {
  name: 'apiservice'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: int(apiservice_containerport)
        transport: 'http'
      }
      registries: [
        {
          server: test_redis_pwd_outputs_azure_container_registry_endpoint
          identity: test_redis_pwd_outputs_azure_container_registry_managed_identity_id
        }
      ]
      runtime: {
        dotnet: {
          autoConfigureDataProtection: true
        }
      }
    }
    environmentId: test_redis_pwd_outputs_azure_container_apps_environment_id
    template: {
      containers: [
        {
          image: apiservice_containerimage
          name: 'apiservice'
          env: [
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EXCEPTION_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EVENT_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_RETRY'
              value: 'in_memory'
            }
            {
              name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED'
              value: 'true'
            }
            {
              name: 'HTTP_PORTS'
              value: apiservice_containerport
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${test_redis_pwd_outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}