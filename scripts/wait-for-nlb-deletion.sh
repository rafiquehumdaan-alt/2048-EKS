#!/usr/bin/env bash
set -euo pipefail

VPC_ID=$(terraform output -raw vpc_id)

for _ in {1..20}; do
  NLB_COUNT=$(aws elbv2 describe-load-balancers \
    --region eu-west-2 \
    --query "length(LoadBalancers[?Type=='network' && VpcId=='$VPC_ID'])" \
    --output text)

  if [ "$NLB_COUNT" -eq 0 ]; then
    echo "All NLBs in the VPC have been deleted."
    exit 0
  fi

  echo "Waiting for $NLB_COUNT NLB(s) to be deleted..."
  sleep 15
done

echo "NLB deletion timed out."
exit 1
