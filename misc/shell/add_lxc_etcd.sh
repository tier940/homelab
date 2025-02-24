#!/usr/bin/env bash

# Extract running LXC containers, format hostname as lowercase with hyphens instead of underscores, and retrieve IP address
for vmid in $(lxc-ls --active); do
  name=$(pvesh get /nodes/pve01/lxc/${vmid}/config --output-format json | jq -r '.hostname' | tr '[:upper:]' '[:lower:]' | tr '_' '-')
  ip=$(pvesh get /nodes/pve01/lxc/${vmid}/interfaces --output-format json | jq -r .[1].inet | cut -d'/' -f1)
  echo "Adding ${name} with IP ${ip} to etcd"
  etcdctl --endpoints=172.16.0.2:2379 put /skydns/si/f5/tier/${name} "{\"host\":\"${ip}\",\"ttl\":60}"
done
