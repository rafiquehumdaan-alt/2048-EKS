variable "aws_region" {
  description = "AWS region used for the 2048 EKS infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for the 2048 application"
  type        = string
  default     = "2048-eks-repo"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  type        = string
  default     = "2048-eks-cluster-role"
}

variable "eks_node_role_name" {
  description = "Name of the EKS managed node group IAM role"
  type        = string
  default     = "2048-eks-managed-node-group-role"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "2048-eks-cluster"
}

variable "eks_node_instance_type" {
  description = "Instance type for the EKS managed node group"
  type        = string
  default     = "c7i-flex.large"
}

variable "eks_node_min_size" {
  description = "Minimum size of the EKS managed node group"
  type        = number
  default     = 2
}

variable "eks_node_desired_size" {
  description = "Desired size of the EKS managed node group"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum size of the EKS managed node group"
  type        = number
  default     = 4
}

variable "aws_admin_principal_arn" {
  description = "AWS EKS access entry for the cluster"
  type        = string
  default     = "arn:aws:iam::435059220418:user/Humdaan"
}