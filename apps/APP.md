# k8s install apps
## Istioのインストール
- 2024/10/25現在のアドオンバージョンは 1.23.3 だった
```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default
helm install istiod istio/istiod -n istio-system --wait

helm ls -n istio-system
kubectl get deployments -n istio-system --output wide

kubectl label namespace default istio-injection=enabled

helm delete istio-base -n istio-system
kubectl delete namespace istio-system
kubectl label namespace default istio-injection-
kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
```

### Istio ingress gatewayのインストール
```bash
kubectl create namespace istio-ingress
helm install istio-ingress istio/gateway -n istio-ingress --wait

helm delete istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress
```

<details>

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

</details>

## k8s-dashboard
```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace -n kubernetes-dashboard
kubectl get svc -n kubernetes-dashboard
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

kubectl apply -f k8s-dashboard/dashboard-adminuser.yaml
kubectl apply -f k8s-dashboard/dashboard-rbac.yaml
kubectl -n kubernetes-dashboard create token admin-user
```

## ArgoCD
- 2024/10/25現在は 2.12.6 だった
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd --create-namespace -n argocd
kubectl get svc -n argocd

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Prometheus
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/prometheus --create-namespace -n prometheus -f ./apps/values-prometheus-local.yaml
kubectl get svc -n prometheus
```

## kube-prometheus-stack
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helmfile sync -f ./apps/kube-prometheus-stack/helmfile.yaml

kubectl patch svc -n prometheus kube-prometheus-stack-grafana -p '{"spec": {"type": "LoadBalancer"}}'

username: admin
password: prom-operator

helm uninstall -n prometheus prometheus-grafana
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd probes.monitoring.coreos.com
kubectl delete crd prometheusagents.monitoring.coreos.com
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd scrapeconfigs.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd thanosrulers.monitoring.coreos.com
```

## サンプルアプリケーション
### Nginx
```bash
kubectl apply -f ./apps/sample/nginx-deploy.yaml

kubectl patch svc nginx-service -p '{"spec": {"type": "LoadBalancer"}}'
kubectl patch svc nginx-service -p '{"spec": {"type": "ClusterIP"}}'

kubectl delete -f ./apps/sample/nginx-deploy.yaml
```

### Gitlab
```bash
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab --create-namespace -n gitlab \
    --timeout 600s \
    --set global.hosts.domain=gitlab.example.com \
    --set global.hosts.externalIP=172.16.8.50 \
    --set certmanager-issuer.email=me@example.com
```
