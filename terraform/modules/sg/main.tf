module "backend-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-backend-sg"
  description = "443, 80, ,22, 8080 Open"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb-sg.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.alb-sg.security_group_id
    },
    {
      rule = "http-8080-tcp"
      source_security_group_id = module.alb-sg.security_group_id
    }

  ]
  number_of_computed_ingress_with_source_security_group_id = 3

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "db-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-db-sg"
  description = "5432, 22 Open"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.backend-sg.security_group_id
    },
    {
      rule = "ssh-tcp"
      source = module.backend-sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "alb-sg" {
  source = "terraform-aws-modules/security-group/aws"
  
  name = "flooding-alb-sg"
  description = "80, 443, 8080 Open"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["https-443-tcp", "http-80-tcp", "http-8080-tcp"]
  egress_cidr_blocks = var.vpc_cidr
  egress_rules = ["all-all"]
}


