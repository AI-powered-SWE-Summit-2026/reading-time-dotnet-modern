using Azure.Identity;
using Microsoft.AspNetCore.Builder;
using Microsoft.Azure.AppConfiguration.AspNetCore;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using ReadingTimeDemo.Services;

var builder = WebApplication.CreateBuilder(args);

var appConfigEndpoint = System.Environment.GetEnvironmentVariable("AZURE_APP_CONFIGURATION_ENDPOINT");
if (!string.IsNullOrEmpty(appConfigEndpoint))
{
    builder.Configuration.AddAzureAppConfiguration(options =>
    {
        options.Connect(new System.Uri(appConfigEndpoint), new DefaultAzureCredential());
    });
    builder.Services.AddAzureAppConfiguration();
}

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddApplicationInsightsTelemetry();

// Register Azure Blob Storage client authenticated with DefaultAzureCredential (Managed Identity).
// BlobServiceClient is registered as Singleton (Rule 26: Azure SDK clients must be Singleton).
builder.Services.AddAzureClients(clientBuilder =>
{
    clientBuilder.AddBlobServiceClient(builder.Configuration.GetSection("Storage"));
    clientBuilder.UseCredential(new DefaultAzureCredential());
});
builder.Services.AddSingleton<IBlobStorageService, BlobStorageService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Home/Error");
}

if (!string.IsNullOrEmpty(appConfigEndpoint))
{
    app.UseAzureAppConfiguration();
}

app.UseStaticFiles();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Book}/{action=Index}/{id?}");

app.Run();
