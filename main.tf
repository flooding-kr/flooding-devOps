provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = "10.0.0.0/20"
  azs                 = "ap-northeast-2a"
  environment         = "prod"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

module "ec2_public" {
  source = "./modules/ec2_public"


  ami_id        = "ami-024ea438ab0376a47" # Ubuntu 24.04 LTS (서울 리전)
  instance_type = "t3.small"
  subnet_id     = module.vpc.public_subnet_id
  environment   = "prod"
}

module "ec2_private" {
  source = "./modules/ec2_private"

  ami_id        = "ami-024ea438ab0376a47"
  instance_type = "t3.samll"
  subnet_id     = module.vpc.private_subnet_id
  environment   = "prod"

}
