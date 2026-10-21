# Networking and User Request Flow

This document follows a request from the browser to the 2048 application and explains the AWS and Kubernetes networking components involved.

## Network layout

The project runs in a VPC with the address range 10.0.0.0/16 in eu-west-2. Two public and two private subnets are spread across eu-west-2a and eu-west-2b.

| Subnet | CIDR | Purpose |
|---|---|---|
| Public, AZ-a | 10.0.1.0/24 | Internet-facing load balancing and NAT |
| Public, AZ-b | 10.0.2.0/24 | Internet-facing load balancing and NAT |
| Private, AZ-a | 10.0.3.0/24 | EKS worker nodes |
| Private, AZ-b | 10.0.4.0/24 | EKS worker nodes |

Public subnets have a route to the Internet Gateway. Each private subnet uses the NAT Gateway in its own Availability Zone for outbound internet access. The worker nodes do not need public IP addresses.

[![AWS infrastructure diagram](Screenshots/2048-infrastructure.png)](Screenshots/2048-infrastructure.png)

## How a request reaches the application

1. A visitor opens https://eks.humdaan.co.uk.
2. Cloudflare delegates the eks.humdaan.co.uk DNS zone to Route 53. ExternalDNS manages the relevant Route 53 records from Kubernetes resources.
3. DNS resolution directs the visitor to the internet-facing AWS Network Load Balancer.
4. The NLB forwards the connection to the NGINX Ingress Controller in EKS. The NLB uses IP targets and Proxy Protocol; TLS is handled at NGINX using the certificate provided by cert-manager.
5. NGINX matches the hostname and forwards the request to the 2048 ClusterIP Service on port 80.
6. The Service routes the request to one of the two 2048 application Pods, which serves the website.

The Grafana hostname follows the same general entry path but is routed to the Grafana service rather than the 2048 application.

## DNS and TLS

The parent domain, humdaan.co.uk, is managed in Cloudflare. Terraform creates a Route 53 hosted zone for eks.humdaan.co.uk and configures delegation from Cloudflare.

ExternalDNS watches Ingress and Service resources and keeps matching Route 53 records updated. It is limited to the eks.humdaan.co.uk domain.

cert-manager uses a Let's Encrypt ClusterIssuer and Route 53 DNS-01 validation to obtain certificates. The application Ingress references the resulting TLS secret. Grafana has its own hostname and TLS secret.

## Private access to AWS services

VPC endpoints reduce the need for traffic from worker nodes to leave the VPC when accessing supported AWS services.

| Endpoint | Connection type |
|---|---|
| ECR API and ECR Docker | Interface |
| CloudWatch Logs, EC2 and STS | Interface |
| S3 | Gateway |

ECR and S3 are used during image retrieval, while the other endpoints support AWS API and logging access. NAT Gateways remain available for outbound connections that do not use these endpoints.

## Why this approach

The Network Load Balancer provides the public entry point, while NGINX handles hostname-based routing inside Kubernetes. Private worker nodes reduce direct exposure, and using two Availability Zones avoids placing the entire network path in one zone. DNS and certificates are automated so that rebuilding the cluster requires fewer manual steps.

For the wider infrastructure design, see [System Design](system-design.md). Security controls are covered in the [Security Overview](security-overview.md).
