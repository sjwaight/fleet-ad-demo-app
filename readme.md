# FMAD Demo

This repository contains the code and instructions to deploy a demo of the FMAD feature.

It contains two main components:

- A Bicep template to deploy the Azure resources required for the demo.
- A simple Python Flask web application that will be containerized and deployed to Fleet member clusters.

## Deploying Azure resources

### Prerequisites

- Check there is [sufficient vCPU quota](https://learn.microsoft.com/azure/virtual-machines/quotas?tabs=cli) in the regions you intend to use. This demo uses a single Subscription, but Fleet Manager can manage clusters in multiple subscriptions and regions as long as the subscriptions are linked to the same Entra ID tenant.

- The Bicep deployment is targeted at the Azure Subscription level so the user running the deployment must have permissions to create resource groups in addition to AKS clusters and Azure Kubernetes Fleet Manager resources.

- The deployment creates an Entra ID role assignment, so the user running the deployment must have sufficient permissions to assign roles.

- Azure Kubernetes Fleet Manager requires your user to hold the `Azure Kubernetes Fleet Manager RBAC Cluster Admin` role in order to interact with the Fleet Manager hub cluster.

Deployment takes ~ 30 minutes depending on the number of clusters you are deploying. If you hit an error your can fix it and then re-run the deployment command. The Bicep deployment will only create resources that do not already exist.

### Steps

1. Modify the `infra/main.bicepparam` file, setting details on VM sizes, number of member clusters (recommendation is minimum of 2), and the Azure region where the resources will be deployed. You can use non-production VM sizes for this demo.

1. Run the following command to deploy the Azure resources:

   ```bash
   az deployment sub create \
    --name fleetmgr-$(date -I) \
    --location <fleet-location> \
    --subscription <demo-sub-id> \
    --template-file main.bicep \
    --parameters main.bicepparam
   ```

Troubleshooting:

1. If during deployment you receive ERROR CODE: VMSizeNotSupported - select a different VM size and update `vmsize` in the `infra/main.bicepparam` file. This is applied to all clusters including the Fleet Manager hub cluster.
1. If you re-run the deployment you may receive an error due to attempting to re-create the role assignment for the AKS clusters to use AcrPull on the Container Registry. These can safely be ignored. Once deployed you can validate access to the Container Registry and AKS clusters using the Azure CLI command `az aks check-acr` ([see docs](https://learn.microsoft.com/cli/azure/aks?view=azure-cli-latest#az-aks-check-acr)). Note there may be a delay before the role assignment is applied.

## Outputs

The result of the Bicep deployment is:

- An Azure Kubernetes Fleet Manager with hub cluster.
- An Azure Container Registry.
- Three AKS clusters joined as members (if you don't modify the number of clusters). Each cluster is assigned a Fleet Manager Update Group and is granted with `AcrPull` access to the Container Registry.
- A Fleet Manager [Update Strategy](https://learn.microsoft.com/azure/kubernetes-fleet/update-create-update-strategy?tabs=azure-portal) and [Auto-upgrade profile](https://learn.microsoft.com/azure/kubernetes-fleet/concepts-update-orchestration#understanding-auto-upgrade-profiles) for the member clusters which ensures they will be updated when new Kubernetes versions are available.
