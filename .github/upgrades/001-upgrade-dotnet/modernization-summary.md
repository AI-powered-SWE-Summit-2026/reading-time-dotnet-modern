# Modernization Summary: 001-upgrade-dotnet

## Task
Upgrade ReadingTimeDemo from `netcoreapp2.0` to `net10.0` (LTS), adopting the modern minimal hosting model and removing obsolete/framework-included NuGet packages.

## Changes Made

### 1. `src/ReadingTimeDemo/ReadingTimeDemo.csproj`
- Changed `TargetFramework` from `netcoreapp2.0` → `net10.0`
- Removed obsolete properties: `ProjectGuid`, `PreserveCompilationContext`, `OutputType`, `RuntimeFrameworkVersion`
- Removed all NuGet packages now included in the ASP.NET Core framework reference:
  - `Microsoft.AspNetCore.Diagnostics`
  - `Microsoft.AspNetCore.Mvc`
  - `Microsoft.AspNetCore.Server.IISIntegration`
  - `Microsoft.AspNetCore.Server.Kestrel`
  - `Microsoft.AspNetCore.StaticFiles`
  - `Microsoft.Extensions.Configuration.EnvironmentVariables`
  - `Microsoft.Extensions.Configuration.Json`
  - `Microsoft.Extensions.Logging`
  - `Microsoft.Extensions.Logging.Console`
  - `Microsoft.Extensions.Logging.Debug`
  - `Microsoft.Extensions.Options.ConfigurationExtensions`
- Removed deprecated package: `Microsoft.VisualStudio.Web.BrowserLink`
- Removed legacy `DotNetCliToolReference` for `BundlerMinifier.Core`
- Updated `Microsoft.ApplicationInsights.AspNetCore` from `2.2.1` → `2.22.0`

### 2. `src/ReadingTimeDemo/Program.cs`
- Replaced legacy `WebHostBuilder` pattern with the modern **minimal hosting model** (`WebApplication.CreateBuilder`)
- Removed manual `Directory.GetCurrentDirectory()` / `UseContentRoot` (handled automatically by the framework)
- Removed `UseKestrel()` / `UseIISIntegration()` (handled automatically)
- Removed `UseStartup<Startup>()` (startup logic merged inline)
- Replaced deprecated `UseMvc(routes => ...)` with `MapControllerRoute(...)`
- Replaced `services.AddMvc()` with `services.AddControllersWithViews()`
- Replaced `loggerFactory.AddConsole/AddDebug` (deprecated pattern) with host-builder defaults
- Replaced `app.AddApplicationInsightsSettings(developerMode)` with `builder.Services.AddApplicationInsightsTelemetry()`
- Removed `app.UseBrowserLink()` (deprecated)

### 3. `src/ReadingTimeDemo/Startup.cs`
- **Deleted** — all configuration merged into `Program.cs` (minimal hosting model)

### 4. `test/ReadingTimeDemo.UnitTests/ReadingTimeDemo.UnitTests.csproj`
- Changed `TargetFramework` from `netcoreapp2.0` → `net10.0`
- Removed obsolete properties: `ProjectGuid`, `GenerateRuntimeConfigurationFiles`, `RuntimeFrameworkVersion`
- Removed unnecessary packages:
  - `Microsoft.ApplicationInsights.AspNetCore` (not needed in test project)
  - `System.Runtime.Serialization.Primitives` (included in framework)
  - `MSTest.TestAdapter` / `MSTest.TestFramework` (tests use xunit, not MSTest)
  - `xunit.runner.console` (not needed with `dotnet test`)
- Updated packages to current versions:
  - `Microsoft.NET.Test.Sdk`: `15.7.0` → `17.12.0`
  - `xunit`: `2.3.1` → `2.9.3`
  - `xunit.runner.visualstudio`: `2.3.1` → `3.0.0`
  - `coverlet.msbuild`: `2.0.1` → `6.0.2`

## Build & Test Results
- ✅ Build: **succeeded** — 0 errors, 0 warnings
- ✅ Tests: **14/14 passed** (0 failed, 0 skipped)
