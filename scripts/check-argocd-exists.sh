#!/usr/bin/env bash
set -euo pipefail

if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  echo "exists=true" >> "$GITHUB_OUTPUT"
else
  echo "exists=false" >> "$GITHUB_OUTPUT"
fi
