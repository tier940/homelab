# k3s install on lxc container
## pve
`vim /etc/pve/lxc/$ID.conf`
```
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop:
lxc.mount.auto: "proc:rw sys:rw"
```

* * *

## lxc
`apt update && apt install -y vim curl`
```bash
cat <<EOF | sudo tee -a /etc/hosts
# k8s host address
172.16.8.0 k8s-controller-1
172.16.8.10 k8s-worker-1
172.16.8.11 k8s-worker-2
EOF
```

`vim /etc/rc.local`
```bash
#!/bin/sh -e

# Kubeadm 1.15 needs /dev/kmsg to be there, but it's not in lxc, but we can just use /dev/console instead
# see: https://github.com/kubernetes-sigs/kind/issues/662
if [ ! -e /dev/kmsg ]; then
    ln -s /dev/console /dev/kmsg
fi

# https://medium.com/@kvaps/run-kubernetes-in-lxc-container-f04aa94b6c9c
mount --make-rshared /
```

```bash
chmod +x /etc/rc.local
reboot
```

* * *

## k3s install
```bash
k3sup install \
    --cluster \
    --host k8s-master \
    --user root \
    --ssh-key $HOME/.ssh/yotsunagi_proxmox \
    --k3s-channel stable \
    --k3s-extra-args "--disable servicelb --disable traefik"
```

```bash
k3sup join \
    --server \
    --host k8s-node1 \
    --user root \
    --ssh-key $HOME/.ssh/yotsunagi_proxmox \
    --server-host k8s-master \
    --server-user root \
    --k3s-channel stable \
    --k3s-extra-args "--disable servicelb --disable traefik"
```

```bash
k3sup join \
    --server \
    --host k8s-node2 \
    --user root \
    --ssh-key $HOME/.ssh/yotsunagi_proxmox \
    --server-host k8s-master \
    --server-user root \
    --k3s-channel stable \
    --k3s-extra-args "--disable servicelb --disable traefik"
```
