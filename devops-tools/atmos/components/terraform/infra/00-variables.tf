# AWS Infrastructure Variables
variable "region" {
  description = "The AWS region in which the infrastructure will be deployed"
  type        = string
  default     = "eu-west-1"
}

# Virtual Private Cloud Variables
variable "vpc_1_cidr" {
  description = "The IP range for the Virtual Private Cloud (VPC) that will be created"
  type        = string
  default     = "10.1.0.0/16"
}

# Public Subnet Variables
variable "public_subnet_1a_cidr" {
  description = "The IP range for the public subnet that will be created within the VPC"
  type        = string
  default     = "10.1.4.0/24"
}

# Route Variables
variable "public_route_1_cidr" {
  description = "The CIDR block for the public route in the route table. This allows traffic to be directed to the internet gateway and out to the public internet"
  type        = string
  default     = "0.0.0.0/0"
}

# Instance Variables
variable "ec2_instance_1_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.small"
}

variable "ec2_root_volume_1_size_gb" {
  description = "The size (in GB) of the root volume for the EC2 instance"
  type        = number
  default     = 80
}

variable "ec2_root_volume_1_type" {
  description = "The type of the root volume for the EC2 instance (e.g. gp2, io1, st1, sc1)"
  type        = string
  default     = "gp2"
}

variable "ec2_root_volume_1_encryption" {
  description = "A flag to enable or disable EBS volume encryption"
  type        = bool
  default     = true
}

variable "ec2_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination"
  type        = bool
  default     = true
}

variable "ec2_monitoring" {
  description = "Whether the instance should be monitored"
  type        = bool
  default     = true
}

variable "ec2_http_tokens" {
  description = "State of token usage for Instance Metadata Service"
  type        = string
  default     = "required"
}

variable "ec2_http_put_response_hop_limit" {
  description = "The max no of hops made by the PUT response of IMDS"
  type        = number
  default     = 1
}

variable "ec2_http_endpoint" {
  description = "Whether the IMDS is available"
  type        = string
  default     = "enabled"
}

variable "ec2_availability_zone" {
  description = "The AWS Availability Zone where the EC2 instance should be deployed"
  type        = string
  default     = "eu-west-1a"
}

# Key Pair Variables
variable "key_pair_1_name" {
  description = "The name of the key pair used to authenticate with the EC2 instance"
  type        = string
  default     = "key-pair-ec2-1"
}

# KMS Variables
variable "kms_key_1_default_retention_days" {
  description = "The default retention period in days for keys created in the KMS keyring"
  type        = number
  default     = 10
}

variable "kms_key_2_default_retention_days" {
  description = "The default retention period in days for keys created in the KMS keyring"
  type        = number
  default     = 10
}

# DynamoDB Variables
variable "dynamodb_terraform_state_lock_1_billing_mode" {
  description = "The billing mode for the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "PAY_PER_REQUEST"
}
