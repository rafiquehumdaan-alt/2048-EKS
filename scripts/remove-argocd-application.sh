#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?ArgoCD Application name is required}"

if kubectl get application "$APP_NAME" -n argocd >/dev/null 2>&1; then
  echo "Removing $APP_NAME Application..."

  kubectl patch application "$APP_NAME" -n argocd \
    --type merge \
    -p '{"metadata":{"finalizers":["resources-finalizer.argocd.argoproj.io"]}}'

  kubectl delete application "$APP_NAME" -n argocd --wait=false

  kubectl wait --for=delete "application/$APP_NAME" \
    -n argocd --timeout=300s

  echo "$APP_NAME Application removed."
else
  echo "$APP_NAME Application not found."
fi
