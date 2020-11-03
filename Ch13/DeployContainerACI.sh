#Create a resource group
az group create \
	--name PacktACIResourceGroup \
	--location eastus

#Create a container and push the image
az container create \
	--name packtaciapp \
	--resource-group PacktACIResourceGroup \
	--os-type linux \
	--image packtaciapp20190917053041.azurecr.io/packtaciapp:latest \
	--ip-address public

#Show status of container
az container show \
	--resource-group PacktACIResourceGroup \
	--name packtaciapp \
	--query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" \
	--out table