# clusters
k8sをもぐもぐたべよう

## 当レポジトリで必要なセットアップ方法
### Proxmox
#### ユーザとロール作成
- 以下のように叩けば認証情報を作成できる。
```bash
pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.GuestAgent.Audit VM.GuestAgent.FileRead VM.GuestAgent.FileSystemMgmt VM.GuestAgent.FileWrite VM.GuestAgent.Unrestricted VM.PowerMgmt User.Modify"
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role Terraform
```

#### 認証方法
- 環境変数で設定する。トークン作成コマンドで生成されたトークン(value)を設定する。
- `export` コマンドの内容はterraformの実行時に必要なため各自メモを取ること。
```bash
pveum user token add terraform@pve provider --privsep=0

export PROXMOX_VE_ENDPOINT='https://XXX.XXX.XXX.XXX:8006/api2/json'
export PROXMOX_VE_API_TOKEN='terraform@pve!provider=生成されたトークン'
```

#### 鍵の配置
- Discordのチャンネルにて鍵を入手し、以下のディレクトリに配置する。
    - `./ansible/roles/01-os-init/files/keys/`
        - `k8s_homelab_ed25519`
        - `k8s_homelab_ed25519.pub`

### Terraform
#### インストール
下記からterraformのバージョン管理を行うツールをインストールする。
> https://github.com/tfversion/tfversion

- インストール後に以下のコマンドを実行する
```bash
cd ./terraform/

echo "export PATH=/home/${USER}/.tfversion/bin:$PATH" >> ~/.bashrc
tfversion install --required
tfversion use --required
terraform version
```

### Ansible
#### インストール
- 以下のコマンドを実行する
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv sync
source .venv/bin/activate
```

### kubenetes
#### インストール(kubectl)
- 以下のコマンドを実行する
```bash
KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
mkdir -pv /home/${USER}/bin/kubectl_${KUBE_VERSION}
curl -L "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl" -o /home/${USER}/bin/kubectl_${KUBE_VERSION}/kubectl
chmod +x /home/${USER}/bin/kubectl_${KUBE_VERSION}/kubectl
ln -s /home/${USER}/bin/kubectl_${KUBE_VERSION}/kubectl /home/${USER}/bin/kubectl
```

#### インストール(ktop)
- 以下サイトからktopのバイナリをダウンロードする
```bash
KTOP_VERSION=v0.4.1
mkdir -pv /home/${USER}/bin/ktop_${KTOP_VERSION}
curl -L "https://github.com/vladimirvivien/ktop/releases/download/${KTOP_VERSION}/ktop_${KTOP_VERSION}_linux_amd64.tar.gz" | tar -xz -C /home/${USER}/bin/ktop_${KTOP_VERSION}
chmod +x /home/${USER}/bin/ktop_${KTOP_VERSION}/ktop
ln -s /home/${USER}/bin/ktop_${KTOP_VERSION}/ktop /home/${USER}/bin/ktop
```


#### インストール(helm)
- 以下サイトからhelmのバイナリをダウンロードする
> https://github.com/helm/helm/releases
```bash
HELM_VERSION=v3.19.0
mkdir -pv /home/${USER}/bin/helm_${HELM_VERSION}
curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz -C /home/${USER}/bin/helm_${HELM_VERSION}
chmod +x /home/${USER}/bin/helm_${HELM_VERSION}/linux-amd64/helm
ln -s /home/${USER}/bin/helm_${HELM_VERSION}/linux-amd64/helm /home/${USER}/bin/helm
helm plugin install https://github.com/databus23/helm-diff
```

#### インストール(helmfile)
- 以下サイトからhelmfileのバイナリをダウンロードする
> https://github.com/helmfile/helmfile/releases
```bash
HELMDILE_VERSION=1.1.7
mkdir -pv /home/${USER}/bin/helmfile_v${HELMDILE_VERSION}
curl -L "https://github.com/helmfile/helmfile/releases/download/v${HELMDILE_VERSION}/helmfile_${HELMDILE_VERSION}_linux_amd64.tar.gz" | tar -xz -C /home/${USER}/bin/helmfile_v${HELMDILE_VERSION}
chmod +x /home/${USER}/bin/helmfile_v${HELMDILE_VERSION}/helmfile
ln -s /home/${USER}/bin/helmfile_v${HELMDILE_VERSION}/helmfile /home/${USER}/bin/helmfile
```

#### インストール(cilium-cli)
- 以下サイトからcilium-cliのバイナリをダウンロードする
> https://github.com/cilium/cilium-cli/releases
```bash
CILIUM_CLI_VERSION=v0.18.7
mkdir -pv /home/${USER}/bin/cilium-cli_${CILIUM_CLI_VERSION}
curl -L "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz" | tar -xz -C /home/${USER}/bin/cilium-cli_${CILIUM_CLI_VERSION}
chmod +x /home/${USER}/bin/cilium-cli_${CILIUM_CLI_VERSION}/cilium
ln -s /home/${USER}/bin/cilium-cli_${CILIUM_CLI_VERSION}/cilium /home/${USER}/bin/cilium
```

#### インストール(hubble)
- 以下サイトからhubbleのバイナリをダウンロードする
> https://github.com/cilium/hubble/releases
```bash
HUBBLE_VERSION=v1.18.0
mkdir -pv /home/${USER}/bin/hubble_${HUBBLE_VERSION}
curl -L "https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-amd64.tar.gz" | tar -xz -C /home/${USER}/bin/hubble_${HUBBLE_VERSION}
chmod +x /home/${USER}/bin/hubble_${HUBBLE_VERSION}/hubble
ln -s /home/${USER}/bin/hubble_${HUBBLE_VERSION}/hubble /home/${USER}/bin/hubble
```

### PATHや補完の設定
- 以下のコマンドを実行する
```bash
echo "export PATH=/home/${USER}/bin:$PATH" >> ~/.bashrc
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(helm completion bash)" >> ~/.bashrc
echo "source <(helmfile completion bash)" >> ~/.bashrc
echo "source <(cilium completion bash)" >> ~/.bashrc
echo "source <(hubble completion bash)" >> ~/.bashrc

source ~/.bashrc
```
