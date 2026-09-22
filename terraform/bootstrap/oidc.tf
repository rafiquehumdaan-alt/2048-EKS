data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
    url = "https://token.actions.githubusercontent.com"
    client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions_role" {
  name = "2048-eks-github-actions-role"
    assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

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

resource "aws_iam_policy" "github_actions_policy" {
  name = "2048-eks-github-actions-policy"
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

data "aws_iam_policy_document" "github_actions_permissions" {
    statement {
        effect = "Allow"
        actions = [
            "s3:ListBucket"
        ]
        resources = [
            aws_s3_bucket.s3_bucket_tfstate.arn
        ]
    }
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

    statement {
        effect = "Allow"
        actions = [
            "ecr:GetAuthorizationToken"
        ]
        resources = ["*"]
    }

    # ECR authentication tokens cannot be restricted to a specific repository, so all resources (*) are required.

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
}







resource "aws_iam_role_policy_attachment" "github_actions_role_policy_attachment" {
    role       = aws_iam_role.github_actions_role.name
    policy_arn = aws_iam_policy.github_actions_policy.arn
}

