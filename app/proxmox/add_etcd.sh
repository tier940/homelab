#!/usr/bin/env bash

# Extract running VMs and format as key,value, converting underscores to hyphens and uppercase to lowercase
qm list | awk '$3 == "running" {print $1 "," tolower(gsub("_", "-", $2) ? $2 : $2)}' > running_vms.txt

# Loop through each running VM to get its IP address
while IFS=',' read -r vmid name; do
  ip=$(pvesh get /nodes/pve01/qemu/${vmid}/agent/network-get-interfaces -o json | jq -r '.result[1]."ip-addresses"[] | select(."ip-address-type" == "ipv4") | ."ip-address"')
  etcdctl --endpoints=172.16.0.2:2379 put /skydns/si/f5/tier/${name} "{\"host\":\"${ip}\",\"ttl\":60}"
done < running_vms.txt
rm running_vms.txt
