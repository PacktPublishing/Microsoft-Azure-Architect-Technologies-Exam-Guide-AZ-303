using Microsoft.Azure;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Auth;
using Microsoft.Azure.Storage.Blob;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace PacktDataAtRest
{
    class Program
    {
        static void Main(string[] args)
        {
            // This is standard code to interact with Blob storage.
            StorageCredentials creds = new StorageCredentials(
                CloudConfigurationManager.GetSetting("accountName"),
                CloudConfigurationManager.GetSetting("accountKey")
                );
            CloudStorageAccount account = new CloudStorageAccount(creds, useHttps: true);
            CloudBlobClient client = account.CreateCloudBlobClient();
            CloudBlobContainer contain = client.GetContainerReference(CloudConfigurationManager.GetSetting("container"));
            contain.CreateIfNotExists();

            // The Resolver object is used to interact with Key Vault for Azure Storage.
            // This is where the GetToken method from below is used.
            KeyVaultKeyResolver cloudResolver = new KeyVaultKeyResolver(GetToken);

            // Retrieve the secret that you created previously.
            SymmetricKey sec = (SymmetricKey)cloudResolver.ResolveKeyAsync(
                        "https://packtdataencryptionvault.vault.azure.net/secrets/Secret2/",
                        CancellationToken.None).GetAwaiter().GetResult();

            // Now you simply use the RSA key to encrypt by setting it in the BlobEncryptionPolicy.
            BlobEncryptionPolicy policy = new BlobEncryptionPolicy(sec, null);
            BlobRequestOptions options = new BlobRequestOptions() { EncryptionPolicy = policy };

            // Reference a block blob.
            CloudBlockBlob blob = contain.GetBlockBlobReference("PacktFile.txt");

            // Upload using the UploadFromStream method.
            using (var stream = System.IO.File.OpenRead(@"C:\Temp\PacktFile.txt"))
                blob.UploadFromStream(stream, stream.Length, null, options, null);


            // In this case, we will not pass a key and only pass the resolver because
            // this policy will only be used for downloading / decrypting.
            BlobEncryptionPolicy policy1 = new BlobEncryptionPolicy(null, cloudResolver);
            BlobRequestOptions options1 = new BlobRequestOptions() { EncryptionPolicy = policy1 };

            using (var np = File.Open(@"C:\Temp\MyFileDecrypted.txt", FileMode.Create))
                blob.DownloadToStream(np, null, options1, null);

        }

        private async static Task<string> GetToken(string authority, string resource, string scope)
        {
            var authContext = new AuthenticationContext(authority);
            ClientCredential clientCred = new ClientCredential(
                CloudConfigurationManager.GetSetting("clientId"),
                CloudConfigurationManager.GetSetting("clientSecret"));
            AuthenticationResult result = await authContext.AcquireTokenAsync(resource, clientCred);

            if (result == null)
                throw new InvalidOperationException("Failed to obtain the JWT token");

            return result.AccessToken;
        }
    }
}
