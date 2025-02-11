# lab setup
```bash
mv /root/kubeconfig /home/tier940/.kube/config
mkdir -p /home/tier940/.kube
chown tier940:tier940 /home/tier940/.kube/ -R
kubectl config use-context default
kubectl get node -o wide

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(helm completion bash)" >> ~/.bashrc
echo "source <(cilium completion bash)" >> ~/.bashrc
echo "source <(hubble completion bash)" >> ~/.bashrc
source ~/.bashrc
```

# k8s install on vm
## カーネルパラメータの追加
```bash
cat <<EOF | tee -a /etc/modules-load.d/containerd.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF
modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe overlay

cat <<EOF | tee -a /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
```

## 日本時間に変更
```bash
timedatectl set-timezone Asia/Tokyo
```

## hostsファイルの編集
```bash
cat <<EOF | tee -a /etc/hosts
# k8s host address
172.16.8.0 k8s-controller-1
172.16.8.10 k8s-worker-1
172.16.8.11 k8s-worker-2
EOF
```

## Containerd Runtimeをインストール
```bash
apt update && apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg 
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update && apt install -y containerd.io

containerd config default | tee /etc/containerd/config.toml > /dev/null 2>&1 
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```

### sandboxのバージョンを更新
- registry.k8s.io/pauseで検索して最新のバージョンに更新する
> 2024/10/25現在は 3.10 だった

### containerdの再起動
```bash
systemctl restart containerd
systemctl enable containerd
```

## Kubernetes用のAptリポジトリを追加
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
```

## Kubectl / Kubeadm / Kubeletをインストール
```bash
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

## コントロールプレーンの作成
```bash
kubeadm init --control-plane-endpoint 172.16.8.0 \
    --pod-network-cidr=10.0.0.0/8 \
    --skip-phases=addon/kube-proxy
```

### コントロールプレーン作成後
```bash
mkdir -p $HOME /.kube
cp -i /etc/kubernetes/admin.conf $HOME /.kube/config
chown $( id -u):$( id -g) $HOME /.kube/config
```

## ワーカーノードの追加
- コントロールプレーン作成時に表示されたコマンドを実行
```bash
kubeadm join 172.16.8.0:6443 --token XXXXX --discovery-token-ca-cert-hash sha256:YYYY
```

### トークンの再作成
- どうやらトークンは有効期限があるらしい
    - コントロールプレーンがあるVM(172.16.8.0)で実行する
```bash
kubeadm token create --print-join-command
```

## crdsのインストール(GatewayAPIを試す場合)
```bash
kubectl apply -k ./crds
```

## CNIプラグインのインストール
### Ciliumを使用する場合
```bash
helmfile sync -f ./systems/network/cilium/helmfile.yaml
kubectl get svc -n kube-system

kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium

cilium status
cilium connectivity test

kubectl delete ns cilium-test-1
```

### Calicoを使用する場合
- 2024/10/25現在は v3.28.2 だった
- kube-proxyをスキップしている場合は利用できない
```bash
wget -O ./systems/network/calico/calico.yaml https://raw.githubusercontent.com/projectcalico/calico/refs/tags/v3.28.2/manifests/calico.yaml
kubectl apply -f ./systems/network/calico/calico.yaml
```

## MetricsServerのインストール
```bash
helmfile sync -f ./systems/network/metrics-server/helmfile.yaml
kubectl get svc -n metrics-server
```

### 旧手法
```bash
wget -O ./systems/network/metrics-server/components.yaml https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml
kubectl apply -f ./systems/network/metrics-server/components.yaml
kubectl get deployment metrics-server -n kube-system
```

#### metrics-serverが起動しない
- 以下を追加すると起動する
```yaml
command:
- /metrics-server
- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP
```

## 動作確認用の使い捨てPodを作成
```bash
kubectl run -it --rm --restart=Never --image=ubuntu:22.04 test-pod -- bash
```

<details>

## LoadBalancerの設定
### MetalLB
```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm upgrade --install metallb metallb/metallb --create-namespace -n metallb-system
kubectl get svc -n metallb-system

kubectl apply -f ./systems/network/metallb/addresspool.yaml
```

## Nginx Ingress Controller
```bash
helm repo add ingress https://kubernetes.github.io/ingress
helm repo update
helm upgrade --install ingress ingress/ingress --create-namespace -n ingress
kubectl get svc -n ingress
```

</details>
