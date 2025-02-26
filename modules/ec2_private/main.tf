
module "ec2_private" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-db-instance"

  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}