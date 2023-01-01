# Azure Web App Infratsructure

This is a simple example of how to use Terraform to deploy a web application to
Azure.

**Note**: This won't work for you unless you have the "keys" to the Azure Environment.

TODO: Create an Azure Pipeline that can run this.

## Getting started

### **Step 1: Install Terraform**

Follow the installation instructions from Terraform [here](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started#install-terraform).

### **Step 2: Install az CLI**

Follow the installation instructions from Microsoft [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

### **Step 3: Setup Terraform to work with Azure**

Follow the setup instructions for Azure from Terraform [here](https://learn.hashicorp.com/tutorials/terraform/azure-build?in=terraform/azure-get-started).

#### **Environment Variables**

Note: You will need to have the following environment variables set:

```bash
$Env:ARM_CLIENT_ID = "<APPID_VALUE>"
$Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
$Env:ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
$Env:ARM_TENANT_ID = "<TENANT_VALUE>"
```

### **Step 4: Move the state file to Azure Storage**

- Open `./init-state-storage.ps1` and modify the variables at the top to specify the resource group,storage account, and container to create for your tfstate file. NOTE: This should be a different resource group than the one you are deploying your solution to.

```powershell
$RESOURCE_GROUP_NAME = 'tfstate'
$STORAGE_ACCOUNT_NAME = "aafcwebapptfstatestor"
$CONTAINER_NAME = 'aafcwebapp'
```

- Open a powershell terminal and run the following commands:

```powershell
./init-state-storage.ps1
```

- Modify `main.tf` to use the storage account and container you created in the previous step. Replace the values in "<>" below with the values you used in the previous step.

```terraform
  backend "azurerm" {
    resource_group_name  = "<RESOURCE_GROUP_NAME>"
    storage_account_name = "<STORAGE_ACCOUNT_NAME>"
    container_name       = "<CONTAINER_NAME>"
    key                  = "terraform.tfstate"
  }
```

- If you have a local `terraform.tfstate` file, move it to the Azure storage account container you just created.
