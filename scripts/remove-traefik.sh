#!/usr/bin/env bash
set -euo pipefail

if kubectl get application traefik -n argocd >/dev/null 2>&1; then
  echo "Removing Traefik Application and its managed resources..."

  kubectl patch application traefik -n argocd --type merge -p '{"metadata":{"finalizers":["resources-finalizer.argocd.argoproj.io"]}}'

  kubectl delete application traefik -n argocd --wait=false

  kubectl wait --for=delete application/traefik -n argocd --timeout=600s

  echo "Traefik Application removed."
else
  echo "Traefik Application not found."
fi
