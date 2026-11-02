#!/usr/bin/env bash
set -euo pipefail

VPC_ID=$(terraform -chdir=terraform output -raw vpc_id)

if [[ ! "$VPC_ID" =~ ^vpc-[0-9a-f]+$ ]]; then
  echo "Invalid Terraform VPC ID: $VPC_ID"
  exit 1
fi

FILE="argocd/applications/aws-load-balancer-controller.yaml"

grep -qE '^[[:space:]]*- name: vpcId$' "$FILE"

sed -i -E '/^[[:space:]]*- name: vpcId$/{n;s/^([[:space:]]*value: ).*/\1"'"$VPC_ID"'"/;}' "$FILE"

grep -qF "value: \"$VPC_ID\"" "$FILE"

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git add "$FILE"

if git diff --cached --quiet; then
  echo "VPC ID already matches Terraform output."
else
  git commit -m "chore: update EKS VPC ID"
  git push origin HEAD:main
fi

git fetch origin main

git show "origin/main:$FILE" | grep -qF "value: \"$VPC_ID\""

echo "VPC ID verified in GitHub: $VPC_ID"
