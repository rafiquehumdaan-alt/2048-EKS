#!/usr/bin/env bash
set -euo pipefail

VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || true)

if [ -z "$VPC_ID" ]; then
  echo "Terraform VPC output unavailable. Trying EKS cluster..."

  VPC_ID=$(aws eks describe-cluster \
    --name 2048-eks-cluster \
    --region eu-west-2 \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text 2>/dev/null || true)
fi

if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
  echo "Could not determine VPC ID. Skipping Kubernetes security group cleanup."
  exit 0
fi

echo "Using VPC: $VPC_ID"

for _ in {1..10}; do
  SG_IDS=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=k8s-*" \
    --query "SecurityGroups[*].GroupId" \
    --output text)

  if [ -z "$SG_IDS" ]; then
    echo "No leftover Kubernetes security groups found."
    exit 0
  fi

  echo "Found Kubernetes security groups: $SG_IDS"

  for SG_ID in $SG_IDS; do
    ENI_COUNT=$(aws ec2 describe-network-interfaces \
      --filters "Name=group-id,Values=$SG_ID" \
      --query "length(NetworkInterfaces)" \
      --output text)

    if [ "$ENI_COUNT" -eq 0 ]; then
      echo "Deleting security group: $SG_ID"
      aws ec2 delete-security-group --group-id "$SG_ID" || true
    else
      echo "$SG_ID is still attached to $ENI_COUNT network interface(s)."
    fi
  done

  echo "Waiting 30 seconds before checking again..."
  sleep 30
done

echo "Some Kubernetes security groups still remain after waiting."
exit 1
