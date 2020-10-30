# Create a resource group.
az group create --location eastus --name PacktVMResourceGroup

# Create the VM.
az vm create \
    --resource-group PacktVMResourceGroup \
    --name PacktVM \
    --image win2016datacenter \
    --admin-username packtuser \
    --admin-password PacktPassword123