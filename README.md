# Azure Cosmos security

Security features for Cosmos DB.

Set up the variables:

```sh
cp config/template.tfvars .auto.tfvars
```

Create the resources:

```sh
terraform init
terraform apply -auto-approve
```

The database will created with CMK:

<img src=".assets/cosmos-cmk.png" />

Log collection is enabled:

<img src=".assets/cosmos-logs.png" />

---

### Destroy

```sh
terraform destroy -auto-approve
```
