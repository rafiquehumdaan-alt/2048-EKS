#!/usr/bin/env bash
set -euo pipefail

AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
IMAGE_TAG="${GITHUB_SHA:?GITHUB_SHA is required}"

EXPECTED_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/2048-eks-repo:${IMAGE_TAG}"

echo "Waiting for ArgoCD to deploy $EXPECTED_IMAGE"

for attempt in {1..60}; do
  CURRENT_IMAGE=$(kubectl get deployment 2048-deployment \
    -n 2048 \
    -o jsonpath='{.spec.template.spec.containers[0].image}')

  if [ "$CURRENT_IMAGE" = "$EXPECTED_IMAGE" ]; then
    echo "Expected image detected."
    break
  fi

  if [ "$attempt" -eq 60 ]; then
    echo "Timed out waiting for the updated image."
    exit 1
  fi

  sleep 10
done

echo "Waiting for Kubernetes rollout..."

kubectl rollout status deployment/2048-deployment -n 2048 --timeout=300s

echo "Verifying ArgoCD synchronisation..."

kubectl wait --for=jsonpath='{.status.sync.status}'=Synced \
  application/2048 -n argocd --timeout=300s

kubectl wait --for=jsonpath='{.status.health.status}'=Healthy \
  application/2048 -n argocd --timeout=300s

echo "2048 deployment successful."
