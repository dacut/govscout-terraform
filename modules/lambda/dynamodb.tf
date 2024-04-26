resource "aws_dynamodb_table" "govscout_access_log" {
  name         = "${local.project}${title(local.environment)}AccessLog"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "CrawlId"
  range_key    = "RequestId"

  attribute {
    name = "CrawlId"
    type = "S"
  }

  attribute {
    name = "RequestId"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  local_secondary_index {
    name            = "Timestamp"
    projection_type = "KEYS_ONLY"
    range_key       = "Timestamp"
  }
}
