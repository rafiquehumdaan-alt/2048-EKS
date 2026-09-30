output "node_sg_id" {
  description = "ID of the EKS worker node security group"
  value       = aws_security_group.node_sg.id
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.main_cluster.identity[0].oidc[0].issuer
}