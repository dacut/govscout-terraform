resource "aws_s3_bucket" "govscout_crawler_pages" {
  bucket_prefix = "${local.project_lower}-${local.environment_lower}-crawler-pages-"
}

resource "aws_s3_bucket_public_access_block" "govscout_crawler_pages" {
  bucket = aws_s3_bucket.govscout_crawler_pages.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "govscout_crawler_pages" {
  bucket = aws_s3_bucket.govscout_crawler_pages.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "govscout_crawler_pages" {
  bucket = aws_s3_bucket.govscout_crawler_pages.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "govscout_crawler_pages" {
  bucket = aws_s3_bucket.govscout_crawler_pages.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Action    = "*"
        Principal = "*"
        Resource  = [aws_s3_bucket.govscout_crawler_pages.arn, "${aws_s3_bucket.govscout_crawler_pages.arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      }
    ]
  })
}
