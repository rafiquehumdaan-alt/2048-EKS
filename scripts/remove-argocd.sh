#!/usr/bin/env bash
set -euo pipefail

echo "Removing ArgoCD Helm release..."

helm uninstall argocd --namespace argocd --ignore-not-found --wait --timeout 300s

echo "Removing ArgoCD namespace..."

kubectl delete namespace argocd --ignore-not-found=true --wait=true --timeout=300s

echo "ArgoCD cleanup complete."
