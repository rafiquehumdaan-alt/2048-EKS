#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for Prometheus CRDs to be established..."

for CRD in prometheuses.monitoring.coreos.com alertmanagers.monitoring.coreos.com servicemonitors.monitoring.coreos.com podmonitors.monitoring.coreos.com; do
  kubectl wait --for=create crd/"$CRD" --timeout=600s

  echo "Waiting for $CRD to become Established..."

  for attempt in {1..60}; do
    STATUS=$(kubectl get crd "$CRD" -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null || true)

    if [ "$STATUS" = "True" ]; then
      echo "$CRD is Established."
      break
    fi

    if [ "$attempt" -eq 60 ]; then
      echo "ERROR: $CRD did not become Established."
      exit 1
    fi

    sleep 5
  done
done

echo "Waiting for Prometheus Operator deployment..."

kubectl wait --for=create deployment/monitoring-kube-prometheus-operator -n monitoring --timeout=600s
kubectl rollout status deployment/monitoring-kube-prometheus-operator -n monitoring --timeout=300s

echo "Restarting Prometheus Operator after CRDs are established..."

kubectl rollout restart deployment/monitoring-kube-prometheus-operator -n monitoring
kubectl rollout status deployment/monitoring-kube-prometheus-operator -n monitoring --timeout=300s

echo "Prometheus Operator is ready."
