gitrepo="https://github.com/PacktPublishing/Microsoft-Azure-Architect-Technologies-Exam-Guide-AZ-300/Chapter14/PacktPubToDoAPI"
webappname="PacktPubToDoAPI"

# Create a resource group.
az group create --location eastus --name PacktWebAppResourceGroup

# Create an App Service plan in the FREE tier.
az appservice plan create --name $webappname --resource-group PacktWebAppResourceGroup --sku FREE

# Create a web app.
az webapp create --name $webappname --resource-group PacktWebAppResourceGroup --plan $webappname

# Deploy code from a public GitHub repository. 
az webapp deployment source config --name $webappname --resource-group PacktWebAppResourceGroup \
--repo-url $gitrepo --branch master --manual-integration