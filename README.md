# Enterprise Azure Zero-Trust Container Mesh (Hub & Spoke)

An enterprise-grade, secure, and fully automated Hub-and-Spoke network topology deployed on Microsoft Azure using Terraform. This architecture isolates serverless application workloads entirely from the public internet using private virtual network injection, bi-directional VNet peering, and private container registries.

---

## 🗺️ Architectural Topology

```text
==========================================================================================
                                  AZURE LOGICAL NETWORK MAP
==========================================================================================

    [ HUB MANAGEMENT REGION ]                             [ SPOKE WORKLOAD REGION ]
   Resource Group: rg-mesh-hub                          Resource Group: rg-mesh-spoke
 ┌──────────────────────────────┐                      ┌────────────────────────────────┐
 │ VNet: vnet-prod-hub          │                      │ VNet: vnet-prod-spoke          │
 │ Address: 10.0.0.0/16         │                      │ Address: 10.1.0.0/16           │
 │                              │                      │                                │
 │  ┌────────────────────────┐  │                      │  ┌──────────────────────────┐  │
 │  │ AzureBastionSubnet     │  │  ◄─────────────────►  │  │ Subnet: snet-prod-aca    │  │
 │  │ 10.0.1.0/24            │  │   Bi-Directional     │  │ 10.1.0.0/23              │  │
 │  └────────────────────────┘  │     VNet Peering     │  │ (Service Delegated)      │  │
 │                              │   (Private Routes)   │  └────────────┬─────────────┘  │
 │  ┌────────────────────────┐  │                      │               │                │
 │  │ snet-prod-jumpbox      │  │                      │   ┌───────────▼────────────┐   │
 │  │ 10.0.2.0/24            │  │                      │   │ Azure Container Apps   │   │
 │  └────────────────────────┘  │                      │   │ Managed Environment    │   │
 └──────────────────────────────┘                      │   │ (cae-prod-secure)      │   │
                                                       │   │ Ingress: INTERNAL ONLY │   │
                                                       │   └───────────▲────────────┘   │
                                                       └───────────────┼────────────────┘
                                                                       │ Secure Image Pull
                                                       ┌───────────────┴────────────────┐
                                                       │ Azure Container Registry (ACR) │
                                                       │ Name: la2026mesh.azurecr.io    │
                                                       └────────────────────────────────┘
==========================================================================================
```
## 🚀 Key Engineering Highlights

* **Zero-Trust Network Isolation:** Built using an explicit `external_enabled = false` ingress schema. The serverless application runtime is nested deeply inside a delegated infrastructure subnet (`10.1.0.0/23`), completely severed from public internet routing paths.

* **DevOps Bootstrap Pattern Integration:** Engineered a modular deployment timeline to resolve implicit cloud dependencies. Leveraged targeted core apply states alongside decoupled Azure Container Registry (ACR) Tasks (`az acr build`) using public staging layers (`ghcr.io`) to safely circumvent unauthenticated registry throttling.

* **Serverless Cost-Optimization Matrix:** Programmed runtime target parameters (`min_replicas = 0`) enabling application underlying containers to scale completely down to zero instances during zero-traffic idle gaps. Eliminates unnecessary compute expenditures.

* **Unified State Infrastructure as Code:** Managed completely via Terraform declarations across dynamic variable schemas, abstracting regional resource group definitions for instantaneous replication across data center geographic zones.

## 📁 Repository Blueprint

```text
.
├── app/
│   ├── index.html        # Custom application presentation layer
│   └── Dockerfile        # Non-privileged NGINX multi-stage container build
├── main.tf               # Core Hub/Spoke virtual network & peering infrastructure
├── compute.tf            # Azure Container Apps environment & Log Analytics workspace
├── registry.tf           # Private secure Azure Container Registry definition
├── app.tf                # Private container workload & runtime configuration
├── variables.tf          # Universal parameter variables
└── .gitignore            # Active secret & state deployment blocker mask

```

## 📊 Live Verification Outputs

The successful execution logs direct from the Terraform state orchestration engines confirm complete infrastructure convergence:

```text
Terraform Apply Success: Resources: 10 added, 0 changed, 0 destroyed.
```
### Deployed Resource Attributes:

```yaml
Deployment Location:       eastus
Private Registry Endpoint: la2026mesh.azurecr.io
Isolated Target App URL:   app-prod-secure--36bz5qt.internal.victoriousisland-44b5bf8b.eastus.azurecontainerapps.io


```
---
## 🛠️ Infrastructure Lifecycle Automation

This repository leverages the **DevOps Bootstrap Pattern** to dynamically resolve implicit cloud deployment dependencies during initial provision sequences.

### 1. Initialize and Bootstrap the Private Core
Initialize the Terraform backend providers and isolate the private Container Registry layer first:
```powershell
terraform init
terraform apply -target="azurerm_container_registry.acr" -auto-approve
```
### 2. Remote Container Workload Compilation
Inject the application layer source packages directly into the cloud registry using managed Azure Container Registry (ACR) Tasks:
```
az acr build --registry la2026mesh --image cloudapp:v1 ./app
```

### 3. Converge the Architecture Mesh
Execute a full state convergence to deploy the core networks, service subnet delegations, bi-directional peerings, and private container environments:
```
terraform apply -auto-approve
```

### 4. Complete Environment Destruction
To safely wipe all active cloud allocations and eliminate ongoing platform resource costs:
```
terraform destroy -auto-approve
```
