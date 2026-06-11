# Projects and dependencies analysis

This document provides a comprehensive overview of the projects and their dependencies in the context of upgrading to .NETCoreApp,Version=v10.0.

## Table of Contents

- [Executive Summary](#executive-Summary)
  - [Highlevel Metrics](#highlevel-metrics)
  - [Projects Compatibility](#projects-compatibility)
  - [Package Compatibility](#package-compatibility)
  - [API Compatibility](#api-compatibility)
  - [Binding Redirect Configuration](#binding-redirect-configuration)
- [Aggregate NuGet packages details](#aggregate-nuget-packages-details)
- [Top API Migration Challenges](#top-api-migration-challenges)
  - [Technologies and Features](#technologies-and-features)
  - [Most Frequent API Issues](#most-frequent-api-issues)
- [Projects Relationship Graph](#projects-relationship-graph)
- [Project Details](#project-details)

  - [src/ReadingTimeDemo/ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj)
  - [test/ReadingTimeDemo.UnitTests/ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj)


## Executive Summary

### Highlevel Metrics

| Metric | Count | Status |
| :--- | :---: | :--- |
| Total Projects | 2 | All require upgrade |
| Total NuGet Packages | 22 | 9 need upgrade |
| Total Code Files | 15 |  |
| Total Code Files with Incidents | 4 |  |
| Total Lines of Code | 608 |  |
| Total Number of Issues | 38 |  |
| Estimated LOC to modify | 8+ | at least 1.3% of codebase |

### Projects Compatibility

| Project | Target Framework | Difficulty | Package Issues | API Issues | Binding Issues | Est. LOC Impact | Description |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| [src/ReadingTimeDemo/ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | netcoreapp2.0 | 🟢 Low | 24 | 8 | 0 | 8+ | AspNetCore, Sdk Style = True |
| [test/ReadingTimeDemo.UnitTests/ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | netcoreapp2.0 | 🟢 Low | 4 | 0 | 0 |  | DotNetCoreApp, Sdk Style = True |

### Package Compatibility

| Status | Count | Percentage |
| :--- | :---: | :---: |
| ✅ Compatible | 13 | 59.1% |
| ⚠️ Incompatible | 3 | 13.6% |
| 🔄 Upgrade Recommended | 6 | 27.3% |
| ***Total NuGet Packages*** | ***22*** | ***100%*** |

### API Compatibility

| Category | Count | Impact |
| :--- | :---: | :--- |
| 🔴 Binary Incompatible | 0 | High - Require code changes |
| 🟡 Source Incompatible | 7 | Medium - Needs re-compilation and potential conflicting API error fixing |
| 🔵 Behavioral change | 1 | Low - Behavioral changes that may require testing at runtime |
| ✅ Compatible | 347 |  |
| ***Total APIs Analyzed*** | ***355*** |  |

## Aggregate NuGet packages details

| Package | Current Version | Suggested Version | Projects | Description |
| :--- | :---: | :---: | :--- | :--- |
| coverlet.msbuild | 2.0.1 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ✅Compatible |
| Microsoft.ApplicationInsights.AspNetCore | 2.2.1 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj)<br/>[ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ⚠️NuGet package is deprecated |
| Microsoft.AspNetCore.Diagnostics | 2.0.2 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package functionality is included with framework reference |
| Microsoft.AspNetCore.Mvc | 2.0.3 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package functionality is included with framework reference |
| Microsoft.AspNetCore.Server.IISIntegration | 2.0.2 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package functionality is included with framework reference |
| Microsoft.AspNetCore.Server.Kestrel | 2.0.2 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package functionality is included with framework reference |
| Microsoft.AspNetCore.StaticFiles | 2.0.2 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package functionality is included with framework reference |
| Microsoft.Extensions.Configuration.EnvironmentVariables | 2.0.1 | 10.0.9 | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package upgrade is recommended |
| Microsoft.Extensions.Configuration.Json | 2.0.1 | 10.0.9 | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package upgrade is recommended |
| Microsoft.Extensions.Logging | 2.0.1 | 10.0.9 | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package upgrade is recommended |
| Microsoft.Extensions.Logging.Console | 2.0.1 | 10.0.9 | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package upgrade is recommended |
| Microsoft.Extensions.Logging.Debug | 2.0.1 | 10.0.9 | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package upgrade is recommended |
| Microsoft.Extensions.Options.ConfigurationExtensions | 2.0.1 | 10.0.9 | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package upgrade is recommended |
| Microsoft.NET.Test.Sdk | 15.7.0 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ✅Compatible |
| Microsoft.NETCore.App | 2.0 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj)<br/>[ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ✅Compatible |
| Microsoft.VisualStudio.Web.BrowserLink | 2.0.2 |  | [ReadingTimeDemo.csproj](#srcreadingtimedemoreadingtimedemocsproj) | NuGet package functionality is included with framework reference |
| MSTest.TestAdapter | 1.2.0 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ✅Compatible |
| MSTest.TestFramework | 1.2.0 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ✅Compatible |
| System.Runtime.Serialization.Primitives | 4.3.0 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | NuGet package functionality is included with framework reference |
| xunit | 2.3.1 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ⚠️NuGet package is deprecated |
| xunit.runner.console | 2.3.1 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ⚠️NuGet package is deprecated |
| xunit.runner.visualstudio | 2.3.1 |  | [ReadingTimeDemo.UnitTests.csproj](#testreadingtimedemounittestsreadingtimedemounittestscsproj) | ✅Compatible |

## Top API Migration Challenges

### Technologies and Features

| Technology | Issues | Percentage | Migration Path |
| :--- | :---: | :---: | :--- |

### Most Frequent API Issues

| API | Count | Percentage | Category |
| :--- | :---: | :---: | :--- |
| T:Microsoft.AspNetCore.Hosting.IHostingEnvironment | 3 | 37.5% | Source Incompatible |
| M:Microsoft.AspNetCore.Builder.ExceptionHandlerExtensions.UseExceptionHandler(Microsoft.AspNetCore.Builder.IApplicationBuilder,System.String) | 1 | 12.5% | Behavioral Change |
| M:Microsoft.Extensions.Logging.DebugLoggerFactoryExtensions.AddDebug(Microsoft.Extensions.Logging.ILoggerFactory) | 1 | 12.5% | Source Incompatible |
| M:Microsoft.Extensions.Logging.ConsoleLoggerExtensions.AddConsole(Microsoft.Extensions.Logging.ILoggerFactory,Microsoft.Extensions.Configuration.IConfiguration) | 1 | 12.5% | Source Incompatible |
| T:Microsoft.AspNetCore.Hosting.WebHostBuilder | 1 | 12.5% | Source Incompatible |
| T:Microsoft.AspNetCore.Hosting.IWebHost | 1 | 12.5% | Source Incompatible |

## Projects Relationship Graph

Legend:
📦 SDK-style project
⚙️ Classic project

```mermaid
flowchart LR
    P2 --> P1

```

## Project Details

