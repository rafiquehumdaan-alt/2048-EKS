#!/usr/bin/env bash
set -euo pipefail

if kubectl get application monitoring -n argocd >/dev/null 2>&1; then
  echo "Removing Monitoring Application..."

  kubectl patch application monitoring -n argocd --type merge -p '{"metadata":{"finalizers":["resources-finalizer.argocd.argoproj.io"]}}'

  kubectl delete application monitoring -n argocd --wait=false

  kubectl wait --for=delete application/monitoring -n argocd --timeout=600s

  echo "Monitoring Application removed."
else
  echo "Monitoring Application not found."
fi
