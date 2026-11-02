#!/usr/bin/env bash
set -euo pipefail

if kubectl get application 2048 -n argocd >/dev/null 2>&1; then
  echo "Removing 2048 Application..."

  kubectl patch application 2048 -n argocd --type merge -p '{"metadata":{"finalizers":["resources-finalizer.argocd.argoproj.io"]}}'

  kubectl delete application 2048 -n argocd --wait=false
fi

for _ in {1..60}; do
  APP=$(kubectl get application 2048 -n argocd --ignore-not-found -o name) || {
    echo "Failed to connect to Kubernetes API"
    exit 1
  }

  if [ -z "$APP" ]; then
    echo "Application 2048 deleted."
    exit 0
  fi

  STUCK_CHALLENGES=$(kubectl get challenges -n 2048 -o json | jq -r '
    .items[]
    | select(.metadata.deletionTimestamp != null)
    | select((.status.reason // "") | contains("NoSuchHostedZone"))
    | .metadata.name
  ')

  for CHALLENGE in $STUCK_CHALLENGES; do
    echo "Removing obsolete finalizer from $CHALLENGE"

    kubectl patch challenge "$CHALLENGE" -n 2048 --type=merge -p '{"metadata":{"finalizers":[]}}'
  done

  sleep 10
done

echo "2048 Application deletion timed out."
kubectl get challenges,orders,certificates,ingress -n 2048
exit 1
