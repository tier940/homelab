# Image Cleanup CronJob
- Kubernetesクラスタ内の古いDockerイメージを自動的に削除するCronJob

## 機能
- 毎日午前2時に自動実行
- 使用されていないイメージを削除
- 7日以上使用されていないイメージを削除
- DockerとContainerdの両方に対応

## デプロイ
```bash
kubectl apply -k kubernetes/manifestes/application/cleanup/
```

## 手動実行
- CronJobを待たずに今すぐ実行したい場合はkubernetes dashboardから実行する

## 実行状況の確認
```bash
# CronJobの状態確認
kubectl get cronjob -n kube-system image-cleanup

# 実行されたJobの確認
kubectl get jobs -n kube-system | grep image-cleanup

# ログの確認
kubectl logs -n kube-system -l job-name=image-cleanup-manual
```

## スケジュール変更
- `cronjob.yaml`の`spec.schedule`を変更すること

### 変更例
- `0 */6 * * *` - 6時間ごと
- `0 0 * * 0` - 毎週日曜日の午前0時

## 削除対象の変更
- デフォルトでは7日(168時間)以上使用されていないイメージを削除を行う
- 期間を変更する場合は、`cronjob.yaml`内の`--filter "until=168h"`の値を変更すること
