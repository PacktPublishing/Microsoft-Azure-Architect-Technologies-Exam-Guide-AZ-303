#First connect to your Azure Account:
Connect-AzAccount

#If necessary, select the right subscription:
Select-AzSubscription -SubscriptionId "********-****-****-****-***********"

#Create first VNet
#Define variables:
$RG1 = "PacktResourceGroup1"
$Location1 = "East US"
$VNetName1 = "PacktVNet1"
$FESubName1 = "FrontEnd"
$BESubName1 = "Backend"
$VNetPrefix01 = "10.11.0.0/16"
$VNetPrefix02 = "10.12.0.0/16"
$FESubPrefix1 = "10.11.0.0/24"
$BESubPrefix1 = "10.12.0.0/24"
$GWSubPrefix1 = "10.12.255.0/27"
$GWName1 = "PacktVNet1Gateway"
$GWIPName1 = "PacktVNet1GWIP"
$GWIPconfName1 = "gwipconf1"
$Connection01 = "VNet1toVNet2"

#Create a resource group:
New-AzResourceGroup -Name $RG1 -Location $Location1

#Create the subnet configurations for PacktVNet1:
$fesub1 = New-AzVirtualNetworkSubnetConfig -Name $FESubName1 -AddressPrefix $FESubPrefix1
$besub1 = New-AzVirtualNetworkSubnetConfig -Name $BESubName1 -AddressPrefix $BESubPrefix1
$gwsub1 = New-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix $GWSubPrefix1

#Create PacktVNet1:
New-AzVirtualNetwork -Name $VNetName1 `
    -ResourceGroupName $RG1 `
    -Location $Location1 `
    -AddressPrefix $VNetPrefix01,$VNetPrefix02 `
    -Subnet $fesub1,$besub1,$gwsub1

#Request a public IP for the gateway:
$gwpip1 = New-AzPublicIpAddress `
    -Name $GWIPName1 `
    -ResourceGroupName $RG1 `
    -Location $Location1 `
    -AllocationMethod Dynamic

#Create the gateway configurations:
$vnet1 = Get-AzVirtualNetwork `
    -Name $VNetName1 `
    -ResourceGroupName $RG1
$subnet1 = Get-AzVirtualNetworkSubnetConfig `
    -Name "GatewaySubnet" `
    -VirtualNetwork $vnet1
$gwipconf1 = New-AzVirtualNetworkGatewayIpConfig `
    -Name $GWIPconfName1 `
    -Subnet $subnet1 `
    -PublicIpAddress $gwpip1

#Create the gateway:
New-AzVirtualNetworkGateway `
    -Name $GWName1 `
    -ResourceGroupName $RG1 `
    -Location $Location1 `
    -IpConfigurations $gwipconf1 `
    -GatewayType Vpn `
    -VpnType RouteBased `
    -GatewaySku VpnGw1


#Create second VNet
#Define variables:
$RG2 = "PacktResourceGroup2"
$Location2 = "West US"
$VNetName2 = "PacktVNet2"
$FESubName2 = "FrontEnd"
$BESubName2 = "Backend"
$VnetPrefix11 = "10.41.0.0/16"
$VnetPrefix12 = "10.42.0.0/16"
$FESubPrefix2 = "10.41.0.0/24"
$BESubPrefix2 = "10.42.0.0/24"
$GWSubPrefix2 = "10.42.255.0/27"
$GWName2 = "PacktVNet2Gateway"
$GWIPName2 = "PacktVNet1GWIP"
$GWIPconfName2 = "gwipconf2"
$Connection02 = "VNet2toVNet1"

#Create a resource group:
New-AzResourceGroup -Name $RG2 -Location $Location2

#Create the subnet configurations for PacktVNet2:
$fesub2 = New-AzVirtualNetworkSubnetConfig -Name $FESubName2 -AddressPrefix $FESubPrefix2
$besub2 = New-AzVirtualNetworkSubnetConfig -Name $BESubName2 -AddressPrefix $BESubPrefix2
$gwsub2 = New-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix $GWSubPrefix2

#Create PacktVNet2:
New-AzVirtualNetwork `
    -Name $VnetName2 `
    -ResourceGroupName $RG2 `
    -Location $Location2 `
    -AddressPrefix $VnetPrefix11,$VnetPrefix12 `
    -Subnet $fesub2,$besub2,$gwsub2

#Request a public IP address:
$gwpip2 = New-AzPublicIpAddress `
    -Name $GWIPName2 `
    -ResourceGroupName $RG2 `
    -Location $Location2 `
    -AllocationMethod Dynamic

#Create the gateway configuration:
$vnet2 = Get-AzVirtualNetwork `
    -Name $VnetName2 `
    -ResourceGroupName $RG2
$subnet2 = Get-AzVirtualNetworkSubnetConfig `
    -Name "GatewaySubnet" `
    -VirtualNetwork $vnet2
$gwipconf2 = New-AzVirtualNetworkGatewayIpConfig `
    -Name $GWIPconfName2 `
    -Subnet $subnet2 `
    -PublicIpAddress $gwpip2

#Create the gateway:
New-AzVirtualNetworkGateway -Name $GWName2 `
    -ResourceGroupName $RG2 `
    -Location $Location2 `
    -IpConfigurations $gwipconf2 `
    -GatewayType Vpn `
    -VpnType RouteBased `
    -GatewaySku VpnGw1

#Create the connections
$vnet1gw = Get-AzVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
$vnet2gw = Get-AzVirtualNetworkGateway -Name $GWName2 -ResourceGroupName $RG2

New-AzVirtualNetworkGatewayConnection `
    -Name $Connection01 `
    -ResourceGroupName $RG1 `
    -VirtualNetworkGateway1 $vnet1gw `
    -VirtualNetworkGateway2 $vnet2gw `
    -Location $Location1 `
    -ConnectionType Vnet2Vnet `
    -SharedKey 'AzurePacktGateway'

New-AzVirtualNetworkGatewayConnection `
    -Name $Connection02 `
    -ResourceGroupName $RG2 `
    -VirtualNetworkGateway1 $vnet2gw `
    -VirtualNetworkGateway2 $vnet1gw `
    -Location $Location2 `
    -ConnectionType Vnet2Vnet `
    -SharedKey 'AzurePacktGateway'

#Verify the connections:
Get-AzVirtualNetworkGatewayConnection -Name $Connection01 -ResourceGroupName $RG1
Get-AzVirtualNetworkGatewayConnection -Name $Connection02 -ResourceGroupName $RG2