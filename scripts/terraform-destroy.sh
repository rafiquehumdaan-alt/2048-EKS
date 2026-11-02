#!/usr/bin/env bash
set -euo pipefail

if terraform apply -auto-approve destroy.tfplan; then
  exit 0
fi

echo "Initial destroy failed. Checking for orphaned Kubernetes ENIs..."

# Do not clean up ENIs while managed node groups still exist.
if aws eks describe-cluster \
  --name 2048-eks-cluster --region eu-west-2 \
  >/dev/null 2>&1; then

  NODEGROUPS=$(aws eks list-nodegroups \
    --cluster-name 2048-eks-cluster \
    --region eu-west-2 \
    --query 'length(nodegroups)' --output text)

  if [ "$NODEGROUPS" -ne 0 ]; then
    echo "Node groups still exist. Refusing ENI cleanup."
    exit 1
  fi
fi

VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || true)

if [ -n "$VPC_ID" ]; then
  aws ec2 describe-network-interfaces \
    --region eu-west-2 \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --output json |
    jq -r '.NetworkInterfaces[]
      | select(
          .Status == "available" and
          .RequesterManaged == false and
          .Attachment == null and
          (.Description | startswith("aws-K8S-"))
        )
      | .NetworkInterfaceId' > /tmp/orphaned-enis.txt

  while read -r ENI_ID; do
    [ -z "$ENI_ID" ] && continue

    echo "Deleting orphaned ENI: $ENI_ID"

    aws ec2 delete-network-interface \
      --region eu-west-2 \
      --network-interface-id "$ENI_ID"
  done < /tmp/orphaned-enis.txt
fi

echo "Retrying Terraform destroy..."

terraform plan -destroy -out=retry-destroy.tfplan
terraform apply -auto-approve retry-destroy.tfplan
