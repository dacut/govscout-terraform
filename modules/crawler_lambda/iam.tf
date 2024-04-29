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
          "dynamodb:PutItem",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectAttributes",
          "s3:GetObjectTagging",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionAttributes",
          "s3:GetObjectVersionTagging",
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:SendMessage",
          "ssm:GetParameter",
        ]
        Resource = [
          aws_dynamodb_table.govscout_crawler_log.arn,
          aws_s3_bucket.govscout_crawler_pages.arn,
          "${aws_s3_bucket.govscout_crawler_pages.arn}/*",
          aws_sqs_queue.crawl_queue.arn,
          "arn:${local.partition}:ssm:${local.region}:${local.account_id}:parameter/${local.project}/${title(local.environment)}/*",
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "govscout_lambda_crawler" {
  role       = aws_iam_role.govscout_lambda_crawler.name
  policy_arn = aws_iam_policy.govscout_lambda_crawler.arn
}
