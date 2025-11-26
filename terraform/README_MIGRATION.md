# basic_vms グループ構造への移行手順

既存の `basic_vms` をグループベースの構造に移行するための手順書です。

## 前提条件

- Terraform がインストールされていること
- 既存の Terraform state が存在すること
- バックアップを取得していること（推奨）

## 移行手順

### 1. コードの更新

以下のファイルが更新されています:

- `variables.tf`: basic_vms の型定義を groups 構造に変更
- `dev.tfvars`: instances を groups.{group_name}.instances に再構成
- `main.tf`: グループ構造のフラット化ロジックを追加
- `inventory.tpl`: 動的グループ生成に対応
- `modules/qemu/clone/variables.tf`: base_name にデフォルト値を追加

### 2. tfvars ファイルの構造変更

**変更前:**
```hcl
basic_vms = {
  base_name = ""
  instances = {
    "proxy" = { ... }
    "dns" = { ... }
    "keycloak" = { ... }
  }
}
```

**変更後:**
```hcl
basic_vms = {
  # base_name フィールドは削除
  groups = {
    proxy = {
      instances = {
        "001" = { ... }  # 既存の proxy の設定をコピー
      }
    }
    dns = {
      instances = {
        "001" = { ... }  # 既存の dns の設定をコピー
      }
    }
    keycloak = {
      instances = {
        "001" = { ... }  # 既存の keycloak の設定をコピー
      }
    }
  }
}
```

### 3. Terraform State の移行

既存のVMを削除せずに新しい構造に対応させるため、state を移動します。

```bash
cd terrafrom

# 現在の state を確認
terraform state list | grep basic_vms

# 各VMのstateを新しいキー名に移動
terraform state mv \
  'module.basic_vms.proxmox_virtual_environment_vm.vm["proxy"]' \
  'module.basic_vms.proxmox_virtual_environment_vm.vm["proxy-001"]'

terraform state mv \
  'module.basic_vms.proxmox_virtual_environment_vm.vm["dns"]' \
  'module.basic_vms.proxmox_virtual_environment_vm.vm["dns-001"]'

terraform state mv \
  'module.basic_vms.proxmox_virtual_environment_vm.vm["keycloak"]' \
  'module.basic_vms.proxmox_virtual_environment_vm.vm["keycloak-001"]'
```

### 4. 変更内容の確認

```bash
# 構文チェック
terraform fmt

# 設定の検証
terraform validate

# 変更内容のプレビュー
terraform plan -var-file=var_files/dev.tfvars
```

**期待される変更:**
- VM名の変更（例: `proxy` → `proxy-001`）
- Ansible インベントリファイルの更新
- hosts ファイルの更新
- ネットワークブリッジの変更（環境による）

**VMの再作成は発生しないこと**を確認してください。

### 5. 適用

```bash
terraform apply -var-file=var_files/dev.tfvars
```

## 新しいVMの追加方法

### 同じグループに2台目を追加

```hcl
basic_vms = {
  groups = {
    proxy = {
      instances = {
        "001" = { vmid = 2100, ... }
        "002" = {  # ← 2台目を追加
          target_node    = "pve01"
          vmid           = 2110
          cores          = 2
          memory         = 1024
          network_bridge = "vmbr0"
          disk = [{ ... }]
          initialization = { ... }
        }
      }
    }
  }
}
```

生成されるVM名: `proxy-002`
Ansibleグループ: `proxy`

### 新しいグループを追加

```hcl
basic_vms = {
  groups = {
    proxy = { ... }
    dns = { ... }
    monitoring = {  # ← 新規グループ
      instances = {
        "001" = {
          target_node    = "pve01"
          vmid           = 2200
          cores          = 4
          memory         = 4096
          # ...
        }
      }
    }
  }
}
```

`main.tf` や `inventory.tpl` の修正は不要です。

## トラブルシューティング

### VMが再作成される場合

`terraform state mv` が正しく実行されていない可能性があります。

```bash
# 現在のstateを確認
terraform state list | grep basic_vms

# 期待される出力:
# module.basic_vms.proxmox_virtual_environment_vm.vm["proxy-001"]
# module.basic_vms.proxmox_virtual_environment_vm.vm["dns-001"]
# module.basic_vms.proxmox_virtual_environment_vm.vm["keycloak-001"]
```

古いキー名（`["proxy"]`）が残っている場合は、再度 `terraform state mv` を実行してください。

### バックアップからの復元

```bash
# state のバックアップを取得（事前に実施推奨）
cp terraform.tfstate terraform.tfstate.backup

# 復元が必要な場合
cp terraform.tfstate.backup terraform.tfstate
```

## 参考

- VM名の形式: `{group}-{instance_key}`
- Ansibleインベントリ: グループ名で自動分類
- ホスト名: `{vm_name}.{base_domain}`
