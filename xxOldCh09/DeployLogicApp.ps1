# First connect to your Azure Account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create a resource group:
New-AzResourceGroup -Name PacktLogicAppResourceGroup -Location EastUS

#Deploy the template inside your Azure subscription:
New-AzResourceGroupDeployment `
    -Name PacktDeployment `
    -ResourceGroupName PacktLogicAppResourceGroup `
    -TemplateFile c:\MyTemplates\template.json