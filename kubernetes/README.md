## kubernetes
### ansibleでセットアップできるまでの手順
```bash
helmfile apply -f ./manifestes/system/00_init/
helmfile apply -f ./manifestes/system/cilium/
kubectl apply -k ./manifestes/system/cilium/manifest/

helmfile apply -f ./manifestes/system/longhorn/

helmfile apply -f ./manifestes/system/cert-manager/
kubectl apply -k ./manifestes/system/cert-manager/manifest/

helmfile apply -f ./manifestes/system/minio/
helmfile apply -f ./manifestes/system/vector/
helmfile apply -f ./manifestes/system/traefik/
helmfile apply -f ./manifestes/system/kubernetes-dashboard/
helmfile apply -f ./manifestes/system/kube-prometheus-stack/

helmfile apply -f ./manifestes/system/argocd/
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

kubectl apply -f ./manifestes/system/homelab-admin.yaml
kubectl apply -f ./manifestes/system/vault-secret.yaml
kubectl apply -f ./manifestes/system/minio-secret.yaml
kubectl apply -f ./manifestes/system/grafana-secret.yaml
kubectl apply -f ./manifestes/system/thanos-objstore-secret.yaml
```

### kubernetes-dashboard
- kubernetes-dashboardのコンソールにアクセスするためのコマンド
```bash
kubectl -n kube-system describe secrets $(kubectl -n kube-system get secrets | grep homelab-admin | awk '{print $1}')
echo "https://localhost:8443/"; kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy --address 0.0.0.0 8443:443
https://localhost:8443/
```

### Tips
- 各種のvalue.yamlはhelmコマンドで確認できる

#### ネットワーク関連
```bash
# Cilium CNI
helm show values cilium/cilium --version X.Y.Z

# Traefik Ingress Controller
helm show values traefik/traefik --version X.Y.Z

# External DNS
helm show values external-dns/external-dns --version X.Y.Z
```

#### 監視・ログ関連
```bash
# Prometheus Stack
helm show values prometheus-community/kube-prometheus-stack --version X.Y.Z
helm show values prometheus-community/prometheus-operator-crds --version X.Y.Z

# Loki (ログ集約)
helm show values grafana/loki --version X.Y.Z

# Vector (ログルーター)
helm show values vector/vector --version X.Y.Z
```

#### ストレージ関連
```bash
# Longhorn
helm show values longhorn/longhorn --version X.Y.Z

# MinIO (S3互換オブジェクトストレージ)
helm show values minio-operator/operator --version X.Y.Z
helm show values minio-operator/tenant --version X.Y.Z
```

#### 管理ツール関連
```bash
# ArgoCD (GitOps)
helm show values argo/argo-cd --version X.Y.Z

# Kubernetes Dashboard
helm show values kubernetes-dashboard/kubernetes-dashboard --version X.Y.Z

# Cert Manager (証明書管理)
helm show values jetstack/cert-manager --version X.Y.Z

# Metrics Server
helm show values metrics-server/metrics-server --version X.Y.Z
```

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

kubectl apply -k ./manifestes/application/lxde/
```
