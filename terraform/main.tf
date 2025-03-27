provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "flooding-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  

  private_subnet_names = ["flooding-private-subnet-a", "flooding-private-subnet-c", "flooding-protected-subnet-a", "flooding-protected-subnet-c"]
  public_subnet_names = ["flooding-public-subnet-a", "flooding-public-subnet-c"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Environment = var.environment
  }
}

module "nat-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-nat-instance"

  instance_type          = "t3.small"
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = module.nat_sg.security_group_id
  subnet_id              = module.vpc.public_subnets.id[0]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

module "server-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-server-instance"

  instance_type          = "t3.medium"
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = 
  subnet_id              = module.vpc.private_subnets.id[0]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

module "db-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-db-instance"

  instance_type          = "t3.medium"
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = 
  subnet_id              = module.vpc.private_subnets.id[2]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

module "nat_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-nat-sg"
  description = "80, 443, ICMPv4, 465, 587"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      rule        = "icmp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule        = "smtp-465-tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule        = "smtp-587-tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
        rule = "ssh-tcp"
        cidr_blocks = "0.0.0.0/0"
        # 추 후 수정 개인 ip로
    }

  ]
}

module "server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-server-sg"
  description = "8080, 22"
  vpc_id      = "vpc-12345678"

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-db-sg"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "vpc-12345678"

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-alb-sg"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "vpc-12345678"

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}