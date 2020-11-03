#Connect to AKS cluster
az aks get-credentials \
	--resource-group PacktAKSResourceGroup \
	--name PacktAKSCluster \
	--subscription "<your-subscription-id>"
	
#Verify the connection
kubectl get nodes