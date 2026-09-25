resource "aws_eks_cluster" "main_cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode = "API"
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

resource "aws_eks_node_group" "main_node_group" {
  cluster_name    = aws_eks_cluster.main_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]

  capacity_type = "ON_DEMAND"
}

resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.admin_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_cluster_access" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.admin_principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin_access]
}

resource "aws_security_group" "cluster_sg" {
  name   = "2048-eks-cluster-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group" "node_sg" {
  name   = "2048-eks-node-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_node_sg" {
  security_group_id = aws_security_group.node_sg.id

  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_cluster_sg" {
  security_group_id = aws_security_group.cluster_sg.id

  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.node_sg.id
}