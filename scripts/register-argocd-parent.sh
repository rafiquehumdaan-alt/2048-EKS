#!/usr/bin/env bash
set -euo pipefail

echo "Registering ArgoCD parent Application..."

kubectl apply -f ../argocd/root-app.yaml

kubectl wait --for=create application/aws-load-balancer-controller -n argocd --timeout=300s

kubectl wait --for=create application/cert-manager -n argocd --timeout=300s

echo "Parent Application registered."
