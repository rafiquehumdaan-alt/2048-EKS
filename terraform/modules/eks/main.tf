resource "aws_eks_cluster" "main_cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster_sg.id]
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

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"
}

resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.admin_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_cluster_access" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.admin_principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

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

  from_port   = 10250
  to_port     = 10250
  ip_protocol = "tcp"

  referenced_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_cluster_sg" {
  security_group_id = aws_security_group.cluster_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  referenced_security_group_id = aws_security_group.node_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
  security_group_id = aws_security_group.node_sg.id

  ip_protocol = "-1"

  referenced_security_group_id = aws_security_group.node_sg.id
}

resource "aws_vpc_security_group_egress_rule" "node_to_node_egress" {
  security_group_id = aws_security_group.node_sg.id

  ip_protocol = "-1"

  referenced_security_group_id = aws_security_group.node_sg.id
}

resource "aws_vpc_security_group_egress_rule" "node_to_cluster_https" {
  security_group_id = aws_security_group.node_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  referenced_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_vpc_security_group_egress_rule" "node_to_internet_https" {
  security_group_id = aws_security_group.node_sg.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "node_to_cluster_kubelet" {
  security_group_id = aws_security_group.node_sg.id

  from_port   = 10250
  to_port     = 10250
  ip_protocol = "tcp"

  referenced_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_vpc_security_group_egress_rule" "node_to_cluster_dns_tcp" {
  security_group_id = aws_security_group.node_sg.id

  from_port   = 53
  to_port     = 53
  ip_protocol = "tcp"

  referenced_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_vpc_security_group_egress_rule" "node_to_cluster_dns_udp" {
  security_group_id = aws_security_group.node_sg.id

  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"

  referenced_security_group_id = aws_security_group.cluster_sg.id
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_node_kubelet" {
  security_group_id = aws_security_group.cluster_sg.id

  from_port   = 10250
  to_port     = 10250
  ip_protocol = "tcp"

  referenced_security_group_id = aws_security_group.node_sg.id
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.cluster_name}-nodes-"

  vpc_security_group_ids = [
    aws_security_group.node_sg.id
  ]
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_node_webhook" {
  security_group_id = aws_security_group.cluster_sg.id

  referenced_security_group_id = aws_security_group.node_sg.id

  ip_protocol = "tcp"
  from_port   = 9443
  to_port     = 9443
}

resource "aws_vpc_security_group_ingress_rule" "node_from_cluster_webhook" {
  security_group_id = aws_security_group.node_sg.id

  referenced_security_group_id = aws_security_group.cluster_sg.id

  ip_protocol = "tcp"
  from_port   = 9443
  to_port     = 9443
}