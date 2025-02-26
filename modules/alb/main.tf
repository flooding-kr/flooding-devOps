module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = var.alb_name
  vpc_id  = var.vpc_id
  subnets = var.subnet_id

  security_groups = var.security_group_id
  

  access_logs = {
    bucket = "my-alb-logs"
  }

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = var.instance_id
    }
  }
}