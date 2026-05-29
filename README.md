# Azure Bicep Modular Deployment

A modular Azure Bicep template that deploys an **App Service** (plan + app) and a **Storage Account**, with environment-aware configuration and parameter validation decorators.

## Project Structure

```
.
├── main.bicep
└── modules/
    └── appService.bicep
```

## Resources Deployed

| Resource | Type |
|---|---|
| App Service Plan | `Microsoft.Web/serverfarms` |
| App Service App | `Microsoft.Web/sites` |
| Storage Account | `Microsoft.Storage/storageAccounts` |

## Parameters

### main.bicep

| Parameter | Type | Default | Description |
|---|---|---|---|
| `environmentType` | string | `dev` | Environment name. Allowed: `dev`, `test`, `prod` |
| `solutionName` | string | `toyhr<unique>` | Unique solution name (5–30 chars) |
| `appServicePlanInstanceCount` | int | `1` | Number of App Service plan instances (1–10) |
| `appServicePlanSku` | object | `F1 / Free` | App Service plan SKU name and tier |
| `location` | string | `eastus` | Azure region |
| `storageAccountName` | string | `toyhr<unique>` | Storage account name |

## Environment Behaviour

| Environment | App Service SKU | Storage SKU |
|---|---|---|
| `dev` / `test` | `F1` (Free) | `Standard_LRS` |
| `prod` | `P2v3` | `Standard_GRS` |

## Outputs

| Output | Description |
|---|---|
| `webAppHostName` | Default hostname of the deployed App Service app |

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) or [Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps)
- An Azure subscription and resource group
- [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

## Deployment

### Azure CLI

```bash
az login

az deployment group create \
  --name main \
  --resource-group <your-resource-group> \
  --template-file main.bicep
```

### Azure PowerShell

```powershell
Connect-AzAccount

New-AzResourceGroupDeployment `
  -Name main `
  -ResourceGroupName <your-resource-group> `
  -TemplateFile main.bicep
```

### Override parameters at deploy time

```bash
az deployment group create \
  --name main \
  --resource-group <your-resource-group> \
  --template-file main.bicep \
  --parameters environmentType=prod
```

## Key Concepts Demonstrated

- **Modular structure** — App Service resources are isolated in a reusable child module
- **Parameter decorators** — `@description`, `@allowed`, `@minLength`, `@maxLength`, `@minValue`, `@maxValue`
- **Environment-based conditionals** — SKU selection via ternary expressions
- **Output chaining** — module output surfaced through main template
- **Naming conventions** — resource names composed from environment + solution name

## Notes

- Azure hostnames do not support underscores (`_`) — use hyphens (`-`) in all resource name variables
- Storage account `kind: 'StorageV2'` is required by the ARM API
- `uniqueString(resourceGroup().id)` ensures globally unique resource names per resource group