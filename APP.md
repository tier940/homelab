# k8s install apps
## Istioのインストール
- 2024/10/25現在のアドオンバージョンは 1.23.2 だった
```bash
istioctl install
kubectl get deployments -n istio-system --output wide
```

### Kiali
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/kiali.yaml
kubectl get svc -n istio-system
istioctl dashboard kiali
```

### Jaeger
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/jaeger.yaml
kubectl get svc -n istio-system
istioctl dashboard jaeger
```

### Grafana
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/grafana.yaml
kubectl get svc -n istio-system
istioctl dashboard grafana
```

### Prometheus
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.23.2/samples/addons/prometheus.yaml
kubectl get svc -n istio-system
istioctl dashboard prometheus
```

## k8s-dashboard
```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
kubectl get svc -n kubernetes-dashboard
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

kubectl apply -f k8s-dashboard/dashboard-adminuser.yaml
kubectl apply -f k8s-dashboard/dashboard-rbac.yaml
kubectl -n kubernetes-dashboard create token admin-user
```

## ArgoCD
- 2024/10/25現在は 2.12.6 だった
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/tags/v2.12.6/manifests/ha/install.yaml
kubectl get svc -n argocd
```

## サンプルアプリケーション
```bash
kubectl apply -f ./sample-deploy.yaml
kubectl port-forward services/nginx-service 8080:80
kubectl delete -f ./sample-deploy.yaml
```
