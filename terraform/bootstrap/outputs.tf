output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state storage."
  value       = aws_s3_bucket.s3_bucket_tfstate.id
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions to assume."
  value       = aws_iam_role.github_actions_role.arn
}
