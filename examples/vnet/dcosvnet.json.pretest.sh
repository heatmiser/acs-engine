#!/bin/bash

az network vnet create -g ${RESOURCE_GROUP} -n DcosCustomVNET --address-prefixes 10.100.0.0/24 10.200.0.0/24 --subnet-name DcosMasterSubnet --subnet-prefix 10.100.0.0/24
az network vnet subnet create --name DcosAgentSubnet --address-prefix 10.200.0.0/24 -g ${RESOURCE_GROUP} --vnet-name DcosCustomVNET

tempfile="$(mktemp)"
trap "rm -rf \"${tempfile}\"" EXIT

jq ".properties.masterProfile.vnetSubnetId = \"/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/DcosCustomVNET/subnets/DcosMasterSubnet\"" ${CLUSTER_DEFINITION} > $tempfile && mv $tempfile ${CLUSTER_DEFINITION}

indx=0
for poolname in `jq -r '.properties.agentPoolProfiles[].name' "${CLUSTER_DEFINITION}"`; do
  jq ".properties.agentPoolProfiles[$indx].vnetSubnetId = \"/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/DcosCustomVNET/subnets/DcosAgentSubnet\"" ${CLUSTER_DEFINITION} > $tempfile && mv $tempfile ${CLUSTER_DEFINITION}
  indx=$((indx+1))
done