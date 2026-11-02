#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="eu-west-2"
CLUSTER_NAME="2048-eks-cluster"
ROLE_ARN="${AWS_ROLE_ARN:?AWS_ROLE_ARN is required}"

if ! aws eks describe-access-entry \
  --cluster-name "$CLUSTER_NAME" \
  --principal-arn "$ROLE_ARN" \
  --region "$AWS_REGION" >/dev/null 2>&1; then

  echo "GitHub Actions EKS access entry is missing. Recreating it..."

  aws eks create-access-entry \
    --cluster-name "$CLUSTER_NAME" \
    --principal-arn "$ROLE_ARN" \
    --type STANDARD \
    --region "$AWS_REGION"

  aws eks associate-access-policy \
    --cluster-name "$CLUSTER_NAME" \
    --principal-arn "$ROLE_ARN" \
    --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
    --access-scope type=cluster \
    --region "$AWS_REGION"

  echo "Waiting for EKS access to propagate..."
  sleep 15
else
  echo "GitHub Actions EKS access already exists."
fi
