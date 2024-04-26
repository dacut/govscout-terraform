resource "aws_lambda_function" "govscout_backend" {
  function_name = local.lambda_function_name
  description   = "Backend for ${local.project} in ${local.environment}"

  architectures = ["arm64"]
  package_type  = "Image"
  memory_size   = 1024
  image_uri     = "${var.ecr_repository_url}:base"
  role          = aws_iam_role.govscout_lambda_backend.arn
  timeout       = 600

  logging_config {
    log_group  = aws_cloudwatch_log_group.govscout_lambda_backend.name
    log_format = "Text"
  }

  environment {
    variables = {
      LOG_S3_BUCKET      = aws_s3_bucket.govscout_pages.bucket
      LOG_S3_PREFIX      = "pages/"
      LOG_DYNAMODB_TABLE = aws_dynamodb_table.govscout_access_log.name
      LOG_SSM_PREFIX     = "/${local.project}/${title(local.environment)}/"
    }
  }

  depends_on = [
    null_resource.ecr_image_bootstrap,
  ]
  lifecycle {
    ignore_changes = [
      image_uri,
    ]
  }
}

# Populate the ECR repository with a LambdaNOP image.
resource "null_resource" "ecr_image_bootstrap" {
  provisioner "local-exec" {
    command = "aws --region us-east-1 ecr-public get-login-password | docker login --username AWS --password-stdin public.ecr.aws && aws --region ${local.region} ecr get-login-password | docker login --username AWS --password-stdin ${var.ecr_repository_url} && docker pull public.ecr.aws/kanga/lambda-nop:latest && docker tag public.ecr.aws/kanga/lambda-nop:latest ${var.ecr_repository_url}:base && docker push ${var.ecr_repository_url}:base"
  }
}
