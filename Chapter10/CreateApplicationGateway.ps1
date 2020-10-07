# First connect to your Azure Account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create a resource group:
New-AzResourceGroup -Name PacktApplicationGateway -Location EastUS

#Create the network resources:
$PacktAGSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name PacktAGSubnet `  -AddressPrefix 10.0.1.0/24

#Create the subnets:
$PacktBackendSubnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name PacktBackendSubnetConfig `
  -AddressPrefix 10.0.2.0/24

#Create the VNet:
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName PacktApplicationGateway `
  -Location eastus `
  -Name PacktVNet `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $PacktAGSubnet, $PacktBackendSubnetConfig

#Create the public IP address:
$pip = New-AzPublicIpAddress `
  -ResourceGroupName PacktApplicationGateway `
  -Location eastus `
  -Name PacktAGPublicIPAddress `
  -AllocationMethod Dynamic

#Create the VMs:
$vnet = Get-AzVirtualNetwork -ResourceGroupName PacktApplicationGateway -Name PacktVNet
$cred = Get-Credential
for ($i=1; $i -le 2; $i++)
{
# Create a virtual machine:
  $nic = New-AzNetworkInterface `
    -Name PacktNic$i `
    -ResourceGroupName PacktApplicationGateway `    -Location eastus `
    -SubnetId $vnet.Subnets[1].Id
  $vm = New-AzVMConfig `
    -VMName PacktVM$i `
    -VMSize Standard_D2
  $vm = Set-AzVMOperatingSystem `
    -VM $vm `
    -Windows `
    -ComputerName PAcktVM$i `
    -Credential $cred `
    -ProvisionVMAgent
  $vm = Set-AzVMSourceImage `
    -VM $vm `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2016-Datacenter `
    -Version latest
  $vm = Add-AzVMNetworkInterface `
    -VM $vm `
    -Id $nic.Id
  $vm = Set-AzVMBootDiagnostic `
    -VM $vm `
    -Disable

  New-AzVM -ResourceGroupName PacktApplicationGateway -Location eastus -VM $vm 
  Set-AzVMExtension `
    -ResourceGroupName PacktApplicationGateway `
    -ExtensionName IIS `
    -VMName PacktVM$i `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.4 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' `
    -Location EastUS
}

# Create IP configurations and frontend port:
$vnet = Get-AzVirtualNetwork `
  -ResourceGroupName PacktApplicationGateway `
  -Name PacktVNet
$subnet=$vnet.Subnets[0]
$gipconfig = New-AzApplicationGatewayIPConfiguration `
  -Name PacktAGIPConfig `
  -Subnet $subnet
$fipconfig = New-AzApplicationGatewayFrontendIPConfig `
  -Name PacktAGFrontendIPConfig `
  -PublicIPAddress $pip
$frontendport = New-AzApplicationGatewayFrontendPort `
  -Name PacktFrontendPort `
  -Port 80

# Create the backend pool and settings:
$address1 = Get-AzNetworkInterface -ResourceGroupName PacktApplicationGateway -Name PacktNic1
$address2 = Get-AzNetworkInterface -ResourceGroupName PacktApplicationGateway -Name PacktNic2

$backendPool = New-AzApplicationGatewayBackendAddressPool `
  -Name PacktGBackendPool `
  -BackendIPAddresses $address1.ipconfigurations[0].privateipaddress, $address2.ipconfigurations[0].privateipaddress
$poolSettings = New-AzApplicationGatewayBackendHttpSettings `
  -Name PacktPoolSettings `
  -Port 80 `
  -Protocol Http `
  -CookieBasedAffinity Enabled `
  -RequestTimeout 120

# Create the default listener and rule:
$defaultlistener = New-AzApplicationGatewayHttpListener `
  -Name PacktAGListener `
  -Protocol Http `
  -FrontendIPConfiguration $fipconfig `
  -FrontendPort $frontendport
$frontendRule = New-AzApplicationGatewayRequestRoutingRule `
  -Name rule1 `
  -RuleType Basic `
  -HttpListener $defaultlistener `
  -BackendAddressPool $backendPool `
  -BackendHttpSettings $poolSettings

#Create the Application Gateway:
$sku = New-AzApplicationGatewaySku -Name Standard_Medium -Tier Standard -Capacity 2

New-AzApplicationGateway `
  -Name PacktAppGateway `
  -ResourceGroupName PacktApplicationGateway `
  -Location eastus `
  -BackendAddressPools $backendPool `
  -BackendHttpSettingsCollection $poolSettings `
  -FrontendIpConfigurations $fipconfig `
  -GatewayIpConfigurations $gipconfig `
  -FrontendPorts $frontendport `
  -HttpListeners $defaultlistener `
  -RequestRoutingRules $frontendRule `
  -Sku $sku

# Get the IP address:
Get-AzPublicIPAddress -ResourceGroupName PacktApplicationGateway -Name PacktAGPublicIPAddress