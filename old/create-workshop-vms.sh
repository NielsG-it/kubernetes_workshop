#!/usr/bin/env bash
#
# create-workshop-vms.sh
#
# A script to create X Ubuntu VMs for a workshop using Azure CLI.

# --- Configuration section ---
# Change these values to fit your scenario:
RESOURCE_GROUP="myWorkshopRG"          # The name of the Azure resource group
LOCATION="westeurope"                      # Azure region (e.g. eastus, westus, etc.)
VM_SIZE="Standard_B2s"                 # VM size/type
ADMIN_USERNAME="bitbash"             # Admin username for the VMs
ADMIN_PASSWORD="Superbitbash1234!"      # Admin password (only for workshop/testing)
VM_COUNT=30                             # Number of VMs to create

# --- End of configuration ---

# Exit on any error
set -e

echo "==========================================="
echo "Azure Workshop VM Creation Script"
echo "==========================================="
echo "Resource Group:  $RESOURCE_GROUP"
echo "Location:        $LOCATION"
echo "VM Size:         $VM_SIZE"
echo "Admin Username:  $ADMIN_USERNAME"
echo "Password:        $ADMIN_PASSWORD"
echo "Number of VMs:   $VM_COUNT"
echo "==========================================="

# 1. Create the resource group if it does not exist
echo "Creating (or reusing) resource group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# 2. Create VMs in a loop
echo "Starting VM creation..."
for i in $(seq 1 $VM_COUNT); do
    VM_NAME="workshopVM$i"
    echo "-------------------------------------------"
    echo "Creating VM: $VM_NAME"

    # Create the VM
    # --image UbuntuLTS ensures we get the latest Ubuntu LTS version
    IP_ADDRESS=$(az vm create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM_NAME" \
        --image "Ubuntu2404" \
        --size "$VM_SIZE" \
        --admin-username "$ADMIN_USERNAME" \
        --admin-password "$ADMIN_PASSWORD" \
        --authentication-type "password" \
        --public-ip-sku "Standard" \
        --query "publicIpAddress" \
        --output tsv)

    # Open the SSH port for each VM
    az vm open-port --port 22 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --output none

    echo "VM: $VM_NAME created."
    echo "Public IP Address: $IP_ADDRESS"
    echo "-------------------------------------------"

    # (Optional) Collect details for final summary
    VM_INFO[$i]="$VM_NAME $IP_ADDRESS"
done

# 3. Summary output
echo ""
echo "==========================================="
echo " All Azure VMs Created Successfully!       "
echo "==========================================="
for i in $(seq 1 $VM_COUNT); do
    IFS=' ' read -r NAME IP <<< "${VM_INFO[$i]}"
    echo "VM Name: $NAME"
    echo "  Public IP:      $IP"
    echo "  Username:       $ADMIN_USERNAME"
    echo "  Password:       $ADMIN_PASSWORD"
    echo "  SSH Command:    ssh $ADMIN_USERNAME@$IP"
    echo "-------------------------------------------"
done

echo "Done!"