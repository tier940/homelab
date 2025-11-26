# Suggested Commands

## Python/Ansible Environment Setup
```bash
uv sync
source .venv/bin/activate
```

## Ansible Commands

### Set Environment
```bash
export APPLY_STAGE=dev  # or other environment
```

### Lint
```bash
cd ansible/
ansible-lint
```

### Dry-run (Check Mode)
```bash
cd ansible/
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./00-all.yml --check --diff
```

### Apply
```bash
cd ansible/
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./00-all.yml --diff
```

### Individual Playbooks
- `01-os-init.yml` - OS initialization
- `02-basic-vms.yml` - Basic VM configuration
- `03-kubernetes.yml` - Kubernetes setup

### Special Operations
- `90-kubernetes-upgrade.yml` - Kubernetes upgrade
- `99-kubernetes-add-woker.yml` - Add worker node
- `99-pkg-upgrade.yml` - Package upgrade
- `99-reboot.yml` - Reboot nodes

## Terraform Commands

### Set Environment Variables
```bash
export PROXMOX_VE_ENDPOINT='https://XXX.XXX.XXX.XXX:8006/api2/json'
export PROXMOX_VE_API_TOKEN='terraform@pve!provider=<token>'
```

### Run Terraform
```bash
cd terrafrom/
terraform init
terraform plan -var-file=var_files/ignore/${USER}.tfvars
terraform apply -var-file=var_files/ignore/${USER}.tfvars
```

## Kubernetes (Helmfile) Commands

### Deploy System Components (in order)
```bash
cd kubernetes/
helmfile apply -f ./manifestes/system/00_init/
helmfile apply -f ./manifestes/system/cilium/
helmfile apply -f ./manifestes/system/cert-manager/
helmfile apply -f ./manifestes/system/traefik/
helmfile apply -f ./manifestes/system/longhorn/
# ... then other components
```

### View Helm Chart Values
```bash
helm show values <repo>/<chart> --version X.Y.Z
```

## Utility Commands (Linux)
```bash
git status
ls -la
find . -name "*.yml"
grep -r "pattern" .
```
