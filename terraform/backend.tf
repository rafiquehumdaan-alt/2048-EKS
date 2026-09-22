terraform {
  backend "s3" {
    bucket       = "2048-tf-state-bucket-2678216865"
    key          = "2048-eks/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}