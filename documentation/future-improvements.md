# Future Improvements

The following improvements could be implemented to further develop the 2048 EKS project.

## 1. Improve Monitoring Data Retention

Prometheus currently uses ephemeral storage, meaning monitoring data is lost when the Pod is recreated.

Move Prometheus to persistent storage using Amazon EBS and introduce a backup or remote-storage strategy to preserve historical metrics.

## 2. Introduce a Database-Backed Feature

The 2048 application is currently a static web application and does not require a database.

Extend the application to support features such as saved scores, leaderboards or user accounts. This would involve introducing a backend API and a managed database service such as Amazon RDS or DynamoDB.

## 3. Make the EKS API Private-Only

The EKS Kubernetes API currently allows both public and private access.

Disable the public endpoint to reduce exposure to the internet. Administrative access and CI/CD operations would instead use a secure connection to the VPC, such as a VPN or a self-hosted GitHub Actions runner.

## 4. Implement Dependabot

The project currently pins GitHub Actions to specific commit SHAs and uses versioned dependencies across its infrastructure and deployment configuration.

Configure GitHub Dependabot to check for dependency updates and open pull requests when newer versions are available. This would help keep GitHub Actions and other supported dependencies up to date while allowing changes to be reviewed and tested before merging.

## 5. Implement External Secrets Operator and AWS Secrets Manager

Grafana credentials are currently passed through GitHub Actions secrets and created as Kubernetes Secrets during deployment.

Introduce AWS Secrets Manager for storing sensitive values and use External Secrets Operator (ESO) to synchronise them into Kubernetes. Configure the operator with appropriately scoped AWS IAM permissions so applications can retrieve the secrets they need without storing those values in Git.

## 6. Use a GitHub App for Protected Branch Automation

The deployment workflows currently need to commit generated changes back to the main branch, such as updated Kubernetes image references and infrastructure configuration.

Create a dedicated GitHub App for these automated commits and configure the main-branch ruleset to allow that App to bypass the relevant restrictions. This would let the workflows push required changes without temporarily relaxing protection for other contributors. The App should have only the repository permissions it needs, with bypass access limited to the intended workflows.
