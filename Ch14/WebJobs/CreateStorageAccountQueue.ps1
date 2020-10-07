#First, we need to login to the Azure account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create a resource group for the Storage account:
New-AzResourceGroup -Name PacktPubWebJobStorageAccount -Location EastUS

#create a new storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName PacktPubWebJobStorageAccount -AccountName packtwebjobstorage -Location "East US" -SkuName Standard_GRS -Kind StorageV2 -AccessTier Hot
$ctx = $storageAccount.Context

#create a new queue
$queue = New-AzStorageQueue –Name "webjob" -Context $ctx