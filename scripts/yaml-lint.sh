#!/usr/bin/env bash
set -euo pipefail

echo "Installing yamllint..."
sudo apt-get update
sudo apt-get install -y yamllint

echo "Linting YAML files..."
yamllint -c .yamllint kubernetes argocd .github/workflows helm

echo "YAML linting complete."
