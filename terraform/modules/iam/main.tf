resource "aws_iam_role" "eks_cluster_role" {
  name               = "2048-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_role_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_cluster_role_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_managed_node_group_role" {
  name               = "2048-eks-managed-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_managed_node_group_role_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_managed_node_group_role_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_managed_node_group_role_policy_attachment" {
  role       = aws_iam_role.eks_managed_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_managed_node_group_cni_policy_attachment" {
  role       = aws_iam_role.eks_managed_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_managed_node_group_registry_policy_attachment" {
  role       = aws_iam_role.eks_managed_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}