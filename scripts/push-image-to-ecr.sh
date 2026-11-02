#!/usr/bin/env bash
set -euo pipefail

AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
IMAGE_TAG="${GITHUB_SHA:?GITHUB_SHA is required}"

IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/2048-eks-repo:${IMAGE_TAG}"

echo "Tagging Docker image..."
docker tag 2048:latest "$IMAGE_URI"

echo "Pushing Docker image to ECR..."
docker push "$IMAGE_URI"

echo "Image pushed: $IMAGE_URI"
