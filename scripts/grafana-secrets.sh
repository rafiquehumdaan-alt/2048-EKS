#!/usr/bin/env bash
set -euo pipefail

for name in GRAFANA_GITHUB_CLIENT_ID GRAFANA_GITHUB_CLIENT_SECRET GRAFANA_ADMIN_PASSWORD; do
  if [ -z "${!name:-}" ]; then
    echo "Missing required secret: $name"
    exit 1
  fi
done

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

python3 - <<'PY' | kubectl apply --server-side --field-manager=grafana-secret-bootstrap -f -
import base64
import json
import os

def encode(value):
    return base64.b64encode(value.encode()).decode()

secrets = [
    {
        "apiVersion": "v1",
        "kind": "Secret",
        "metadata": {
            "name": "grafana-oauth-credentials",
            "namespace": "monitoring"
        },
        "type": "Opaque",
        "data": {
            "GF_AUTH_GITHUB_CLIENT_ID": encode(os.environ["GRAFANA_GITHUB_CLIENT_ID"]),
            "GF_AUTH_GITHUB_CLIENT_SECRET": encode(os.environ["GRAFANA_GITHUB_CLIENT_SECRET"])
        }
    },
    {
        "apiVersion": "v1",
        "kind": "Secret",
        "metadata": {
            "name": "grafana-admin-credentials",
            "namespace": "monitoring"
        },
        "type": "Opaque",
        "data": {
            "admin-user": encode("admin"),
            "admin-password": encode(os.environ["GRAFANA_ADMIN_PASSWORD"])
        }
    }
]

print(json.dumps({
    "apiVersion": "v1",
    "kind": "List",
    "items": secrets
}))
PY
