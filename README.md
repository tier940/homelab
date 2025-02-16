# lab setup
```bash
mv /root/kubeconfig /home/tier940/.kube/config
mkdir -p /home/tier940/.kube
chown tier940:tier940 /home/tier940/.kube/ -R
kubectl config use-context default
kubectl get node -o wide

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(helm completion bash)" >> ~/.bashrc
echo "source <(helmfile completion bash)" >> ~/.bashrc
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
tcp_bbr
sch_fq
overlay
EOF
modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe tcp_bbr
modprobe sch_fq
modprobe overlay

cat <<EOF | tee -a /etc/sysctl.d/kubernetes.conf
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv6.tcp_congestion_control=bbr
net.ipv4.ip_forward = 1
net.ipv6.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.dfault.forwarding = 1
net.ipv6.conf.dfault.forwarding = 1
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
- 公式の[URL](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)を参照

### sandboxのバージョンを更新
- registry.k8s.io/pauseで検索して最新のバージョンに更新する
> 2024/10/25現在は 3.10 だった
```bash
containerd config default | tee /etc/containerd/config.toml > /dev/null 2>&1 
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

cat /etc/containerd/config.toml | grep 'registry.k8s.io/pause'
```

## Kubectl / Kubeadm / Kubeletをインストール
- 公式の[URL](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)を参照

### swapが無効化できない
- zramなら以下方法で無効化できる。やってることは `zram-generator-defaults` を削除しているだけ
> https://www.reddit.com/r/Fedora/comments/wgetj1/cant_disable_swap_in_fedora_server_36/

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
