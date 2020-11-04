#First connect to your Azure Account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#URL to the sample application on GitHub
$gitrepo="https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
$webappname="PacktWebApp"

#Create the web app:
New-AzWebApp `
    -Name $webappname `
    -Location "East US" `
    -AppServicePlan PacktAppServicePlan `
    -ResourceGroupName PacktAppServicePlan

#Configure GitHub deployment from your GitHub repo:
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
    isManualIntegration = "true";
}

#Deploy the GitHub web app to the web app:
Set-AzResource `
    -PropertyObject $PropertiesObject `
    -ResourceGroupName PacktAppServicePlan `
    -ResourceType Microsoft.Web/sites/sourcecontrols `
    -ResourceName $webappname/web `
    -ApiVersion 2015-08-01 `
    -Force