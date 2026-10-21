# Security Overview

Security was considered throughout the project, from the AWS network layout to container deployment and access to monitoring. This document covers the controls currently configured in the repository, along with a few limitations of the environment.

## Network and cluster access

The EKS worker nodes run in private subnets across two Availability Zones. They do not receive public IP addresses. An internet-facing Network Load Balancer exposes the application through NGINX Ingress, rather than exposing the worker nodes or application Pods directly.

Security groups define communication between the EKS control plane, worker nodes and VPC endpoints. The worker nodes use IMDSv2 through their EC2 launch template. The EKS API endpoint has both private and public access enabled, so the control plane is not private-only.

VPC endpoints provide private connectivity to ECR, S3, CloudWatch Logs, EC2 and STS where supported.

## Identity and permissions

The project uses IAM roles for EKS, worker nodes and Kubernetes components that need AWS access. Kubernetes service accounts for controllers such as ExternalDNS and cert-manager use role annotations and the cluster's OIDC provider to obtain AWS permissions without embedding AWS access keys in manifests.

GitHub Actions authenticates to AWS by assuming an IAM role through OIDC. This avoids storing long-lived AWS access keys as repository secrets. EKS access entries grant cluster access to the configured administrator and GitHub Actions role.

## HTTPS and certificates

The application uses HTTPS at [eks.humdaan.co.uk](https://eks.humdaan.co.uk). cert-manager requests and renews Let's Encrypt certificates through a Route 53 DNS-01 challenge. NGINX Ingress uses the resulting Kubernetes TLS secret to serve the application securely.

![2048 application using HTTPS](Screenshots/web-app-live.png)

## Application and container security

The application runs in two Kubernetes Pods behind a ClusterIP Service. Startup, readiness and liveness probes help Kubernetes detect startup and runtime problems. CPU and memory requests and limits are also defined in the Deployment.

ECR stores images with immutable tags and image scanning on push. The application pipeline runs Trivy against the built image, while the Terraform workflow runs Checkov against Terraform and Kubernetes files.

These scans currently provide visibility rather than strict deployment gates: Checkov uses soft-fail mode, and Trivy is configured with exit code 0. Findings should still be reviewed before treating a deployment as production-ready.

## Secrets and Grafana access

Grafana uses GitHub OAuth for sign-in, with anonymous access disabled. Its OAuth credentials and admin password are passed through GitHub Actions secrets and created as Kubernetes Secrets during deployment, rather than committed to Git.

Grafana is exposed through an HTTPS-enabled NGINX Ingress. An optional IP allowlist appears in the Helm values, but is inactive in the form of a comment as of now. The option is available to add IP addresses to the allowlist if needed. Prometheus and Alertmanager remain internal services.

## Current limitations

For the infrastructure layout and request path, see [System Design](system-design.md) and [Networking and User Request Flow](networking.md).
