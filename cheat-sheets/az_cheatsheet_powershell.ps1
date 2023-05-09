##################################################################################
# Naming Scheme
##################################################################################

# Virtual machine Commands:
Get-AzVM
New-AzVM
Remove-AzVM

# Keyvault Commands:
Get-AzKeyVault
New-AzKeyVault
Remove-AzKeyVault

# VNet Commands:
Get-AzVirtualNetwork
New-AzVirtualNetwork
Remove-AzVirtualNetwork

# Subnet Commands:
Get-AzVirtualNetworkSubnetConfig
New-AzVirtualNetworkSubnetConfig
Remove-AzVirtualNetworkSubnetConfig

##################################################################################
# ROLES
##################################################################################

# Create Custom RBAC Role:
New-AzRoleDefinition -InputFile ./az104-02a-customRoleDefinition.json

##################################################################################
# POLICY
##################################################################################

# Get Policy by display name
Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq "Azure Cosmos DB allowed locations" }

# Assigning RG to $rg object
$rg = Get-AzResourceGroup -Name "RESOURCE_GROUP_NAME" -Location "East Us"

# Assigning DisplayName to $definition object
$definition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq "Azure Cosmos DB allowed locations" }

# Creating the Policy
New-AzPolicyAssignment -Name "CheckingNameRules" -DisplayName "Checking the rules" -Scope $rg.ResourceId -PolicyDefinition $definition

# Force Policy to run:
Start-AzPolicyComplianceScan -ResourceGroupName 'RESOURCE_GROUP_NAME'


##################################################################################
# Resource Groups
##################################################################################

# Create new Resource Group:
New-AzResourceGroup -Name "RESOURCE_GROUP_NAME" -Location "East Us"

# Get Resource Group:
Get-AzResourceGroup -Name "RESOURCE_GROUP_NAME" -Location "East Us"

# Assigning RG to object and get name & id:
$rg = Get-AzResourceGroup -Name "RESOURCE_GROUP_NAME" -Location "East Us"

$rg.ResourceGroupName
$rg.ResourceId

