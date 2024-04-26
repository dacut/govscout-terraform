resource "aws_iam_role" "govscout_lambda_crawler" {
  name        = "${local.project}${title(local.environment)}LambdaCrawler"
  description = "Lambda role for ${local.project} crawler in ${local.environment}"
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

resource "aws_iam_policy" "govscout_lambda_crawler" {
  name        = "${local.project}${title(local.environment)}LambdaCrawler"
  description = "Lambda policy for ${local.project} crawler in ${local.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "${aws_cloudwatch_log_group.govscout_lambda_crawler.arn}:log-stream:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = [
          aws_s3_bucket.govscout_crawler_pages.arn,
          "${aws_s3_bucket.govscout_crawler_pages.arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
        ]
        Resource = aws_dynamodb_table.govscout_crawler_log.arn
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Resource = aws_sqs_queue.crawl_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "govscout_lambda_crawler" {
  role       = aws_iam_role.govscout_lambda_crawler.name
  policy_arn = aws_iam_policy.govscout_lambda_crawler.arn
}
