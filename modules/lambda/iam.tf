resource "aws_iam_role" "govscout_lambda_backend" {
  name = "${local.project}${title(local.environment)}LambdaBackend"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "govscout_lambda_backend" {
  name        = "${local.project}${title(local.environment)}LambdaBackend"
  description = "Lambda policy for ${local.project} backend in ${local.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "${aws_cloudwatch_log_group.govscout_lambda_backend.arn}:log-stream:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = [
          aws_s3_bucket.govscout_pages.arn,
          "${aws_s3_bucket.govscout_pages.arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
        ]
        Resource = aws_dynamodb_table.govscout_access_log.arn
      }
    ]
  })
}
