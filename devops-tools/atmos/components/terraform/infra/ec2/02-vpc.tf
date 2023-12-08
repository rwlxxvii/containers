# VPC creation
resource "aws_vpc" "vpc_1" {
  cidr_block = var.vpc_1_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-ec2-1"
  }
}
