resource "aws_iam_role" "github" {
  name        = "${local.project}${title(local.environment)}GitHubActions"
  description = "GitHub Actions role for ${local.project} in ${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo: dacut/govscout-backend:ref:refs/heads/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "github" {
  name       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github.arn
  roles      = [aws_iam_role.github.name]
}

resource "aws_iam_policy" "github" {
  name        = "${local.project}${title(local.environment)}GitHubActions"
  description = "Allow GitHub Actions to push images to ECR"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:DescribeImages",
            "ecr:GetDownloadUrlForLayer",
            "ecr:InitiateLayerUpload",
            "ecr:ListImages",
            "ecr:PutImage",
            "ecr:StartImageScan",
            "ecr:UploadLayerPart",
          ]
          Resource = aws_ecr_repository.govscout_backend.arn
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
          ]
          Resource = "*"
        }
      ]
    }
  )
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/jwks"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github.certificates[*].sha1_fingerprint
}
