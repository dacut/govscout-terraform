# We use CodeBuild because GitHub Actions doesn't (yet) support
# ARM runners.
resource "aws_codebuild_project" "govscout_crawler" {
  name           = "${local.project}${title(local.environment)}Crawler"
  description    = "Build and deploy the ${local.project} crawler in ${local.environment}"
  build_timeout  = 30
  service_role   = aws_iam_role.govscout_crawler_codebuild.arn
  queued_timeout = 60
  source_version = var.crawler_branch

  artifacts {
    type                = "S3"
    path                = "${local.project}/${title(local.environment)}/CrawlerBuildArtifacts"
    namespace_type      = "BUILD_ID"
    packaging           = "NONE"
    bucket_owner_access = "FULL"
    location            = aws_s3_bucket.govscout_crawler_artifacts.bucket
  }

  environment {
    compute_type    = "BUILD_GENERAL1_LARGE"
    type            = "ARM_CONTAINER"
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
    }

    environment_variable {
      name  = "ECR_REPOSITORY_URL"
      value = aws_ecr_repository.govscout_crawler.repository_url
    }

    environment_variable {
      name  = "LAMBDA_FUNCTION_NAME"
      value = replace(data.aws_arn.crawler_lambda_function.resource, "function:", "")
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.govscout_codebuild_crawler.name
    }
  }

  source {
    type            = "GITHUB"
    git_clone_depth = 0
    location        = var.crawler_repository
  }

  depends_on = [aws_iam_policy_attachment.govscout_crawler_codebuild]
}

resource "aws_cloudwatch_log_group" "govscout_codebuild_crawler" {
  name              = "/${local.environment}/${local.project}/CrawlerCodeBuild"
  retention_in_days = 365
}
