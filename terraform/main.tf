provider "aws" {
  region = var.region
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "flooding-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]


  private_subnet_names = ["flooding-private-subnet-a", "flooding-private-subnet-c", "flooding-protected-subnet-a", "flooding-protected-subnet-c"]
  public_subnet_names  = ["flooding-public-subnet-a", "flooding-public-subnet-c"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# NAT
module "nat-instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-nat"

  instance_type          = "t3.small"
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = module.nat_sg.security_group_id
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# SERVER
module "server-instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-server"

  instance_type          = "t3.medium"
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = module.server_sg.security_group_id
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# DB
module "db-instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-db"

  instance_type          = "t3.medium"
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = module.db_sg.security_group_id
  subnet_id              = module.vpc.private_subnets[2]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# NAT_SG
module "nat_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-nat-sg"
  description = "80, 443, ICMPv4, 465, 587"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      rule        = "all-icmp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule        = "smtps-465-tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule        = "smtp-submission-587-tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
      # 추 후 수정 개인 ip로
    }

  ]
}
# SERVER_SG
module "server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-server-sg"
  description = "8080, 22"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.alb.security_group_id
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.nat_sg.security_group_id
    }
  ]
}

# DB_SG
module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-db-sg"
  description = "5432, 22"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.server_sg.security_group_id
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.nat_sg.security_group_id
    }
  ]
}
# ALB
# ALB 모듈 수정
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "flooding-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"  # 모든 아웃바운드 트래픽 허용
    }
  }

  access_logs = {
    bucket = "flooding-alb-logs"
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "flooding-server"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix = "h1"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = module.server-instance.id
    }
  }

  tags = {
    Environment = var.environment
    Project     = "flooding"
  }
}