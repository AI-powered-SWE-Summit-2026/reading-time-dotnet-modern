# Task 002 – Migrate appsettings to Azure App Configuration

## Summary

This task migrates the ReadingTimeDemo application to read its configuration from **Azure App Configuration** using the SDK provider, authenticated via **Managed Identity** (`DefaultAzureCredential`). The `IConfiguration` / `IOptions<T>` shape is fully preserved so all consuming code continues to work without changes.

## Changes Made

### `src/ReadingTimeDemo/ReadingTimeDemo.csproj`
- Added `Microsoft.Extensions.Configuration.AzureAppConfiguration` (v8.5.0) — the core SDK provider.
- Added `Microsoft.Azure.AppConfiguration.AspNetCore` (v8.5.0) — provides the `UseAzureAppConfiguration()` middleware.
- Added `Azure.Identity` (v1.21.0) — provides `DefaultAzureCredential` for Managed Identity auth.
- Updated `Microsoft.Extensions.Azure` from 1.10.0 → 1.14.0 to resolve a transitive version-downgrade conflict with the App Configuration packages.

### `src/ReadingTimeDemo/Program.cs`
- Added `using Microsoft.Extensions.Configuration;` (explicit — implicit usings are not enabled in this project).
- Added `using Microsoft.Azure.AppConfiguration.AspNetCore;` for the refresh middleware.
- Wired Azure App Configuration as an additional configuration source, **conditionally**, when `AZURE_APP_CONFIGURATION_ENDPOINT` is set:

```csharp
var appConfigEndpoint = System.Environment.GetEnvironmentVariable("AZURE_APP_CONFIGURATION_ENDPOINT");
if (!string.IsNullOrEmpty(appConfigEndpoint))
{
    builder.Configuration.AddAzureAppConfiguration(options =>
    {
        options.Connect(new System.Uri(appConfigEndpoint), new DefaultAzureCredential());
    });
    builder.Services.AddAzureAppConfiguration();
}
```

- Registered `UseAzureAppConfiguration()` middleware conditionally in the pipeline.
- When `AZURE_APP_CONFIGURATION_ENDPOINT` is not set the app continues to run using `appsettings.json` and environment variables as fallback sources (local dev / unit-test friendly).

### `.azure/configuration-migration.json` (new)
Emitted the seed file for the deployment agent:

```json
{
  "keyValues": [],
  "featureFlags": []
}
```

**`keyValues` is intentionally empty** — the only non-`Logging` setting present in `appsettings.json` is `ApplicationInsights.InstrumentationKey` (empty string). Per the migration skill guidance, anything that looks like an **API key** (including InstrumentationKey) must be excluded; secrets belong in Key Vault. The `Logging` section is a runtime-host concern and is always kept in `appsettings.json`.

## Skipped / Excluded Settings

| Key | Reason skipped |
|-----|----------------|
| `ApplicationInsights:InstrumentationKey` | Identified as an API key — excluded per skill guidance |
| `Logging:*` | Runtime-host concern — always kept in `appsettings.json` |

## Consistency & Correctness

- **IConfiguration / IOptions\<T\> shape**: unchanged — no call-site modifications required.
- **Managed Identity**: `DefaultAzureCredential` is used; no connection strings or secrets are committed.
- **AZURE_APP_CONFIGURATION_ENDPOINT**: consumed exclusively from the environment variable, never placed in `appsettings.json`.
- **Environment variables fallback**: remain active as a lower-priority configuration source (ASP.NET Core default ordering preserved).
- **Conditional activation**: the App Configuration provider is only registered when the endpoint env var is present, so local development and unit tests work without the service.

## Build & Test Results

- **Build**: ✅ 0 errors, 0 warnings
- **Unit tests**: ✅ 14/14 passed
