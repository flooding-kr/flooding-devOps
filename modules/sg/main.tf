module "backend-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "flooding-backend-sg"
  description = "443, 80, 22 Open"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb-sg.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.alb-sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

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
  number_of_computed_ingress_with_source_security_group_id = 2
}

module "alb-sg" {
  source = "terraform-aws-modules/security-group/aws"
  
  name = "flooding-alb-sg"
  description = "80, 443 Open"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["https-443-tcp", "http-80-tcp"]
  egress_rules = ["all-all"]
}


