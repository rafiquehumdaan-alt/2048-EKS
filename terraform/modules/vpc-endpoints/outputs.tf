output "endpoint_sg_id" {
  description = "ID of the VPC endpoint security group"
  value       = aws_security_group.endpoint_sg.id
}

output "s3_prefix_list_id" {
  description = "The prefix list ID for S3"
  value       = aws_vpc_endpoint.s3.prefix_list_id
}