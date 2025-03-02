module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "flooding-backend-instance"

  instance_type          = "t3.medium"
  ami = var.ami_id
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
  user_data = var.user_data

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}