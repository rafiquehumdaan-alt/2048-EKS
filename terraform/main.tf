module "ecr" {
  source = "./modules/ecr"

  repository_name = "2048-eks-repo"
}