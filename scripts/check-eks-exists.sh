#!/usr/bin/env bash
set -euo pipefail

if aws eks describe-cluster --name 2048-eks-cluster --region eu-west-2 >/dev/null 2>&1; then
  echo "exists=true" >> "$GITHUB_OUTPUT"
  echo "EKS cluster exists."
else
  echo "exists=false" >> "$GITHUB_OUTPUT"
  echo "EKS cluster does not exist. Skipping Kubernetes cleanup."
fi
