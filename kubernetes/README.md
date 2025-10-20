## kubernetes
### ansibleでセットアップできるまでの手順
```bash
kubectl apply -f ./manifestes/system/homelab-admin.yaml
kubectl apply -f ./manifestes/system/minio-secret.yaml
kubectl apply -f ./manifestes/system/coredns-cm.yaml


helmfile apply -f ./manifestes/system/00_init/
kubectl apply -k ./manifestes/system/cilium/manifest/

helmfile apply -f ./manifestes/system/minio/
helmfile apply -f ./manifestes/system/vector/
helmfile apply -f ./manifestes/system/traefik/
helmfile apply -f ./manifestes/system/kubernetes-dashboard/
helmfile apply -f ./manifestes/system/kube-prometheus-stack/
```

### kubernetes-dashboard
- kubernetes-dashboardのコンソールにアクセスするためのコマンド
```bash
kubectl -n kube-system describe secrets $(kubectl -n kube-system get secrets | grep homelab-admin | awk '{print $1}')
echo "https://localhost:8443/"; kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy --address 0.0.0.0 8443:443
https://localhost:8443/
```

### Tips
- 各種のvalue.yamlは以下のリポジトリから取得することができる

#### cilium
- ciliumのテンプレートvalue
> https://github.com/cilium/cilium/tree/main/install/kubernetes/cilium

#### external-dns
- external-dnsのテンプレートvalue
> https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns

#### kubernetes-dashboard
- kubernetes-dashboardのテンプレートvalue
> https://github.com/kubernetes/dashboard/tree/master/charts/kubernetes-dashboard


##### Tips
```bash
kubectl get pvc -A
kubectl get pv -A
kubectl get storageclass -A
kubectl get pvc -A | grep -E 'Pending|Failed' | awk '{print "kubectl delete pvc " $2 " -n " $1}' | bash
```

```bash
kubectl run -it --rm --restart=Never --image=ubuntu:24.04 ubuntu

kubectl run -it --rm --restart=Never --image=infoblox/dnstools:latest dnstools

kubectl run -it --rm --restart=Never --image=ghcr.io/tier940/desktop-lxde:v1.1.0 lxde
kubectl port-forward pod/lxde 5901:5901
```
