resource "aws_s3_bucket" "govscout_crawler_artifacts" {
  bucket_prefix = "${local.project_lower}-${local.environment_lower}-crawler-artifacts-"
}

resource "aws_s3_bucket_public_access_block" "govscout_crawler_artifacts" {
  bucket = aws_s3_bucket.govscout_crawler_artifacts.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "govscout_crawler_artifacts" {
  bucket = aws_s3_bucket.govscout_crawler_artifacts.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "govscout_crawler_artifacts" {
  bucket = aws_s3_bucket.govscout_crawler_artifacts.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "govscout_crawler_artifacts" {
  bucket = aws_s3_bucket.govscout_crawler_artifacts.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Action    = "*"
        Principal = "*"
        Resource  = [aws_s3_bucket.govscout_crawler_artifacts.arn, "${aws_s3_bucket.govscout_crawler_artifacts.arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      }
    ]
  })
}
