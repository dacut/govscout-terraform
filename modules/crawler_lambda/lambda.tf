resource "aws_lambda_function" "govscout_crawler" {
  function_name = local.lambda_function_name
  description   = "Crawler for ${local.project} in ${local.environment}"

  architectures = ["arm64"]
  package_type  = "Image"
  memory_size   = 1024
  image_uri     = "${var.crawler_ecr_repository_url}:${local.crawler_ecr_image_tag}"
  role          = aws_iam_role.govscout_lambda_crawler.arn
  timeout       = aws_sqs_queue.crawl_queue.visibility_timeout_seconds - 10

  logging_config {
    log_group  = aws_cloudwatch_log_group.govscout_lambda_crawler.name
    log_format = "Text"
  }

  environment {
    variables = {
      LOG_S3_BUCKET      = aws_s3_bucket.govscout_crawler_pages.bucket
      LOG_S3_PREFIX      = "pages/"
      LOG_DYNAMODB_TABLE = aws_dynamodb_table.govscout_crawler_log.name
      SQS_QUEUE_URL      = aws_sqs_queue.crawl_queue.url
      SSM_PREFIX         = "/${local.project}/${title(local.environment)}/"
      RUST_LOG           = "debug"
      RUST_BACKTRACE     = "1"
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
    command = "aws --region us-east-1 ecr-public get-login-password | docker login --username AWS --password-stdin public.ecr.aws && aws --region ${local.region} ecr get-login-password | docker login --username AWS --password-stdin ${var.crawler_ecr_repository_url} && docker pull public.ecr.aws/kanga/lambda-nop:latest && docker tag public.ecr.aws/kanga/lambda-nop:latest ${var.crawler_ecr_repository_url}:base && docker push ${var.crawler_ecr_repository_url}:base"
  }
}

resource "aws_lambda_permission" "govscout_crawler_sqs" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.govscout_crawler.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.crawl_queue.arn
}

resource "aws_lambda_event_source_mapping" "govscout_crawler_sqs" {
  event_source_arn = aws_sqs_queue.crawl_queue.arn
  function_name    = aws_lambda_function.govscout_crawler.function_name
  batch_size       = 10
  enabled          = true

  scaling_config {
    maximum_concurrency = 2
  }

  depends_on = [
    aws_lambda_permission.govscout_crawler_sqs,
    aws_iam_policy.govscout_lambda_crawler,
    aws_iam_role_policy_attachment.govscout_lambda_crawler,
  ]
}
