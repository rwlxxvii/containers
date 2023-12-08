# Random string generation
resource "random_id" "random_id_1" {
  byte_length = 5
}

# S3 bucket creation
resource "aws_s3_bucket" "bucket_1" {
  # S3 bucket name
  # Note that S3 buckets in AWS are global, which means that it is not possible to use a name that has been used by someone else
  bucket              = "terraform-state-storage-ec2-1-${random_id.random_id_1.hex}"
  object_lock_enabled = true

  tags = {
    Name = "terraform-state-storage-ec2-1"
  }

  depends_on = [
    random_id.random_id_1,
    aws_kms_key.kms_key_1,
    aws_s3_bucket.log_bucket_1
  ]
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "bucket_1_versioning" {
  bucket = aws_s3_bucket.bucket_1.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.bucket_1]
}

# S3 bucket public access configuration
resource "aws_s3_bucket_public_access_block" "bucket_1_public_access_block_block" {
  bucket = aws_s3_bucket.bucket_1.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.bucket_1]
}

# S3 bucket server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_1_sse_configuration" {
  bucket = aws_s3_bucket.bucket_1.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_key_1.arn
      sse_algorithm     = "aws:kms"
    }
  }

  depends_on = [
    aws_s3_bucket.bucket_1,
    aws_kms_key.kms_key_1
  ]
}

# Create a new S3 bucket to store logs
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "log_bucket_1" {
  bucket              = "terraform-state-storage-logs-ec2-1-${random_id.random_id_1.hex}"
  object_lock_enabled = true
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "log_bucket_1_versioning" {
  bucket = aws_s3_bucket.log_bucket_1.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.log_bucket_1]
}

# S3 bucket public access configuration
resource "aws_s3_bucket_public_access_block" "log_bucket_1_public_access_block_block" {
  bucket = aws_s3_bucket.log_bucket_1.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.log_bucket_1]
}

# Log bucket policy to allow write access for log delivery
resource "aws_s3_bucket_policy" "log_bucket_1_policy" {
  bucket = aws_s3_bucket.log_bucket_1.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.log_bucket_1.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket.log_bucket_1]
}

# S3 bucket server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_1_sse_configuration" {
  bucket = aws_s3_bucket.log_bucket_1.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_key_1.arn
      sse_algorithm     = "aws:kms"
    }
  }

  depends_on = [
    aws_s3_bucket.log_bucket_1,
    aws_kms_key.kms_key_1
  ]
}

# Enable logging for the main S3 bucket and set the log bucket as the target for log storage
resource "aws_s3_bucket_logging" "log_bucket_1_logging" {
  bucket = aws_s3_bucket.bucket_1.id

  # Specify the target bucket for storing logs and the prefix for log files
  target_bucket = aws_s3_bucket.log_bucket_1.id
  target_prefix = "log/"

  depends_on = [
    aws_s3_bucket.log_bucket_1,
    aws_s3_bucket.bucket_1
  ]
}

# Create a new S3 bucket to store logs
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "log_bucket_2" {
  bucket              = "vpc-flow-logs-ec2-1-${random_id.random_id_1.hex}"
  object_lock_enabled = true
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "log_bucket_2_versioning" {
  bucket = aws_s3_bucket.log_bucket_2.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.log_bucket_2]
}

# S3 bucket public access configuration
resource "aws_s3_bucket_public_access_block" "log_bucket_2_public_access_block_block" {
  bucket = aws_s3_bucket.log_bucket_2.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.log_bucket_2]
}

# Log bucket policy to allow write access for log delivery
resource "aws_s3_bucket_policy" "log_bucket_2_policy" {
  bucket = aws_s3_bucket.log_bucket_2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.log_bucket_2.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket.log_bucket_2]
}

# S3 bucket server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_2_sse_configuration" {
  bucket = aws_s3_bucket.log_bucket_2.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_key_1.arn
      sse_algorithm     = "aws:kms"
    }
  }

  depends_on = [
    aws_s3_bucket.log_bucket_2,
    aws_kms_key.kms_key_1
  ]
}

# Create a VPC Flow Log resource to enable flow logs for the VPC
resource "aws_flow_log" "vpc_1_flow_logs" {
  log_destination      = aws_s3_bucket.log_bucket_2.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc_1.id

  depends_on = [aws_s3_bucket.log_bucket_2]
}
