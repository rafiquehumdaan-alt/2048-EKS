# 2048 on Amazon EKS

Welcome to my EKS-2048 Project. I built the below project from scratch, taking an application from a docker container to a working deployment on AWS. The main focus for this project is not the application but the infrastructure, Kubernetes, and deploying and updating the application.

Terraform provisions the AWS environment, GitHub Actions runs the pipelines, and ArgoCD keeps the application and configuration in my Kubernetes environment in sync with my GitHub repository.

## The application

When the environment is running, the game is available at [eks.humdaan.co.uk](https://eks.humdaan.co.uk) over HTTPS. I destroy the environment when I am not using it to keep AWS costs down, so the site may be offline.

![2048 running over HTTPS](documentation/Screenshots/web-app-live.png)

## How it fits together

The application runs on Amazon EKS, with Docker images stored in ECR. I use Helm to manage the Kubernetes components, NGINX Ingress to route traffic, and cert-manager for HTTPS certificates.

### AWS infrastructure

![AWS infrastructure diagram](documentation/Screenshots/2048-infrastructure.png)

### Kubernetes

![Kubernetes architecture diagram](documentation/Screenshots/kubernetes-infrastructure.png)

## Deploying changes

I split the automation into two workflows: one for the infrastructure and one for the application.

The Terraform workflow runs infrastructure checks and Checkov scans. It supports plan, apply, and destroy operations, and sets up ArgoCD when the environment is created. The Terraform Workflow must run after the bootstrap is applied first using a local 'terraform apply' command.

![Terraform apply pipeline](documentation/Screenshots/terraform-apply-pipeline.png)

The application workflow builds the Docker image, scans it with Trivy, pushes it to ECR, and updates the image tag in Git. ArgoCD picks up that change and syncs the deployment with the repository.

![Application delivery pipeline](documentation/Screenshots/application-push-pipeline.png)

ArgoCD also gives me a view of the application and platform components running in the cluster.

![Applications in ArgoCD](documentation/Screenshots/argocd-all-applications.png)

The destroy pipeline and application resource tree screenshots show the teardown process and the Kubernetes resources in more detail.

## Monitoring

I use Prometheus and Grafana to monitor the application and the EKS environment. These dashboards show the application metrics and the infrastructure behind it.

### Application metrics

![2048 application dashboard in Grafana](documentation/Screenshots/grafana-2048-application-dashboard.png)

### Cluster metrics

![EKS infrastructure dashboard in Grafana](documentation/Screenshots/grafana-2048-eks-infrastructure-dashboard.png)

## Further documentation

I have added the below files for anyone interested in reading some more in depth documentation:

- [System design](documentation/system-design.md)
- [Security](documentation/security-overview.md)
- [Networking](documentation/networking.md)
- [CI/CD](documentation/cicd-overview.md)

TIME LOG: 74 HOURS