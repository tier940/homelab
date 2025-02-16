## Cilium
```bash
kubectl kustomize --enable-helm infra/network/cilium | kubectl apply -f -
```

### Trouble Shooting
```bash
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
kubectl -n kube-system rollout restart ds/cilium-envoy

cilium status
cilium connectivity test

kubectl delete ns cilium-test-1
```

## ArgoCD
```bash
kubectl kustomize --enable-helm infra/controllers/argocd | kubectl apply -f -
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl apply -k infra
kubectl apply -k sets
```

## Tips
```bash
kubectl run -it --rm --restart=Never --image=ubuntu:24.04 ubuntu

kubectl run -it --rm --restart=Never --image=infoblox/dnstools:latest dnstools
```
