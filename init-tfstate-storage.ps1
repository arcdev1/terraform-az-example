$RESOURCE_GROUP_NAME = 'tfstate'
$STORAGE_ACCOUNT_NAME = "webapptfstatestor"
$CONTAINER_NAME = 'webapp'

# Create resource group
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location canadacentral

# Create storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME -SkuName Standard_LRS -Location canadacentral 

# Create blob container
New-AzStorageContainer -Name $CONTAINER_NAME -Context $storageAccount.context -Permission blob

# Get storage account key
$ACCOUNT_KEY = (Get-AzStorageAccountKey -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME)[0].value
$env:ARM_ACCESS_KEY = $ACCOUNT_KEY