## Terraform
### Providers
- Proxmox VEをTerraformで操作するためのPluginの立ち位置。
> https://registry.terraform.io/providers/bpg/proxmox/latest/docs


### applyなどのコマンド
- tfvarsファイルをコピーして認証情報を `pve_auth` に設定する。
- 認証情報を修正後にtfvarsに記載されている `tagsのenv` を自分のIDなどに変更する。 
- またIPアドレスやVMIDは各自で修正すること。
```bash
# init
terraform init

# copy var_files
cp var_files/dev.tfvars var_files/ignore/${USER}.tfvars

# plan
terraform plan -var-file=var_files/ignore/${USER}.tfvars

# apply
terraform apply -var-file=var_files/ignore/${USER}.tfvars -target=module.template
terraform apply -var-file=var_files/ignore/${USER}.tfvars

# destroy
terraform destroy -var-file=var_files/ignore/${USER}.tfvars
```
