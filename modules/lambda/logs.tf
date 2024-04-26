resource "aws_cloudwatch_log_group" "govscout_lambda_backend" {
  name              = "${local.environment}/${local.project}/LambdaBackend"
  retention_in_days = 365
}
