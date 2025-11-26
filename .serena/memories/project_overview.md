# Homelab Project Overview

## Purpose
Infrastructure-as-code repository for managing a Kubernetes cluster on Proxmox VE.

## Tech Stack
- **Hypervisor**: Proxmox VE (Terraform provider: bpg/proxmox)
- **Configuration Management**: Ansible
- **Infrastructure Provisioning**: Terraform
- **Container Orchestration**: Kubernetes
  - **CNI**: Cilium
  - **Ingress**: Traefik
  - **Storage**: Longhorn + MinIO (S3-compatible)
  - **Monitoring**: kube-prometheus-stack + Vector (logging)
  - **GitOps**: ArgoCD
  - **Certificates**: cert-manager

## Repository Structure

```
homelab/
├── ansible/           # Configuration management for VMs and Kubernetes
│   ├── roles/         # Ansible roles
│   │   ├── 01-os-init/       # OS initialization
│   │   ├── 02-basic-vms/     # Basic VM setup (DNS, Proxy, Keycloak)
│   │   └── 03-kubernetes/    # Kubernetes setup
│   ├── inventories/   # Inventory files per environment
│   └── *.yml          # Playbooks
├── kubernetes/        # Helm charts and Kubernetes manifests
│   ├── manifestes/system/      # System components
│   │   ├── 00_init/           # Initialization
│   │   ├── cilium/            # CNI
│   │   ├── cert-manager/      # TLS certificates
│   │   ├── traefik/           # Ingress controller
│   │   ├── longhorn/          # Storage
│   │   ├── minio/             # S3-compatible storage
│   │   ├── kube-prometheus-stack/  # Monitoring
│   │   └── vector/            # Logging
│   └── manifestes/application/ # Application deployments
├── terrafrom/         # VM provisioning on Proxmox VE (typo in dir name)
│   ├── modules/       # Terraform modules
│   ├── var_files/     # Variable files
│   └── *.tf           # Terraform configs
├── proxmox/           # Proxmox-related utilities (etcd registration)
├── vyos/              # VyOS router configuration
└── misc/              # Shell scripts for maintenance
```

## Python Environment
- Python >= 3.13
- Managed via `uv` package manager
- Dependencies: ansible, ansible-core, ansible-lint, cryptography

## Dependency Management
- **Renovate** configured for automated dependency updates
- Terraform providers auto-merge for minor/patch updates
