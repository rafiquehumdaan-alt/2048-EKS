#!/usr/bin/env bash
set -euo pipefail

AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
IMAGE_TAG="${GITHUB_SHA:?GITHUB_SHA is required}"

FILE="kubernetes/deployment.yaml"
IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/2048-eks-repo:${IMAGE_TAG}"

echo "Updating Kubernetes deployment image..."

if [ ! -f "$FILE" ]; then
  echo "ERROR: Deployment file not found: $FILE"
  exit 1
fi

python3 - "$FILE" "$IMAGE_URI" <<'PY'
from pathlib import Path
import re
import sys

file = Path(sys.argv[1])
new_image = sys.argv[2]
content = file.read_text()

pattern = (
    r'^(\s*image:\s*")'
    r'(\d{12}\.dkr\.ecr\.eu-west-2\.amazonaws\.com/2048-eks-repo:[^"]+)'
    r'(")'
)

updated, count = re.subn(
    pattern,
    lambda match: match.group(1) + new_image + match.group(3),
    content,
    flags=re.MULTILINE,
)

if count != 1:
    raise SystemExit(
        f"ERROR: Expected exactly one 2048 image reference; found {count}."
    )

file.write_text(updated)
PY

if ! grep -qF "image: \"$IMAGE_URI\"" "$FILE"; then
  echo "ERROR: Kubernetes image update verification failed."
  exit 1
fi

echo "Image reference verified: $IMAGE_URI"

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git add "$FILE"

if git diff --cached --quiet; then
  echo "Deployment image is already up to date."
  exit 0
fi

git commit -m "chore: update 2048 image to ${IMAGE_TAG}"
git push

echo "Kubernetes deployment manifest updated successfully."
