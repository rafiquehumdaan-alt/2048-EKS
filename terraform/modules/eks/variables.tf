variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string
}

variable "node_min_size" {
  description = "Minimum number of worker nodes in the EKS node group"
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of worker nodes in the EKS node group"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes in the EKS node group"
  type        = number
}

variable "admin_principal_arn" {
  description = "IAM principal ARN granted admin access to the EKS cluster"
  type        = string
}