#!/usr/bin/env bash
set -euo pipefail

LOG_GROUP="/aws/eks/2048-eks-cluster/cluster"

echo "Checking CloudWatch log group: $LOG_GROUP"

LOG_GROUPS=$(aws logs describe-log-groups \
  --region eu-west-2 \
  --log-group-name-prefix "$LOG_GROUP" \
  --query "logGroups[?logGroupName=='$LOG_GROUP'].logGroupName" \
  --output text)

if [ "$LOG_GROUPS" = "$LOG_GROUP" ]; then
  echo "Deleting leftover EKS log group..."

  aws logs delete-log-group \
    --region eu-west-2 \
    --log-group-name "$LOG_GROUP"

  echo "CloudWatch log group deleted."
else
  echo "No leftover EKS log group found."
fi
