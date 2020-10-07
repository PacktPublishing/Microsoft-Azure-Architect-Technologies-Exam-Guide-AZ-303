# First connect to your Azure Account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Set some paramaters:
$ResourceGroupName = 'PacktVMResourceGroup'
$vmName = 'PacktVM1'
$KeyVaultName = 'PacktEncryptionVault'

#Retrieve the Key Vault:
$KeyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName
$diskEncryptionKeyVaultUrl = $KeyVault.VaultUri
$KeyVaultResourceId = $KeyVault.ResourceId

#Encrypt the disk:
Set-AzVMDiskEncryptionExtension `
    -ResourceGroupName $ResourceGroupName `
    -VMName $vmName `
    -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
    -DiskEncryptionKeyVaultId $KeyVaultResourceId