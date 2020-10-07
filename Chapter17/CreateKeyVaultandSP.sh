#Create resource Group
az group create --name "DataEncryptionResourceGroup" -l "EastUS"

#Create a Storage account with Blob container
az storage account create \
    --name packtblobstorageaccount1 \
    --resource-group DataEncryptionResourceGroup \
    --location eastus \
    --sku Standard_LRS \
    --encryption blob
	
#Display Storage account account keys
az storage account keys list \
    --account-name packtblobstorageaccount1 \
    --resource-group DataEncryptionResourceGroup \
    --output table

#Create Key Vault
az keyvault create --name PacktDataEncryptionVault -g "DataEncryptionResourceGroup"

#Create a Service Principal
az ad sp create-for-rbac -n "http://PacktSP" --sdk-auth

#create an access policy for the Service Principal
az keyvault set-policy \
	-n PacktDataEncryptionVault \
	--spn <clientId-of-your-service-principal> \
	--secret-permissions delete get list set \
	--key-permissions create decrypt delete encrypt get list unwrapKey wrapKey
	
#Store clientID and clientSecret in Key Vault
az keyvault secret set \
	--vault-name PacktDataEncryptionVault \
	--name "clientID" \
	--value <clientId-of-your-service-principal>
az keyvault secret set \
	--vault-name PacktDataEncryptionVault \
	--name "clientSecret" \
	--value <clientSecret-of-your-service-principal>

#Create an RSA Key for encrypting the data
azure keyvault secret set \
	--name rsakey \
	--vault-name PacktDataEncryptionVault \
	--file ~/.ssh/id_rsa