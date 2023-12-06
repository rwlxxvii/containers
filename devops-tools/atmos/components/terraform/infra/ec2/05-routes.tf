# Public route table creation
resource "aws_route_table" "public_route_1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = var.public_route_1_cidr
    gateway_id = aws_internet_gateway.igw_1.id
  }

  tags = {
    Name = "public-route-ec2-1"
  }

  depends_on = [aws_internet_gateway.igw_1]
}

# Public route table association
resource "aws_route_table_association" "public_subnet_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_route_1.id

  depends_on = [
    aws_subnet.public_subnet_1a,
    aws_route_table.public_route_1
  ]
}
