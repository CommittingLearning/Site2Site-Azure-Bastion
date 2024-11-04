# Azure Bastion Host Deployment with Terraform and CI/CD Pipeline

This repository contains Terraform configuration files for deploying an Azure Bastion Host within an existing Virtual Network (VNet), along with a GitHub Actions CI/CD pipeline for automated deployment. The pipeline includes validation, security checks, manual approval, and automatic teardown after a demonstration period.

## Table of Contents

- [Introduction](#introduction)
- [Terraform Configuration](#terraform-configuration)
  - [Resources Created](#resources-created)
  - [Variables](#variables)
  - [Outputs](#outputs)
- [CI/CD Pipeline](#cicd-pipeline)
  - [Workflow Triggers](#workflow-triggers)
  - [Pipeline Overview](#pipeline-overview)
  - [Environment Variables and Secrets](#environment-variables-and-secrets)
- [Usage](#usage)
  - [Clone the Repository](#clone-the-repository)
  - [Set Up Azure Credentials](#set-up-azure-credentials)
  - [Configure the Terraform Backend](#configure-the-terraform-backend)
  - [Dependency on Existing VNet](#dependency-on-existing-vnet)
  - [Branch Strategy](#branch-strategy)
  - [Manual Approval](#manual-approval)
  - [Automatic Teardown](#automatic-teardown)
- [Notes](#notes)

## Introduction

This project automates the deployment of an Azure Bastion Host within an existing Virtual Network (VNet) using Terraform. The Bastion Host allows secure and seamless RDP and SSH connectivity to virtual machines directly through the Azure Portal without exposing them to public IP addresses.

The GitHub Actions CI/CD pipeline automates validation, security scanning, deployment, and teardown processes.

The CI/CD pipeline is designed to:

- Validate and test Terraform code on pull requests.
- Deploy infrastructure on pushes to specific branches.
- Perform security checks using TFSec.
- Require manual approval before deployment.
- Automatically destroy resources after a demonstration period to minimize costs.

## Terraform Configuration

### Resources Created

The Terraform configuration deploys the following resources:

1. **Azure Public IP Address:**

   - **Name:** `bastion-public-ip-{environment}`
   - **Allocation Method:** Defined by `var.IPAllocation` (default is `Static`).
   - **SKU:** Defined by `var.IPsku` (default is `Standard`).

2. **Azure Bastion Host:**

   - **Name:** `bastion-{environment}`
   - **Location:** Defined by `var.location` (default is `West US`).
   - **SKU:** Defined by `var.Bastionsku` (default is `Basic`).
   - **Subnet:** Uses the `AzureBastionSubnet` from the existing VNet.
   - **Public IP Address:** Associates with the created public IP.

### Variables

The `variables.tf` file defines the inputs for the Terraform configuration:

- **Azure Credentials:**
  - `azure_subscription_id` (type: `string`, provided via secrets)
  - `azure_client_id` (type: `string`, provided via secrets)
  - `azure_tenant_id` (type: `string`, provided via secrets)

- **Resource Group:**
  - `rg_name` (default: `"Site2Site_rg"`)

- **Location:**
  - `location` (default: `"West US"`)

- **Environment:**
  - `environment` (type: `string`)

- **Public IP Configuration:**
  - `IPAllocation` (default: `"Static"`)
  - `IPsku` (default: `"Standard"`)

- **Bastion Host Configuration:**
  - `Bastionsku` (default: `"Basic"`)

### Outputs

The `outputs.tf` file provides the following outputs after deployment:

- `bastion_public_ip`: Public IP address of the Bastion Host.
- `bastion_name`: Name of the Bastion Host.

## CI/CD Pipeline

The CI/CD pipeline is defined in the GitHub Actions workflow file `.github/workflows/azure-terraform.yml`. It automates the deployment process and ensures code quality and security.

### Workflow Triggers

The pipeline is triggered on:

- **Pull Requests** to the following branches:
  - `development`
  - `production`
  - `testing`
- **Pushes** to the following branches:
  - `development`
  - `production`

### Pipeline Overview

The pipeline consists of two primary jobs:

1. **Validate and Test (`validate-and-test`):**

   - **Checkout Code:** Retrieves the repository code.
   - **Azure Login:** Authenticates to Azure using OpenID Connect (OIDC) with the provided credentials.
   - **Set Up Terraform:** Prepares the environment for Terraform operations.
   - **Set Environment Variable:** Determines the environment (`development`, `production`, or `default`) based on the branch.
   - **Terraform Initialization:** Initializes Terraform with backend configuration for state storage in Azure Blob Storage.
   - **Terraform Validate:** Validates the Terraform configuration syntax.
   - **Terraform Plan:** Creates an execution plan and saves it to `tfplan`.
   - **Show Terraform Plan:** Displays the plan output.
   - **Install TFSec:** Installs TFSec for security scanning.
   - **Run TFSec Security Checks:** Scans the Terraform code for potential security issues.
   - **Skip Apply in Pull Requests:** Ensures that deployment does not occur on pull requests.

2. **Deploy (`deploy`):**

   - **Depends On:** The `validate-and-test` job must succeed.
   - **Runs On:** Not triggered on pull requests.
   - **Repeat Steps:** Similar steps for checkout, authentication, environment setup, and initialization.
   - **Re-run Terraform Plan:** Ensures the plan is up-to-date before applying.
   - **Manual Approval:** Requires manual approval via GitHub Issues before proceeding with the apply step.
   - **Terraform Apply:** Applies the changes as per the plan.
   - **Wait for Demonstration Period:** Pauses execution for 7.5 minutes (450 seconds) to allow for demonstration or testing.
   - **Terraform Destroy:** Automatically destroys the resources to prevent unnecessary costs.

### Environment Variables and Secrets

The pipeline uses the following secrets and environment variables:

- **Secrets (Stored in GitHub Secrets):**
  - `AZURE_CLIENT_ID`: Azure Service Principal Client ID.
  - `AZURE_TENANT_ID`: Azure Tenant ID.
  - `AZURE_SUBSCRIPTION_ID`: Azure Subscription ID.
  - `github_TOKEN`: Automatically provided by GitHub for authentication in workflows.

- **Environment Variables:**
  - `ENVIRONMENT`: Set based on the branch (`development`, `production`, or `default`).

## Usage

### Clone the Repository

```bash
git clone https://github.com/CommittingLearning/Site2Site-Azure-Bastion.git
```

### Set Up Azure Credentials

Ensure that the following secrets are added to your GitHub repository under **Settings > Secrets and variables > Actions**:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

These credentials should correspond to an Azure Service Principal with the necessary permissions.

### Configure the Terraform Backend

The Terraform backend is configured to use Azure Blob Storage. Ensure that the storage account and container specified in the `terraform init` command exist, or modify the backend configuration as needed.

- **Storage Account Name:** `tsblobstore11{environment}`
- **Container Name:** `terraform-state`
- **Key:** `Site2Site_Bastion_{environment}.tfstate`
- **Resource Group Name:** `Site2Site_rg_{environment}`

### Dependency on Existing VNet

This deployment depends on an existing VNet and its subnets, specifically the `AzureBastionSubnet`. Ensure that:

- The VNet and subnets are already deployed and accessible.
- The Terraform state for the VNet is stored remotely and accessible via Terraform Remote State Data Source.
- Adjust the `data.tf` file if necessary to point to the correct remote state.

### Branch Strategy

- **Development Environment:** Use the `development` branch to deploy to the development environment.
- **Production Environment:** Use the `production` branch to deploy to the production environment.
- **Default Environment:** Any other branches will use the `default` environment settings.

### Manual Approval

The pipeline requires manual approval before applying changes:

- A GitHub issue will be created prompting for approval.
- Approvers need to approve the issue to proceed with deployment.

### Automatic Teardown

After a demonstration period of 7.5 minutes, the pipeline will automatically destroy the deployed resources to prevent unnecessary costs.

## Notes

- **Security Checks:**
  - The pipeline includes security checks using TFSec to identify potential security issues in the Terraform code.

- **State Management:**
  - Terraform state is stored remotely in Azure Blob Storage, ensuring consistency across deployments.
  - The deployment uses a Terraform Remote State Data Source to access outputs from the VNet deployment.

- **Customizations:**
  - Modify the variables in `variables.tf` to change resource names, configurations, and other settings as needed.

- **Testing:**
  - Pull requests to `development`, `production`, or `testing` branches will trigger the validation and testing steps without applying changes.

---

**Disclaimer:** This repository is accessible in a read only format, and therefore, only the admin has the privileges to perform a push on the branches.