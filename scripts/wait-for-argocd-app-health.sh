#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?Application name is required}"

echo "Waiting for $APP_NAME to become Healthy..."

kubectl wait --for=jsonpath='{.status.health.status}'=Healthy "application/$APP_NAME" -n argocd --timeout=600s

echo "$APP_NAME is Healthy."
