variable "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  type        = string
}

variable "eks_node_role_name" {
  description = "Name of the EKS managed node group IAM role"
  type        = string
}