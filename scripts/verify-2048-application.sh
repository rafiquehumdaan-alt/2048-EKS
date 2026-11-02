#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for the 2048 ArgoCD Application..."

kubectl wait --for=create application/2048 -n argocd --timeout=600s

echo "Waiting for the 2048 Application to become Synced..."

kubectl wait --for=jsonpath='{.status.sync.status}'=Synced application/2048 -n argocd --timeout=600s

echo "Waiting for the 2048 Application to become Healthy..."

kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/2048 -n argocd --timeout=600s

echo "2048 Application is Synced and Healthy."
