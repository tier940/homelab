##
### Providers
- Proxmox VEをTerraformで操作するためのPluginの立ち位置。
> https://registry.terraform.io/providers/bpg/proxmox/latest/docs

### 認証情報
- 環境変数で設定する。また以下の値は適宜変更すること。
```bash
export PROXMOX_VE_ENDPOINT="https://XXX.XXX.XXX.XXX:8006/api2/json"
export PROXMOX_VE_USERNAME="terraform-prov@pve"
export PROXMOX_VE_PASSWORD='a-strong-password'
```

#### 認証情報の作成例
- 以下のように叩けば認証情報を作成できる。このとき **パスワードは必ず変える** こと!!
```bash
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
pveum user add terraform-prov@pve --password a-strong-password
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

### Install
下記からterraformのバージョン管理を行うツールをインストールする
> https://github.com/tfversion/tfversion

- インストール後に以下のコマンドを実行する
```bash
cd ./proxmox/terraform/

tfversion install --required
terraform version
```

### Setup
```bash
# init
terraform init

# plan
terraform plan -var-file=var_files/dev.tfvars

# apply
terraform apply -var-file=var_files/dev.tfvars

# destroy
terraform destroy -var-file=var_files/dev.tfvars
```
