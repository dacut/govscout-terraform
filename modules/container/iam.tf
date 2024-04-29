# resource "aws_iam_role" "govscout_crawler_codepipeline" {
#   name        = "${local.project}${title(local.environment)}CrawlerCodePipeline"
#   description = "CodePipeline access for ${local.project} in ${local.environment}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "codepipeline.amazonaws.com"
#         }
#         Action = [
#           "sts:AssumeRole",
#           "sts:TagSession",
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "govscout_crawler_codepipeline" {
#   name        = "${local.project}${title(local.environment)}CrawlerCodePipeline"
#   description = "Allow CodePipeline to build and deploy ${local.project} in ${local.environment}"

#   policy = jsonencode(
#     {
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Effect = "Allow"
#           Action = [
#             "codebuild:BatchGetBuilds",
#             "codebuild:StartBuild",
#             "codestar-connections:UseConnection",
#             "s3:GetObject",
#             "s3:GetObjectVersion",
#             "s3:GetBucketVersioning",
#             "s3:PutObject",
#           ]
#           Resource = [
#             aws_codestarconnections_connection.govscout_crawler.arn,
#             aws_s3_bucket.govscout_crawler_artifacts.arn,
#             "${aws_s3_bucket.govscout_crawler_artifacts.arn}/*",
#           ]
#         },
#       ]
#     }
#   )
# }

# resource "aws_iam_policy_attachment" "govscout_crawler_codepipeline" {
#   name       = aws_iam_role.govscout_crawler_codepipeline.name
#   policy_arn = aws_iam_policy.govscout_crawler_codepipeline.arn
#   roles      = [aws_iam_role.govscout_crawler_codepipeline.name]
# }

resource "aws_iam_role" "govscout_crawler_codebuild" {
  name        = "${local.project}${title(local.environment)}CrawlerCodeBuild"
  description = "CodeBuild access for ${local.project} in ${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "govscout_crawler_codebuild" {
  name        = "${local.project}${title(local.environment)}CrawlerCodeBuild"
  description = "Allow CodeBuild to push images to ECR"
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
            "lambda:UpdateFunctionCode",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Resource = [
            aws_ecr_repository.govscout_crawler.arn,
            aws_cloudwatch_log_group.govscout_codebuild_crawler.arn,
            "${aws_cloudwatch_log_group.govscout_codebuild_crawler.arn}:*",
            var.crawler_lambda_function_arn,
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr-public:GetAuthorizationToken",
            "ecr-public:BatchGetImage",
            "ecr-public:BatchCheckLayerAvailability",
            "ecr-public:GetDownloadUrlForLayer",
            "logs:DescribeLogGroups",
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
            "sts:GetServiceBearerToken",
          ]
          Resource = "*"
        },
      ]
    }
  )
}

resource "aws_iam_policy_attachment" "govscout_crawler_codebuild" {
  name       = aws_iam_role.govscout_crawler_codebuild.name
  policy_arn = aws_iam_policy.govscout_crawler_codebuild.arn
  roles      = [aws_iam_role.govscout_crawler_codebuild.name]
}
