##################################################################################
# Naming Scheme
##################################################################################

# Virtual Machine Commands:
az vm list
az vm create
az vm delete

# Keyvault Commands:
az keyvault list
az keyvault create
az keyvault delete

# Networking Commands:
az network vnet list
az network vnet create
az network vnet delete

# Subnet Commands:
az network vnet subnet list
az network vnet subnet create
az network vnet subnet delete

##################################################################################
# Switching Subscription
##################################################################################
# get the current default subscription using show
az account show --output table

# get the current default subscription using list
az account list --query "[?isDefault]"

# get a list of subscriptions except for the default subscription
az account list --query "[?isDefault == \`false\`]"

# get the details of a specific subscription
az account show --subscription MySubscriptionName