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

  depends_on = [module.iam]
}