# Code Style and Conventions

## General Editor Settings (.editorconfig)
- **Charset**: UTF-8
- **Line endings**: LF (Unix-style)
- **Indent**: 2 spaces (4 spaces for Markdown)
- **Final newline**: Required
- **Trailing whitespace**: Trimmed (except Markdown)

## Ansible Conventions

### Ansible-lint Configuration
Skip rules in `ansible/.ansible-lint`:
- `fqcn[action-core]`, `fqcn` - FQCN (Fully Qualified Collection Names) not required
- `name[template]` - Jinja2 templates allowed in task names
- `no-changed-when` - `changed_when: false` allowed
- `role-name` - Flexible role naming allowed

### Excluded Paths
- `output/` - Generated output files excluded from linting

## Terraform Conventions
- Variable files stored in `var_files/` directory
- User-specific configs in `var_files/ignore/`
- Provider: bpg/proxmox for Proxmox VE

## Kubernetes/Helmfile Conventions
- System components in `manifestes/system/`
- Application deployments in `manifestes/application/`
- Secrets stored as separate YAML files (e.g., `*-secret.yaml`)
- Deployment order matters for system components

## File Naming
- YAML files use `.yml` extension
- Terraform files use `.tf` extension
- Playbooks prefixed with numbers for ordering (00, 01, 02, etc.)
