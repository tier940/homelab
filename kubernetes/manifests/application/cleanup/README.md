# Image Cleanup DaemonSet
- Kubernetesクラスタ内の全ノード(ワーカー・コントロールプレーン)で古いコンテナイメージを自動的に削除するDaemonSet

## 機能
- 全ノード(ワーカー・コントロールプレーン)で自動実行
- 毎日午前2時に各ノードでクリーンアップを実行
- Pod起動時にも即座にクリーンアップを実行
- 使用されていないイメージを削除(`crictl rmi --prune`)
- CRI-O対応

## デプロイ
```bash
kubectl apply -k ./manifests/application/cleanup/
```

## 手動実行
- 特定のノードで即座に実行したい場合は、そのノードのPodを再起動する
```bash
# 特定ノードのPodを削除して再起動(起動時にクリーンアップが実行される)
kubectl delete pod -n kube-system -l app=image-cleanup --field-selector spec.nodeName=<ノード名>
```

## 実行状況の確認
```bash
# DaemonSetの状態確認
kubectl get daemonset -n kube-system image-cleanup

# 各ノードで実行中のPodの確認
kubectl get pods -n kube-system -l app=image-cleanup -o wide

# 特定ノードのログ確認
kubectl logs -n kube-system -l app=image-cleanup --tail=100

# 特定ノードのPodのログ確認
kubectl logs -n kube-system <pod-name>
```

## スケジュール変更
- `daemonset.yaml`内のシェルスクリプトの`TARGET_SECONDS`変数を変更すること
- デフォルトは午前2時(7200秒 = 2時間 × 3600秒)

### 変更例
- `TARGET_SECONDS=0` - 毎日午前0時
- `TARGET_SECONDS=10800` - 毎日午前3時(3時間 × 3600秒)
- `TARGET_SECONDS=43200` - 毎日正午(12時間 × 3600秒)

## 削除対象
- `crictl rmi --prune`コマンドにより、使用されていないイメージを自動削除
- 現在実行中のコンテナで使用されているイメージは削除されない
