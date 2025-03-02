module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.repository_name
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 15 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 15
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = "prod"
  }
}