data "aws_caller_identity" "current" {}


# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}


# GitHub Actions IAM Role
resource "aws_iam_role" "github_actions_role" {
  name               = "2048-eks-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}


# Trust Policy - Allows GitHub Actions from the main branch to assume the role
data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.oidc_provider.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:rafiquehumdaan-alt/2048-EKS:ref:refs/heads/main"]
    }
  }
}


# GitHub Actions Permissions Policy
resource "aws_iam_policy" "github_actions_policy" {
  name   = "2048-eks-github-actions-policy"
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}


data "aws_iam_policy_document" "github_actions_permissions" {

  # Terraform State Bucket
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.s3_bucket_tfstate.arn
    ]
  }

  # Terraform State Objects
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket_tfstate.arn}/*"
    ]
  }


  # ECR Authentication
  # ECR authentication tokens cannot be restricted to a specific repository,
  # so all resources (*) are required.
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }


  # ECR Repository
  statement {
    effect = "Allow"

    actions = [
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:CreateRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]

    resources = [
      "arn:aws:ecr:eu-west-2:${data.aws_caller_identity.current.account_id}:repository/2048-eks-repo"
    ]
  }


  # VPC / EC2 Networking
  statement {
    effect = "Allow"

    actions = [
      # VPC
      "ec2:DescribeVpcs",
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",

      # Subnets
      "ec2:DescribeSubnets",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:ModifySubnetAttribute",

      # Internet Gateways
      "ec2:DescribeInternetGateways",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",

      # Elastic IPs
      "ec2:DescribeAddresses",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",

      # NAT Gateways
      "ec2:DescribeNatGateways",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",

      # Route Tables / Routes
      "ec2:DescribeRouteTables",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:ReplaceRoute",
      "ec2:ReplaceRouteTableAssociation",

      # Security Groups
      "ec2:DescribeSecurityGroups",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",

      # VPC Endpoints
      "ec2:DescribeVpcEndpoints",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteVpcEndpoints",
      "ec2:ModifyVpcEndpoint",
      "ec2:DescribeVpcEndpointServices",

      # Availability Zones
      "ec2:DescribeAvailabilityZones",

      # Tags
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }


  # EKS Cluster and Managed Node Groups
  statement {
    effect = "Allow"

    actions = [
      # EKS Cluster
      "eks:CreateCluster",
      "eks:DescribeCluster",
      "eks:DeleteCluster",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",

      # Managed Node Groups
      "eks:CreateNodegroup",
      "eks:DescribeNodegroup",
      "eks:DeleteNodegroup",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",

      # EKS Information / Updates
      "eks:ListClusters",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "eks:DescribeUpdate",

      # Tags
      "eks:TagResource",
      "eks:UntagResource"
    ]

    resources = ["*"]
  }


  # Allow Terraform to create and manage IAM roles required by EKS
  statement {
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:TagRole",
      "iam:UntagRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/2048-eks-*"
    ]
  }


  # Allow Terraform to pass project IAM roles to EKS and EC2
  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/2048-eks-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "eks.amazonaws.com",
        "ec2.amazonaws.com"
      ]
    }
  }
}


# Attach Permissions Policy to GitHub Actions Role
resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}