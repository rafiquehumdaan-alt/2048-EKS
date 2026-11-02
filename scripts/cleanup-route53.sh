#!/usr/bin/env bash
set -euo pipefail

ZONE_ID=$(terraform output -raw eks_route53_zone_id 2>/dev/null || true)

if [ -z "$ZONE_ID" ]; then
  echo "No Route 53 zone in Terraform state. Skipping."
  exit 0
fi

echo "Cleaning Route 53 hosted zone: $ZONE_ID"

aws route53 list-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --output json |
  jq '{
    Changes: [
      .ResourceRecordSets[]
      | select(
          (.Type != "NS" and .Type != "SOA")
          and
          (
            .Name == "eks.humdaan.co.uk."
            or (.Name | endswith(".eks.humdaan.co.uk."))
          )
        )
      | {
          Action: "DELETE",
          ResourceRecordSet: .
        }
    ]
  }' > /tmp/2048-dns-cleanup.json

COUNT=$(jq '.Changes | length' /tmp/2048-dns-cleanup.json)

echo "Found $COUNT DNS records to delete."

if [ "$COUNT" -gt 0 ]; then
  CHANGE_ID=$(aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch file:///tmp/2048-dns-cleanup.json \
    --query ChangeInfo.Id \
    --output text)

  aws route53 wait resource-record-sets-changed --id "$CHANGE_ID"

  echo "DNS records deleted successfully."
else
  echo "No leftover DNS records found."
fi

echo "Route 53 cleanup complete."
