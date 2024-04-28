resource "aws_sqs_queue" "crawl_queue" {
  name                      = "${local.project}${title(local.environment)}Crawl"
  message_retention_seconds = 300
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.crawl_dead_letter_queue.arn
    maxReceiveCount     = 5
  })
  visibility_timeout_seconds = 610
}

resource "aws_sqs_queue" "crawl_dead_letter_queue" {
  name                      = "${local.project}${title(local.environment)}CrawlDLQ"
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
}

