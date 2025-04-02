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

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  instance_type          = "t3.medium"
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = module.server_sg.security_group_id
  subnet_id              = module.vpc.private_subnets[0]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y ruby
    wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install
    chmod +x ./install
    sudo ./install auto
    sudo service codedeploy-agent start
  EOF

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
      cidr_ipv4   = "0.0.0.0/0" # 모든 아웃바운드 트래픽 허용
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
      port        = 8080 # 80 → 8080 변경
      target_type = "instance"
      target_id   = module.server-instance.id
    }
  }

  tags = {
    Environment = var.environment
    Project     = "flooding"
  }
}
# ECR
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "flooding-ecr"

  repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# Cloud Watch
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "flooding-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Sum"
  threshold           = 10
  period              = 300
  alarm_description   = "ALB 5xx 에러 발생 감지"
  dimensions = {
    LoadBalancer = module.alb.lb_arn_suffix
  }
}


# Code Deploy
resource "aws_codedeploy_app" "flooding_app" {
  name = "flooding-app"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.flooding_app.name
  deployment_group_name = "flooding-dg"
  service_role_arn      = aws_iam_role.codedeploy_service.arn

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "flooding-server"
  }

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# CodePipline
resource "aws_codepipeline" "ecr_to_ec2" {
  name     = "flooding-ecr-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = module.s3_bucket.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "ECR_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["ecr_source"]

      configuration = {
        RepositoryName       = module.ecr.repository_name
        ImageTag             = var.image_tag
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "EC2_Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["ecr_source"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.flooding_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.main.deployment_group_name
      }
    }
  }
}

# IAM

resource "aws_iam_role" "codedeploy_service" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "codedeploy.amazonaws.com" }
    }]
  })
}
resource "aws_iam_role" "ec2_instance" {
  name = "EC2CodeDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2CodeDeployProfile"
  role = aws_iam_role.ec2_instance.name
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.alb_logs.json
}

data "aws_iam_policy_document" "alb_logs" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }
}

# S3

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "flooding-alb-logs"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
# Cloud Trail


# ACM
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "example.com"
  zone_id     = aws_route53_zone.private.zone_id
}