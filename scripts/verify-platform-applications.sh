#!/usr/bin/env bash
set -euo pipefail

APPS=(
  aws-load-balancer-controller
  cert-manager
  cluster-issuer
  traefik
  external-dns
  monitoring
)

for APP in "${APPS[@]}"; do
  echo "Checking $APP..."

  if ! kubectl wait --for=create "application/$APP" -n argocd --timeout=600s; then
    echo "ERROR: $APP Application was not created."
    kubectl get applications -n argocd || true
    exit 1
  fi

  if ! kubectl wait --for=jsonpath='{.status.sync.status}'=Synced "application/$APP" -n argocd --timeout=600s; then
    echo "ERROR: $APP failed to become Synced."
    kubectl describe application "$APP" -n argocd || true
    exit 1
  fi

  if ! kubectl wait --for=jsonpath='{.status.health.status}'=Healthy "application/$APP" -n argocd --timeout=600s; then
    echo "ERROR: $APP failed to become Healthy."

    kubectl describe application "$APP" -n argocd || true

    echo "Application resources:"
    kubectl get pods,deployments,statefulsets,services -n monitoring || true

    echo "Recent Kubernetes events:"
    kubectl get events -A --sort-by=.lastTimestamp | tail -40 || true

    exit 1
  fi

  echo "$APP is Synced and Healthy."
done

echo "All ArgoCD platform Applications are ready."
