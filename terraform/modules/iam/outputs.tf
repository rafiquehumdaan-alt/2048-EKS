output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS managed node group IAM role"
  value       = aws_iam_role.eks_managed_node_group_role.arn
}

output "vpc_flow_logs_role_arn" {
  description = "Flow log role ARN for the VPC flow logs IAM role"
  value       = aws_iam_role.vpc_flow_logs.arn
}