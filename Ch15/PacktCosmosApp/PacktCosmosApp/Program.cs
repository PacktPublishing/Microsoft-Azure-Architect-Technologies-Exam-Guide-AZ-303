using System;
using System.Threading.Tasks;
using System.Configuration;
using System.Collections.Generic;
using System.Net;
using Microsoft.Azure.Cosmos;

namespace PacktCosmosApp
{
    class Program
    {
        // Azure Cosmos DB endpoint.
        private static readonly string EndpointUri = "<your endpoint here>";
        // Primary key for the Azure Cosmos account.
        private static readonly string PrimaryKey = "<your primary key>";

        // The Cosmos client instance
        private CosmosClient cosmosClient;

        // The database we will create
        private Database database;

        // The container we will create.
        private Container container;

        // The name of the database and container we will create
        private string databaseId = "FamilyDatabase";
        private string containerId = "FamilyContainer";

        public static async Task Main(string[] args)
        {
            try
            {
                Console.WriteLine("Beginning operations...\n");
                Program p = new Program();
                await p.GetStartedDemoAsync();

            }
            catch (CosmosException de)
            {
                Exception baseException = de.GetBaseException();
                Console.WriteLine("{0} error occurred: {1}", de.StatusCode, de);
            }
            catch (Exception e)
            {
                Console.WriteLine("Error: {0}", e);
            }
            finally
            {
                Console.WriteLine("End of demo, press any key to exit.");
                Console.ReadKey();
            }
        }

        public async Task GetStartedDemoAsync()
        {
            // Create a new instance of the Cosmos Client
            this.cosmosClient = new CosmosClient(EndpointUri, PrimaryKey);
            await this.CreateDatabaseAsync();
            await this.CreateContainerAsync();
            await this.AddItemsToContainerAsync();
            await this.QueryItemsAsync();
            await this.ReplaceFamilyItemAsync();
            await this.DeleteFamilyItemAsync();
        }
        /// <summary>
        /// Create the database if it does not exist
        /// </summary>
        private async Task CreateDatabaseAsync()
        {
            // Create a new database
            this.database = await this.cosmosClient.CreateDatabaseIfNotExistsAsync(databaseId);
            Console.WriteLine("Created Database: {0}\n", this.database.Id);
        }
        /// <summary>
        /// Create the container if it does not exist. 
        /// Specifiy "/LastName" as the partition key since we're storing family information, to ensure good distribution of requests and storage.
        /// </summary>
        /// <returns></returns>
        private async Task CreateContainerAsync()
        {
            // Create a new container
            this.container = await this.database.CreateContainerIfNotExistsAsync(containerId, "/LastName");
            Console.WriteLine("Created Container: {0}\n", this.container.Id);
        }

        /// <summary>
        /// Add Family items to the container
        /// </summary>
        private async Task AddItemsToContainerAsync()
        {
            // Create a family object for the Zaal family
            Family ZaalFamily = new Family
            {
                Id = "Zaal.1",
                LastName = "Zaal",
                Parents = new Parent[]
                {
            new Parent { FirstName = "Thomas" },
            new Parent { FirstName = "Sjoukje" }
                },
                Children = new Child[]
                {
            new Child
            {
                FirstName = "Molly",
                Gender = "female",
                Grade = 5,
                Pets = new Pet[]
                {
                    new Pet { GivenName = "Fluffy" }
                }
            }
                },
                Address = new Address { State = "WA", County = "King", City = "Seattle" },
                IsRegistered = false
            };

            try
            {
                // Read the item to see if it exists.  
                ItemResponse<Family> zaalFamilyResponse = await this.container.ReadItemAsync<Family>(ZaalFamily.Id, new PartitionKey(ZaalFamily.LastName));
                Console.WriteLine("Item in database with id: {0} already exists\n", zaalFamilyResponse.Resource.Id);
            }
            catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                // Create an item in the container representing the Zaal family. Note we provide the value of the partition key for this item, which is "Zaal"
                ItemResponse<Family> zaalFamilyResponse = await this.container.CreateItemAsync<Family>(ZaalFamily, new PartitionKey(ZaalFamily.LastName));

                // Note that after creating the item, we can access the body of the item with the Resource property off the ItemResponse. We can also access the RequestCharge property to see the amount of RUs consumed on this request.
                Console.WriteLine("Created item in database with id: {0} Operation consumed {1} RUs.\n", zaalFamilyResponse.Resource.Id, zaalFamilyResponse.RequestCharge);
            }

