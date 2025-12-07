# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a homelab infrastructure-as-code repository for managing a Kubernetes cluster on Proxmox VE. It uses Terraform for VM provisioning, Ansible for configuration management, and Helmfile for Kubernetes application deployment.

## Architecture

```
homelab/
├── ansible/          # Configuration management for VMs and Kubernetes
├── kubernetes/       # Helm charts and Kubernetes manifests
│   ├── manifests/system/    # System components (Cilium, Traefik, etc.)
│   └── manifests/application/
├── terrafrom/        # VM provisioning on Proxmox VE (note: typo in dir name)
├── proxmox/          # Proxmox-related utilities (etcd registration)
└── misc/             # Shell scripts for maintenance
```

**Key Stack:**
- **Proxmox VE**: Hypervisor with Terraform provider (bpg/proxmox)
- **Kubernetes CNI**: Cilium
- **Ingress**: Traefik
- **Storage**: Longhorn + MinIO (S3-compatible)
- **Monitoring**: kube-prometheus-stack + Vector (logging)
- **GitOps**: ArgoCD
- **Certificates**: cert-manager

## Common Commands

### Python/Ansible Setup
```bash
uv sync
source .venv/bin/activate
```

### Ansible
```bash
cd ansible/
export APPLY_STAGE=dev

# Lint
ansible-lint

# Dry-run
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./00-all.yml --check --diff

# Apply
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./00-all.yml --diff

# Individual playbooks: 01-os-init.yml, 02-basic-vms.yml, 03-kubernetes.yml
# Special operations: 90-kubernetes-upgrade.yml, 99-kubernetes-add-worker.yml, 99-pkg-upgrade.yml, 99-reboot.yml
```

### Terraform
```bash
cd terrafrom/

terraform init
terraform plan -var-file=var_files/ignore/${USER}.tfvars
terraform apply -var-file=var_files/ignore/${USER}.tfvars
```

### Kubernetes (Helmfile)
```bash
cd kubernetes/

# Deploy system components in order
helmfile apply -f ./manifests/system/00_init/
helmfile apply -f ./manifests/system/cilium/
helmfile apply -f ./manifests/system/cert-manager/
helmfile apply -f ./manifests/system/traefik/
helmfile apply -f ./manifests/system/longhorn/
# ... then other components

# View Helm chart values
helm show values <repo>/<chart> --version X.Y.Z
```

## Environment Variables

Proxmox API authentication required for Terraform:
```bash
export PROXMOX_VE_ENDPOINT='https://XXX.XXX.XXX.XXX:8006/api2/json'
export PROXMOX_VE_API_TOKEN='terraform@pve!provider=<token>'
```

## Ansible-lint Configuration

Skip rules defined in `ansible/.ansible-lint`:
- `fqcn[action-core]`, `fqcn` - FQCN not required
- `name[template]` - Jinja2 in task names allowed
- `no-changed-when` - changed_when:false allowed
- `role-name` - Flexible role naming

## Dependency Management

- **Renovate** is configured for automated dependency updates (Terraform providers auto-merge for minor/patch)
- Python dependencies managed via `uv` (pyproject.toml)
