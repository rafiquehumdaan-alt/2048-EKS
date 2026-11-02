#!/usr/bin/env bash
set -euo pipefail

echo "Checking Grafana PVC..."

if kubectl get pvc monitoring-grafana -n monitoring >/dev/null 2>&1; then
  kubectl wait --for=delete pvc/monitoring-grafana -n monitoring --timeout=300s
fi

echo "Checking for remaining Grafana EBS volumes..."

for _ in {1..30}; do
  VOLUME_IDS=$(aws ec2 describe-volumes --region eu-west-2 --filters "Name=tag:kubernetes.io/created-for/pvc/name,Values=monitoring-grafana" --query 'Volumes[].VolumeId' --output text)

  if [ -z "$VOLUME_IDS" ]; then
    echo "Grafana EBS volume cleanup confirmed."
    exit 0
  fi

  echo "Waiting for Grafana EBS volumes to be deleted: $VOLUME_IDS"
  sleep 10
done

echo "ERROR: Grafana EBS volume still exists."
exit 1
