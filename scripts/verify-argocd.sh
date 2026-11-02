#!/usr/bin/env bash
set -euo pipefail

echo "Verifying ArgoCD deployments..."

kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=300s
kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=300s
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s
kubectl rollout status deployment/argocd-applicationset-controller -n argocd --timeout=300s

echo "ArgoCD pods:"
kubectl get pods -n argocd

echo "ArgoCD Helm release:"
helm list -n argocd