            // Create a family object for the PacktPub family
            Family PacktPubFamily = new Family
            {
                Id = "PacktPub.1",
                LastName = "PacktPub",
                Parents = new Parent[]
                {
            new Parent { FamilyName = "PacktPub", FirstName = "Robin" },
            new Parent { FamilyName = "Zaal", FirstName = "Sjoukje" }
                },
                Children = new Child[]
                {
            new Child
            {
                FamilyName = "Merriam",
                FirstName = "Jesse",
                Gender = "female",
                Grade = 8,
                Pets = new Pet[]
                {
                    new Pet { GivenName = "Goofy" },
                    new Pet { GivenName = "Shadow" }
                }
            },
            new Child
            {
                FamilyName = "Miller",
                FirstName = "Lisa",
                Gender = "female",
                Grade = 1
            }
                },
                Address = new Address { State = "NY", County = "Manhattan", City = "NY" },
                IsRegistered = true
            };

            try
            {
                // Read the item to see if it exists
                ItemResponse<Family> packtPubFamilyResponse = await this.container.ReadItemAsync<Family>(PacktPubFamily.Id, new PartitionKey(PacktPubFamily.LastName));
                Console.WriteLine("Item in database with id: {0} already exists\n", packtPubFamilyResponse.Resource.Id);
            }
            catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                // Create an item in the container representing the Wakefield family. Note we provide the value of the partition key for this item, which is "PacktPub"
                ItemResponse<Family> packtPubFamilyResponse = await this.container.CreateItemAsync<Family>(PacktPubFamily, new PartitionKey(PacktPubFamily.LastName));

                // Note that after creating the item, we can access the body of the item with the Resource property off the ItemResponse. We can also access the RequestCharge property to see the amount of RUs consumed on this request.
                Console.WriteLine("Created item in database with id: {0} Operation consumed {1} RUs.\n", packtPubFamilyResponse.Resource.Id, packtPubFamilyResponse.RequestCharge);
            }
        }
        /// <summary>
        /// Run a query (using Azure Cosmos DB SQL syntax) against the container
        /// </summary>
        private async Task QueryItemsAsync()
        {
            var sqlQueryText = "SELECT * FROM c WHERE c.LastName = 'Zaal'";

            Console.WriteLine("Running query: {0}\n", sqlQueryText);

            QueryDefinition queryDefinition = new QueryDefinition(sqlQueryText);
            FeedIterator<Family> queryResultSetIterator = this.container.GetItemQueryIterator<Family>(queryDefinition);

            List<Family> families = new List<Family>();

            while (queryResultSetIterator.HasMoreResults)
            {
                FeedResponse<Family> currentResultSet = await queryResultSetIterator.ReadNextAsync();
                foreach (Family family in currentResultSet)
                {
                    families.Add(family);
                    Console.WriteLine("\tRead {0}\n", family);
                }
            }
        }

        /// <summary>
        /// Update an item in the container
        /// </summary>
        private async Task ReplaceFamilyItemAsync()
        {
            ItemResponse<Family> PacktPubFamilyResponse = await this.container.ReadItemAsync<Family>("PacktPub.1", new PartitionKey("PacktPub"));
            var itemBody = PacktPubFamilyResponse.Resource;

            // update registration status from false to true
            itemBody.IsRegistered = true;
            // update grade of child
            itemBody.Children[0].Grade = 6;

            // replace the item with the updated content
            PacktPubFamilyResponse = await this.container.ReplaceItemAsync<Family>(itemBody, itemBody.Id, new PartitionKey(itemBody.LastName));
            Console.WriteLine("Updated Family [{0},{1}].\n \tBody is now: {2}\n", itemBody.LastName, itemBody.Id, PacktPubFamilyResponse.Resource);
        }
        /// <summary>
        /// Delete an item in the container
        /// </summary>
        private async Task DeleteFamilyItemAsync()
        {
            var partitionKeyValue = "Zaal";
            var familyId = "Zaal.1";

            // Delete an item. Note we must provide the partition key value and id of the item to delete
            _ = await this.container.DeleteItemAsync<Family>(familyId, new PartitionKey(partitionKeyValue));
            Console.WriteLine("Deleted Family [{0},{1}]\n", partitionKeyValue, familyId);
        }
    }
}
