#!/usr/bin/env bash
set -euo pipefail

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

helm upgrade --install metrics-server metrics-server/metrics-server --namespace kube-system --version 3.14.0 --wait --timeout 5m
