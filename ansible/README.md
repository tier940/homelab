## Ansible
### apply前の確認
- 初回実行のみ以下を実行する。sshの初回接続時に聞かれるのを回避してくれる。
```bash
cd ./ansible/

export ANSIBLE_HOST_KEY_CHECKING=false
export APPLY_STAGE=dev
ansible all -m ping -i ./inventories/${APPLY_STAGE}/${USER}.yml
unset ANSIBLE_HOST_KEY_CHECKING
```

### applyなどのコマンド
- ファイルをコピーして `genvのenv` を自分のIDなどに変更する。 
- またIPアドレスは各自で修正すること。
```bash
cp ./group_vars/${APPLY_STAGE}.yml ./group_vars/${USER}.yml

# plan(dry-run)
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./00-all.yml --check --diff

# apply
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./00-all.yml --diff
```

#### 個別に実行する場合
```bash
# plan(dry-run)
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./01-os-init.yml --check --diff
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./02-basic-vms.yml --check --diff
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./03-kubernetes.yml --check --diff

# apply
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./01-os-init.yml --diff
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./02-basic-vms.yml --diff
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./03-kubernetes.yml --diff
```

### 特殊な操作
#### Workerノード追加
```bash
# plan(dry-run)
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./99-kubernetes-add-woker.yml --check --diff

# apply
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./99-kubernetes-add-woker.yml --diff
```

#### Kubernetesバージョンアップグレード
- `group_vars/${USER}.yml` の `genv.kubernetes.kube_version` と `genv.kubernetes.kubeadm.kube_version` を更新してから実行する
- Control planeノード、Workerノードの順に1台ずつアップグレードされる

```bash
# plan(dry-run) - アップグレード対象の確認
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./90-kubernetes-upgrade.yml --check --diff

# apply - 実際のアップグレード実行
ansible-playbook -i ./inventories/${APPLY_STAGE}/${USER}.yml ./90-kubernetes-upgrade.yml --diff
```

### Tips
#### 証明書の用途について
- 以下を確認すること
> https://kubernetes.io/docs/setup/best-practices/certificates/
