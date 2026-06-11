# Modernization Summary: 003-transform-static-content-to-azure-blob

## Task Description
Migrate static web content (images, CSS, JavaScript) from the local `wwwroot` directory to Azure Blob Storage, and update the application to serve these assets from blob storage using Managed Identity (DefaultAzureCredential) for authentication.

## Changes Made

### New Files
| File | Description |
|------|-------------|
| `src/ReadingTimeDemo/Services/IBlobStorageService.cs` | Interface defining `GetStaticAssetUrl(string assetPath)` for generating blob storage asset URLs |
| `src/ReadingTimeDemo/Services/BlobStorageService.cs` | Singleton implementation backed by `BlobServiceClient` (authenticated via `DefaultAzureCredential`). Reads container name from `Storage:StaticAssetsContainerName` config key. |

### Modified Files

#### `src/ReadingTimeDemo/ReadingTimeDemo.csproj`
Added NuGet packages:
- `Azure.Storage.Blobs` 12.28.0 — data-plane SDK for blob storage URL generation
- `Azure.Identity` 1.21.0 — `DefaultAzureCredential` for Managed Identity authentication
- `Microsoft.Extensions.Azure` 1.14.0 — `AddAzureClients` DI integration
- `Microsoft.Azure.AppConfiguration.AspNetCore` 8.5.0 — ASP.NET Core middleware for Azure App Configuration (from task 002; fixed compilation errors)
- `Microsoft.Extensions.Configuration.AzureAppConfiguration` 8.5.0 — configuration provider (from task 002; upgraded to resolve package conflict)

#### `src/ReadingTimeDemo/Program.cs`
- Added `using Microsoft.Azure.AppConfiguration.AspNetCore;` and `using Microsoft.Extensions.Configuration;` (missing namespaces that were causing pre-existing build failures from task 002)
- Fixed Azure App Configuration registration: changed from `builder.Configuration.AddAzureAppConfiguration(...)` to `builder.Host.ConfigureAppConfiguration(config => config.AddAzureAppConfiguration(...))` to use `IConfigurationBuilder` explicitly and avoid namespace resolution issues
- Added `AddAzureClients` registration with `AddBlobServiceClient` reading from `Storage` configuration section and `UseCredential(new DefaultAzureCredential())`
- Registered `IBlobStorageService` as Singleton: `builder.Services.AddSingleton<IBlobStorageService, BlobStorageService>()`
- `BlobServiceClient` is registered as **Singleton** via `AddAzureClients` (per Rule 26: Azure SDK clients must be Singleton to avoid per-request AAD token acquisition overhead)

#### `src/ReadingTimeDemo/appsettings.json`
Added `Storage` configuration section:
```json
"Storage": {
  "ServiceUri": "https://{YOUR_STORAGE_ACCOUNT_NAME}.blob.core.windows.net",
  "StaticAssetsContainerName": "static-assets"
}
```

#### `src/ReadingTimeDemo/Views/Book/Index.cshtml`
- Added `@inject ReadingTimeDemo.Services.IBlobStorageService BlobStorageService`
- Replaced `src="~/images/covers/@item.Cover"` → `src="@BlobStorageService.GetStaticAssetUrl("images/covers/" + item.Cover)"`

#### `src/ReadingTimeDemo/Views/Home/Index.cshtml`
- Added `@inject ReadingTimeDemo.Services.IBlobStorageService BlobStorageService`
- Replaced all 4 banner image references (`~/images/banner1-4.svg`) with `@BlobStorageService.GetStaticAssetUrl("images/banner1-4.svg")`

#### `src/ReadingTimeDemo/Views/Shared/_Layout.cshtml`
- Added `@inject ReadingTimeDemo.Services.IBlobStorageService BlobStorageService` at top
- Replaced `~/css/site.css` and `~/css/site.min.css` with blob storage URLs
- Replaced `~/js/site.js` and `~/js/site.min.js` with blob storage URLs
- Replaced `/images/octocat.png` and `/images/heart.png` with blob storage URLs
- Removed `asp-append-version="true"` from blob storage asset references (the ASP.NET Core tag helper cannot hash remote URLs; cache invalidation should be managed at CDN/blob level)
- Vendor libraries (Bootstrap, jQuery) intentionally remain served from local `wwwroot` in Development and from external CDN in Staging/Production — they do not require blob storage hosting
- Added a Razor comment block documenting the mixed delivery strategy and cache invalidation rationale

## Architecture

```
Application (ASP.NET Core MVC)
    │
    ├── IBlobStorageService (Singleton)
    │       └── BlobStorageService
    │               └── BlobServiceClient (Singleton, via AddAzureClients)
    │                       └── DefaultAzureCredential (Managed Identity)
    │                               └── Azure Blob Storage
    │                                       └── static-assets container
    │                                               ├── images/covers/*.jpg
    │                                               ├── images/banner*.svg
    │                                               ├── images/octocat.png
    │                                               ├── images/heart.png
    │                                               ├── css/site.css
    │                                               ├── css/site.min.css
    │                                               ├── js/site.js
    │                                               └── js/site.min.js
    │
    └── wwwroot (local) — vendor libs only
            ├── lib/bootstrap/
            └── lib/jquery/
```

## Deployment Notes
Before deploying to Azure, the following steps are required:
1. Create an Azure Storage Account and a blob container named `static-assets` (or configure `Storage:StaticAssetsContainerName` with the actual name)
2. Upload all static assets from `wwwroot/` (images, CSS, JS) to the container, preserving directory structure
3. Set `Storage:ServiceUri` to `https://{actual-account-name}.blob.core.windows.net`
4. Assign the `Storage Blob Data Reader` RBAC role to the application's Managed Identity on the storage account
5. For public web serving, either enable public blob-level read on the container, or generate SAS URLs for private containers (see migration skill Rule 8)

## Build and Test Results
- ✅ Build: Succeeded (0 errors, 0 warnings)
- ✅ Unit Tests: 14/14 passed
