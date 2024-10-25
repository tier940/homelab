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

`vim /etc/hosts`
```bash
# k8s host address
172.16.8.0 k8s-master
172.16.8.10 k8s-node1
172.16.8.11 k8s-node2
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

## lab
### setup
```bash
mv /root/kubeconfig /home/tier940/.kube/config
mkdir -p /home/tier940/.kube
chown tier940:tier940 /home/tier940/.kube/ -R
kubectl config use-context default
kubectl get node -o wide

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(helm completion bash)" >> ~/.bashrc
echo "source <(istioctl completion bash)" >> ~/.bashrc
echo "source <(kustomize completion bash)" >> ~/.bashrc
source ~/.bashrc
```

### MetalLB
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
kubectl apply -f MetalLB/addresspool.yaml
```

### Istio
```bash
istioctl install
kubectl get deployments -n istio-system --output wide
```

#### Kiali
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/kiali.yaml
kubectl get svc -n istio-system
istioctl dashboard kiali
```

#### Jaeger
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/jaeger.yaml
kubectl get svc -n istio-system
istioctl dashboard jaeger
```

#### Grafana
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/grafana.yaml
kubectl get svc -n istio-system
istioctl dashboard grafana
```

#### Prometheus
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/prometheus.yaml
kubectl get svc -n istio-system
istioctl dashboard prometheus
```

#### Loki
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/loki.yaml
kubectl get svc -n istio-system
```

### k8s-dashboard
```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
kubectl get svc -n kubernetes-dashboard
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

kubectl apply -f k8s-dashboard/dashboard-adminuser.yaml
kubectl apply -f k8s-dashboard/dashboard-rbac.yaml
kubectl -n kubernetes-dashboard create token admin-user
```

### ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/tags/v2.12.4/manifests/ha/install.yaml
kubectl get svc -n argocd

kubectl -n argocd port-forward svc/argocd-server 8443:443 --address='0.0.0.0'
kubectl -n argocd get secrets argocd-initial-admin-secret -ojsonpath={.data.password} | base64 -d
```
