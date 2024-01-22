# Public subnet creation
resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = var.public_subnet_1a_cidr
  availability_zone = "${var.region}a"
  #tfsec:ignore:aws-ec2-no-public-ip-subnet
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-ec2-1-${var.region}a"
  }

  depends_on = [aws_vpc.vpc_1]
}
