provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/20"
  vpc_name = "flooding-vpc"
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2_public" {
  source = "./modules/ec2_public"


  ami_id                 = var.ami_id
  instance_type          = "t3.small"
  subnet_id              = module.vpc.public_subnet_id
  vpc_security_group_ids = [module.sg.backend_sg_id]
}

module "ec2_private" {
  source = "./modules/ec2_private"

  ami_id                 = var.ami_id
  instance_type          = "t3.small"
  subnet_id              = module.vpc.private_subnet_id
  vpc_security_group_ids = [module.sg.db_sg_id]
}

