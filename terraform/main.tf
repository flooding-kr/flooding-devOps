provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr[0]
  vpc_name = "flooding-vpc"
}

module "sg" {
  source   = "./modules/sg"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "ec2_public" {
  source = "./modules/ec2_public"


  ami_id                 = var.ami_id
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.public_subnet_id[0]
  vpc_security_group_ids = [module.sg.backend_sg_id]
}

module "ec2_private" {
  source = "./modules/ec2_private"

  ami_id                 = var.ami_id
  instance_type          = "t3.small"
  subnet_id              = module.vpc.private_subnet_id[0]
  vpc_security_group_ids = [module.sg.db_sg_id]
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "flooding-ecr"
}

module "alb" {
  source            = "./modules/alb"
  alb_name          = "flooding-alb"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnet_id
  instance_id       = module.ec2_public.instance_id
  security_group_id = [module.sg.alb_sg_id]

}


