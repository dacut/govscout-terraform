resource "aws_ecr_repository" "govscout_backend" {
  name                 = "${local.project_lower}-backend-${local.environment_lower}"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "govscout_backend" {
  repository = aws_ecr_repository.govscout_backend.name

  policy = jsonencode(
    {
      rules = [
        {
          rulePriority = 1
          description  = "Expire untagged images older than 14 days"
          selection = {
            tagStatus   = "untagged"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = 14
          }
          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 2
          description  = "Keep last 30 tagged images"
          selection = {
            tagStatus     = "tagged"
            tagPrefixList = ["v"]
            countType     = "imageCountMoreThan"
            countNumber   = 30
          }
          action = {
            type = "expire"
          }
        }
      ]
    }
  )
}

resource "aws_ecr_repository_policy" "govscout_backend" {
  repository = aws_ecr_repository.govscout_backend.name

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "Lambda"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer",
          ]
        }
      ]
    }
  )
}
