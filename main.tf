locals {
  tags = {
    Project = var.project_name
    Managed  = "terraform"
  }
}

module "vpc" {
  source        = "./modules/vpc"
  vpc_cidr      = var.vpc_cidr
  public_subnets = var.public_subnets
  tags          = local.tags
}

# Example: simple EC2 instance for demonstration and quick testing
module "ec2_demo" {
  source        = "./modules/ec2"
  instance_type = var.instance_type
  ami_name      = "amazon-linux-2"
  tags          = local.tags
  subnet_id     = module.vpc.public_subnet_ids[0]
}

# RDS module is provided but not enabled by default. Uncomment to use:
# module "rds" {
#   source = "./modules/rds"
#   allocated_storage = 20
#   engine            = "mysql"
#   engine_version    = "8.0"
#   instance_class    = "db.t3.micro"
#   username          = "dbadmin"
#   password          = "CHANGE_ME" # Use Secrets Manager in production
#   subnet_ids        = module.vpc.public_subnet_ids
#   tags              = local.tags
# }
