# Here we are making a 128-bit key so we have 16 characters.
# The characters are in the ASCII range of UTF8 so they are
# each 1 byte. 16 x 8 = 128:
$key = "qwertyuiopasdfgh"
$b = [System.Text.Encoding]::UTF8.GetBytes($key)
$enc = [System.Convert]::ToBase64String($b)
$secretvalue = ConvertTo-SecureString $enc -AsPlainText -Force

# Substitute the VaultName and Name in this command:
$secret = Set-AzureKeyVaultSecret -VaultName 'PacktDataEncryptionVault' -Name 'Secret2' -SecretValue $secretvalue -ContentType "application/octet-stream"