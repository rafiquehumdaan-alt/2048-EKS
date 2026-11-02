#!/usr/bin/env bash
set -euo pipefail

if ! kubectl get application root-app -n argocd >/dev/null 2>&1; then
  echo "Parent Application not found. Continuing cleanup."
  exit 0
fi

echo "Disabling parent automatic synchronisation..."

kubectl patch application root-app -n argocd --type merge -p '{"spec":{"syncPolicy":{"automated":null}}}'

echo "Waiting for any active parent sync to finish..."

for attempt in {1..60}; do
  PHASE=$(kubectl get application root-app -n argocd -o jsonpath='{.status.operationState.phase}')

  if [ "$PHASE" != "Running" ]; then
    echo "No active parent sync."
    break
  fi

  if [ "$attempt" -eq 60 ]; then
    echo "ERROR: Parent Application sync is still running."
    exit 1
  fi

  sleep 5
done

echo "Removing parent Application without deleting children..."

kubectl patch application root-app -n argocd --type merge -p '{"metadata":{"finalizers":null}}'

kubectl delete application root-app -n argocd --cascade=orphan --wait=true --timeout=120s

echo "Parent removed. Child Applications remain for ordered cleanup."

kubectl get applications -n argocd
