## Ansible
### apply前の確認
- 初回実行のみ以下を実行する。sshの初回接続時に聞かれるのを回避してくれる。
```bash
export ANSIBLE_HOST_KEY_CHECKING=false
export APPLY_STAGE=dev
ansible all -m ping -i ./inventory/${APPLY_STAGE}/${USER}.yml
unset ANSIBLE_HOST_KEY_CHECKING
```

### applyなどのコマンド
- ファイルをコピーして `genvのenv` を自分のIDなどに変更する。 
- またIPアドレスは各自で修正すること。
```bash
cp ./group_vars/${APPLY_STAGE}.yml ./group_vars/${USER}.yml

# plan(dry-run)
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./00-all.yml --check --diff

# apply
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./00-all.yml --diff
```

#### 個別に実行する場合
```bash
# plan(dry-run)
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./01-os-init.yml --check --diff
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./02-basic-vms.yml --check --diff
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./03-kubernetes.yml --check --diff

# apply
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./01-os-init.yml --diff
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./02-basic-vms.yml --diff
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./03-kubernetes.yml --diff
```

### 特殊な操作
```bash
# plan(dry-run)
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./99-kubernetes-add-woker.yml --check --diff

# apply
ansible-playbook -i ./inventory/${APPLY_STAGE}/${USER}.yml ./99-kubernetes-add-woker.yml --diff
```

### Tips
#### 証明書の用途について
- 以下を確認すること
> https://kubernetes.io/docs/setup/best-practices/certificates/
