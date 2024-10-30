# lab setup
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
echo "source <(cilium completion bash)" >> ~/.bashrc
source ~/.bashrc
```

# k8s install on vm
## カーネルパラメータの追加
```bash
tee /etc/modules-load.d/containerd.conf << EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

tee /etc/sysctl.d/kubernetes.conf << EOF 
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1 
net.ipv4.ip_forward = 1 
EOF

sysctl --system
```

## 日本時間に変更
```bash
timedatectl set-timezone Asia/Tokyo
```

## hostsファイルの編集
```bash
cat <<EOF | sudo tee -a /etc/hosts
# k8s host address
172.16.8.0 k8s-master
172.16.8.10 k8s-node1
172.16.8.11 k8s-node2
EOF
```

## Containerd Runtimeをインストール
```bash
apt update && apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg 
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update && apt install -y containerd.io

containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1 
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
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

## Kubectl / Kubeadm / Kubeletをインストール
```bash
apt update 
apt install -y kubelet kubeadm kubectl 
apt-mark hold kubelet kubeadm kubectl
```

## コントロールプレーンの作成
- ひとまずデフォルトの設定で初期化
```bash
kubeadm init --control-plane-endpoint 172.16.8.0 \
    --pod-network-cidr=10.1.0.0/16
```

### コントロールプレーン作成後
```bash
mkdir -p $HOME /.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME /.kube/config
sudo chown $( id -u):$( id -g) $HOME /.kube/config
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
kubeadm token create
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

## CNIプラグインのインストール
### Calicoを使用する場合
- 2024/10/25現在は v3.28.2 だった
```bash
wget -O ./cni-calico.yaml https://raw.githubusercontent.com/projectcalico/calico/refs/tags/v3.28.2/manifests/calico.yaml
kubectl apply -f ./cni-calico.yaml
```

### Ciliumを使用する場合
```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
helmfile sync -f ./cni-helmfile-cilium.yaml
kubectl get svc -n kube-system
```

## MetricsServerのインストール
- 2024/10/25現在は v0.7.2 だった
```bash
wget -O metrics-server-components.yaml https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml
kubectl apply -f metrics-server-components.yaml
kubectl get deployment metrics-server -n kube-system
```

### metrics-serverが起動しない
- deployment.appsに以下を追加すると起動する
```bash
command:
- /metrics-server
- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP
```

### MetalLB
```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb --create-namespace --namespace metallb-system --set crds.create=true

kubectl apply -f ./metallb/addresspool.yaml
```

### istio-ingressgatewayがpending
- MetalLBが使える環境であればLoadBalancerが使えるのでむしろ問題ない
```bash
kubectl get svc -n istio-system

# 以下の方法で解決
kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "NodePort"}}'

# 戻す場合
kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "LoadBalancer"}}'
```
