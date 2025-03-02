module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = var.alb_name
  vpc_id  = var.vpc_id
  subnets = var.subnet_id

  security_groups = var.security_group_id
  


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
      certificate_arn = "arn:aws:acm:ap-northeast-2:495740757494:certificate/9e29cb8d-3bd6-455c-87c2-43a50165e32b"

      forward = {
        target_group_key = "flooding-backend"
      }
    }
  }

  target_groups = {
    flooding-backend = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = var.instance_id
    }
  }
}

