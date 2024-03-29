# Azure Cosmos security

Security features for Cosmos DB.

## Setup

Set up the variables:

```sh
cp config/template.tfvars .auto.tfvars
```

Set your IP address in `cosmos_ip_range_filter`.

Create the resources:

```sh
terraform init
terraform apply -auto-approve
```

Use the Go SDK client in the `/client` directory to send data to Cosmos.

Create the `.env` file:

```sh
COSMOS_ENDPOINT="https://<COSMOS NAME>.documents.azure.com:443/"
```

Run the client:

```sh
go get
go run .
```

For data operations there are only two [built-in role definitions][1]:

- `Cosmos DB Built-in Data Reader`
- `Cosmos DB Built-in Data Contributor`

## Monitor

Since Diagnostics has been enabled, troubleshooting can be performed using Azure Monitor.

This query will filter for data plane requests in the `AzureDiagnostics` table. With Entra ID authentication it is possible to audit users that access data in Cosmos DB accounts.

> 💡 For this scenario, local authentication should be disabled and users would have to use Entra ID

```sql
AzureDiagnostics
| where Category == "DataPlaneRequests" and TimeGenerated > ago(1h)
| project TimeGenerated, aadPrincipalId_g, Resource, OperationName, requestResourceId_s, statusCode_s, clientIpAddress_s, authTokenType_s, keyType_s
```

## Security (other)

The database will created with CMK:

<img src=".assets/cosmos-cmk.png" />

Log collection is enabled:

<img src=".assets/cosmos-logs.png" />

Network IP filtering:

<img src=".assets/cosmos-vnet.png" />

---

### Destroy

When done, clean up the resources:

```sh
terraform destroy -auto-approve
```

[1]: https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions
