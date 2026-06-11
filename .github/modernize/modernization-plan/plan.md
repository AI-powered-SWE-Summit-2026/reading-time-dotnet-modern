# Modernization Plan: ReadingTimeDemo Azure Migration

**Project**: ReadingTimeDemo

---

## Technical Framework

- **Language**: C# / .NET Core 2.0 (netcoreapp2.0)
- **Framework**: ASP.NET Core 2.0 MVC
- **Build Tool**: MSBuild
- **Database**: None (in-memory data)
- **Key Dependencies**: Microsoft.AspNetCore.Mvc 2.0, Microsoft.ApplicationInsights.AspNetCore 2.2, Microsoft.AspNetCore.StaticFiles 2.0

---

## Overview

This migration upgrades the ReadingTimeDemo ASP.NET Core 2.0 MVC application to .NET 10 LTS and migrates it to Azure cloud-native services. The application currently runs on an end-of-life framework (netcoreapp2.0), uses local application configuration files, and serves static content from the container filesystem. The new architecture will:

- Run on .NET 10 LTS, eliminating the EOL framework risk and all associated NuGet incompatibilities
- Externalize non-secret application settings into Azure App Configuration for centralized, environment-agnostic configuration management
- Serve static web content from Azure Blob Storage, removing reliance on the local container filesystem
- Be containerized and deployed to Azure Container Apps for scalable, cloud-native hosting

The migration follows a phased approach: first upgrade the runtime, then migrate individual Azure services, and finally deploy to Azure Container Apps.

---

## Migration Impact Summary

| Application       | Original Service         | New Azure Service             | Authentication   | Comments                              |
|-------------------|--------------------------|-------------------------------|-----------------|---------------------------------------|
| ReadingTimeDemo   | Local appsettings.json   | Azure App Configuration       | Managed Identity | Non-secret settings externalized      |
| ReadingTimeDemo   | Local wwwroot (static)   | Azure Blob Storage            | Managed Identity | Static assets served from blob        |
| ReadingTimeDemo   | Local hosting            | Azure Container Apps          | Managed Identity | Containerized deployment              |

---

## Open Questions & Questionnaire

- [x] Q: Should the plan include environment/infrastructure provisioning? → A: No — focus on code migration only
- [x] Q: Which Azure deployment target should the plan use? → A: Azure Container Apps
- [x] Q: Should the plan include a security scan and CVE remediation task? → A: No — skip security/CVE remediation
