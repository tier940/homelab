# k8s install apps
## k8s-dashboard
```bash
kubectl -n kubernetes-dashboard create token admin-user
```

## kube-prometheus-stack
- デフォルト値なので変えること
```bash
username: admin
password: prom-operator
```

## Cert-Manager
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager --create-namespace -n cert-manager --set installCRDs=true
```

## Kubeshark
```bash
helm repo add kubeshark https://helm.kubeshark.co
helm repo update
helm upgrade --install kubeshark kubeshark/kubeshark --create-namespace -n kubeshark
kubectl get svc -n kubeshark

kubectl apply -f ./systems/network/ingress/all/kubeshark-ingress.yaml
```

## サンプルアプリケーション
### Nginx
```bash
kubectl apply -f ./apps/sample/nginx-deploy.yaml

#kubectl patch svc nginx-service -p '{"spec": {"type": "LoadBalancer"}}'
#kubectl patch svc nginx-service -p '{"spec": {"type": "ClusterIP"}}'
kubectl apply -f ./systems/network/ingress/all/nginx-ingress.yaml

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

<details>

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

### Istio Ingress Gateway
```bash
kubectl create namespace istio-ingress
helm install istio-ingress istio/gateway -n istio-ingress --wait

helm delete istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress
```

#### istio-ingressgatewayがpending
- MetalLBが使える環境であればLoadBalancerが使えるのでむしろ問題ない
```bash
kubectl get svc -n istio-system

# 以下の方法で解決
kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "NodePort"}}'

# 戻す場合
kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "LoadBalancer"}}'
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

</details>
