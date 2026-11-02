#!/usr/bin/env bash
set -euo pipefail

echo "========== Root configuration =========="
tflint

for dir in modules/*/; do
  echo "========== Checking $dir =========="
  tflint --chdir "$dir" --config "$PWD/.tflint.hcl"
done
