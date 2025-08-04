@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param test_redis_pwd_outputs_azure_container_apps_environment_default_domain string

param test_redis_pwd_outputs_azure_container_apps_environment_id string

@secure()
param redis_password_value string

param test_redis_pwd_outputs_volumes_redis_0 string

resource redis 'Microsoft.App/containerApps@2025-01-01' = {
  name: 'redis'
  location: location
  properties: {
    configuration: {
      secrets: [
        {
          name: 'redis-password'
          value: redis_password_value
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 6379
        transport: 'tcp'
      }
    }
    environmentId: test_redis_pwd_outputs_azure_container_apps_environment_id
    template: {
      containers: [
        {
          image: 'docker.io/library/redis:8.0.3'
          name: 'redis'
          command: [
            '/bin/sh'
          ]
          args: [
            '-c'
            'redis-server --requirepass \$REDIS_PASSWORD --save 1 1'
          ]
          env: [
            {
              name: 'REDIS_PASSWORD'
              secretRef: 'redis-password'
            }
          ]
          volumeMounts: [
            {
              volumeName: 'v0'
              mountPath: '/data'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      volumes: [
        {
          name: 'v0'
          storageType: 'AzureFile'
          storageName: test_redis_pwd_outputs_volumes_redis_0
        }
      ]
    }
  }
}