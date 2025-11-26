# Task Completion Checklist

## Before Committing Changes

### For Ansible Changes
1. Run ansible-lint:
   ```bash
   cd ansible/
   ansible-lint
   ```
2. Test with dry-run (if applicable):
   ```bash
   ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml <playbook>.yml --check --diff
   ```

### For Terraform Changes
1. Run terraform fmt:
   ```bash
   cd terrafrom/
   terraform fmt
   ```
2. Run terraform validate:
   ```bash
   terraform validate
   ```
3. Run terraform plan to verify changes:
   ```bash
   terraform plan -var-file=var_files/ignore/${USER}.tfvars
   ```

### For Kubernetes/Helmfile Changes
1. Verify Helm chart syntax:
   ```bash
   helm lint <chart-path>
   ```
2. Run helmfile diff to preview changes:
   ```bash
   helmfile diff -f <helmfile-path>
   ```

## General Checklist
- [ ] Code follows the style conventions (see code_style_conventions.md)
- [ ] No trailing whitespace
- [ ] Files end with newline
- [ ] Indentation is correct (2 spaces for YAML, 4 for Markdown)
- [ ] Sensitive data is not committed (check .gitignore)
