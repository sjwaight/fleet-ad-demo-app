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

## Prepare Fleet Manager hub cluster

Using the Azure CLI and `kubectl` we add a new namespace to the Fleet Manager hub cluster which will be used to stage our demo application resources.

### Steps

1. Connect to the Fleet Manager hub cluster:

   ```bash
   az fleet get-credentials \
    --name <fleet-name> \
    --resource-group <fleet-rg>
   ```

1. Once the credentials are downloaded, you can use `kubectl` to connect to the hub cluster.

   ```bash
   kubectl create namespace fmad-demo
   ```

Troubleshooting:

1. If you receive a Forbidden error when attempting to create the namespace, check you have the `Azure Kubernetes Fleet Manager RBAC Cluster Admin` role assigned to your user. You may need to wait a few minutes for the role assignment to propagate before you can create the namespace.

## Use FMAG to stage application on Fleet Manager hub cluster

Next we will use FMAD to build and stage the demo application on the Fleet Manager hub cluster. For this demo you can following the official Microsoft Learn tutorial.

Once the application is staged you can confirm that the assets have been created.

- Dockerfile and .dockerignore files are created in the ./src directory.
- Kubernetes manifests are created in the ./src/manifests directory.

On the Fleet Manager hub cluster you can see the following resources created in the `fmad-demo` namespace:

- A Deployment for the demo application (`kubectl get deployments -n fmad-demo`). Pending status is expected as the application is not yet deployed to the member clusters and cannot be scheduled on the hub cluster.

```output
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
fm-ad-app-01   0/1     0            0           5m15s
```
 
- A LoadBalancer Service (`kubectl get svc -n fmad-demo`). The lack of an external IP is expected as the application is not yet deployed to the member clusters. 

```output
NAME           TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
fm-ad-app-01   LoadBalancer   10.0.131.149   <pending>     8000:32289/TCP   6m28s
```

- A ConfigMap (`kubectl get cm -n fmad-demo`).

```output
NAME                  DATA   AGE
fm-ad-app-01-config   0      7m31s
kube-root-ca.crt      1      23m
```

### Place application onto member clusters

The final step is to place the application onto the member clusters. In order to do this you need to write a [cluster resource placement](https://learn.microsoft.com/azure/kubernetes-fleet/quickstart-resource-propagation?tabs=azure-cli) manifest and manually add it to the list of manifests executed by the GitHub Actions workflow. In a future release we hope to provide a more intuitive way to do this for those who are not familiar with Kubernetes.
