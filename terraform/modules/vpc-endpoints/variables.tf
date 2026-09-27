variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "aws_region" {
  description = "Default AWS Region"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the Private Subnets"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "IDs of the Private Route Tables"
  type        = list(string)
}

variable "node_sg_id" {
  description = "ID of the EKS worker node security group"
  type        = string
}