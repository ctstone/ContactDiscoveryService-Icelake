#! /usr/bin/env bash

set -e

RG=jamb-signal-dev
VM=jamb-dev-signal-cdsi-2
DNS=jamb-dev-signal-cdsi-2
REGION=southcentralus
SIZE=Standard_DC24s_v3
DOMAIN=directory.jamb.ai
DOMAIN_EMAIL=chris@jamb.ai

az group create --resource-group $RG --location $REGION || true

# Check availability:
# az vm list-skus --location $REGION --size $SIZE --all --output table
# az vm list-skus --size $SIZE --all --output table

cp cloud-init.template.yml cloud-init.yml
sed -i "s/__DOMAIN__/$DOMAIN/g" cloud-init.yml
sed -i "s/__DOMAIN_EMAIL__/$DOMAIN_EMAIL/g" cloud-init.yml

# Create VM
az vm create \
  -g $RG \
  -n $VM \
  --size $SIZE \
  --location $REGION \
  --image Ubuntu2204 \
  --data-disk-sizes-gb 100 \
  --public-ip-address-dns-name $DNS \
  --custom-data ./cloud-init.yml \
  --ssh-key-values @$(realpath ~/.ssh/*.pub)

az vm open-port -g $RG -n $VM --port 443,80

# Might need this after VM starts up:
# - sudo vi /etc/default/grub
# - GRUB_CMDLINE_LINUX_DEFAULT="quiet splash sgx=1"
# - sudo reboot

rm cloud-init.yml