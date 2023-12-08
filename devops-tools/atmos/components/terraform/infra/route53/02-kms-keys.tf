# KMS key creation
resource "aws_kms_key" "kms_key_1" {
  description             = "KMS key for terraform state storage bucket"
  deletion_window_in_days = var.kms_key_1_default_retention_days
  enable_key_rotation     = true
}

# Creating an AWS KMS alias
resource "aws_kms_alias" "kms_key_1_alias" {
  name          = "alias/terraform-bucket-key-route53-1"
  target_key_id = aws_kms_key.kms_key_1.key_id

  depends_on = [aws_kms_key.kms_key_1]
}

# Creating an AWS KMS alias
resource "aws_kms_key" "kms_key_2" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = var.kms_key_2_default_retention_days
  enable_key_rotation     = true
}

# Creating an AWS KMS alias
resource "aws_kms_alias" "kms_key_2_alias" {
  name          = "alias/dynamodb-table-encryption-route53-1"
  target_key_id = aws_kms_key.kms_key_2.key_id

  depends_on = [aws_kms_key.kms_key_2]
}
