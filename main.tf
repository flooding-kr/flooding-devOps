provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = "10.0.0.0/16"
  environment        = "dev"
  public_subnet_cidr = "10.0.1.0/24"
}

module "ec2" {
  source = "./modules/ec2"

  ami_id       = "ami-0c9c942bd7bf113a2"  # Amazon Linux 2 AMI ID (서울 리전)
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnet_id
  environment   = "dev"
}
