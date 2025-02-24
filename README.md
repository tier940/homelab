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

## swapの無効化
- zramなら以下方法で無効化できる。やってることは `zram-generator-defaults` を削除しているだけ
> https://www.reddit.com/r/Fedora/comments/wgetj1/cant_disable_swap_in_fedora_server_36/

## SELinuxの無効化
```bash
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

## CRI-O / Kubectl / Kubeadm / Kubeletをインストール
- 公式の[URL](https://github.com/cri-o/packaging/blob/main/)を参照

### sandboxのバージョンを更新
- 最新のバージョンを記載する
> 2024/10/25現在は 3.10 だった
`/etc/crio/crio.conf.d/10-crio.conf`

```conf
[crio.image]
pause_image="registry.k8s.io/pause:3.10"
```

### cgroup driverの変更
- cgroupfsを指定する
`/etc/crio/crio.conf.d/10-crio.conf`
```conf
[crio.runtime]
conmon_cgroup = "pod"
cgroup_manager = "cgroupfs"
```

## tcのインストール
```bash
dnf install -y iproute-tc
```

### サービスの起動
```bash
systemctl enable --now crio.service
systemctl enable --now kubelet.service

systemctl status crio.service
systemctl status kubelet.service
```

## コントロールプレーンの作成
```bash
kubeadm init --control-plane-endpoint k8s-ctrl-001.tier.k8s.local \
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
kubeadm join k8s-ctrl-001.tier.k8s.local:6443 --token XXXXX --discovery-token-ca-cert-hash sha256:YYYY
```

### トークンの再作成
- どうやらトークンは有効期限があるらしい
    - コントロールプレーンがあるVMで実行する
```bash
kubeadm token create --print-join-command
```
