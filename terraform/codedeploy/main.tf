resource "aws_codedeploy_app" "flooding-deploy" {
  compute_platform = "Server"
  name             = "flooding-deploy"
}

resource "aws_codedeploy_deployment_group" "flooding-deploy-DG" {
  app_name              = aws_codedeploy_app.flooding-deploy.name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = aws_iam_role.example.arn
  autoscaling_groups = [ var.asg_name ]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    elb_info {
      name = var.alb_name
    }
  }
  

  blue_green_deployment_config {
    deployment_ready_option {
      #만약 배포에 문제가 지속해서 생길 경우 STOP_DEPLOYMENT로 변경 후 수동 확인
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 10
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }
}