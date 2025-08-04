using Azure.Provisioning.AppContainers;

var builder = DistributedApplication.CreateBuilder(args);

var redis = builder.AddRedis("redis")
    .WithImageTag("8.0.3")
    .WithRedisInsight(resourceBuilder => resourceBuilder.WithHostPort(5540).WithDataVolume("test-redis-insight"))
    .WithDataVolume("test-redis-data")
    .WithPersistence(TimeSpan.FromSeconds(1))
    .PublishAsAzureContainerApp(configure: (infrastructure, app) =>
    {
        app.Template.Scale.MaxReplicas = 1;
    });
    
var apiService = builder.AddProject<Projects.TestRedisPassword_ApiService>("apiservice")
    .WithHttpHealthCheck("/health");

builder.AddProject<Projects.TestRedisPassword_Web>("webfrontend")
    .WithExternalHttpEndpoints()
    .WithHttpHealthCheck("/health")
    .WithReference(apiService)
    .WithReference(redis)
    .WaitFor(apiService);

builder.AddAzureContainerAppEnvironment("test-redis-pwd");

builder.Build().Run();
