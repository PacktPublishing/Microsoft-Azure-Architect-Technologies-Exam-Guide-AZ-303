#create basic webapi
mkdir webapi
cd webapi
dotnet new webapi

#setup git
git config user.email “myemail@mydomain.com”
git config user.name “yourname”
git init
git add .
git commit -m "first commit"

#setup the webapp
az webapp deployment user set --user-name auniqueusername
az group create --location eastus --name PacktWebAppRSG
az appservice plan create --name packtpubwebapi --resource-group PacktWebAppRSG --sku FREE
az webapp create --name packtpubwebapi --resource-group PacktWebAppRSG --plan packtpubwebapi 
az webapp deployment source config-local-git --name packtpubwebapi --resource-group PacktWebAppRSG

#deploy to the webapp
git remote add azure https://yourdeploymentusername@packtpubwebapi.scm.azurewebsites.net/packtpubwebapi.git
git push azure master
