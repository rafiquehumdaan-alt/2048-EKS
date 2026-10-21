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