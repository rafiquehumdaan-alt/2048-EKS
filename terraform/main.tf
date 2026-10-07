module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block             = var.vpc_cidr_block
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones         = var.availability_zones
  vpc_flow_logs_role_arn     = module.iam.vpc_flow_logs_role_arn
}

module "iam" {
  source = "./modules/iam"

  eks_cluster_role_name = var.eks_cluster_role_name
  eks_node_role_name    = var.eks_node_role_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.eks_cluster_name
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_type = var.eks_node_instance_type

  node_min_size     = var.eks_node_min_size
  node_desired_size = var.eks_node_desired_size
  node_max_size     = var.eks_node_max_size

  admin_principal_arn = var.aws_admin_principal_arn

  vpc_id = module.vpc.vpc_id

  github_actions_role_arn = "arn:aws:iam::435059220418:role/2048-eks-github-actions-role"

  depends_on = [module.iam]
}

module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  vpc_id                  = module.vpc.vpc_id
  aws_region              = var.aws_region
  private_subnet_ids      = module.vpc.private_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  node_sg_id              = module.eks.node_sg_id
}

resource "aws_vpc_security_group_egress_rule" "node_to_vpc_endpoints" {
  security_group_id            = module.eks.node_sg_id
  referenced_security_group_id = module.vpc_endpoints.endpoint_sg_id
  description                  = "Allow worker nodes to communicate with VPC endpoints over HTTPS"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "node_to_s3" {
  security_group_id = module.eks.node_sg_id
  prefix_list_id    = module.vpc_endpoints.s3_prefix_list_id
  description       = "Allow worker nodes to communicate with S3 over HTTPS"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

module "addons_iam" {
  source = "./modules/addons-iam"

  oidc_issuer_url = module.eks.oidc_issuer_url

  route53_zone_arn = module.dns.zone_arn
}

module "dns" {
  source = "./modules/dns"

  subdomain          = var.eks_subdomain
  cloudflare_zone_id = var.cloudflare_zone_id

  tags = {
    Project = "2048-EKS"
  }
}