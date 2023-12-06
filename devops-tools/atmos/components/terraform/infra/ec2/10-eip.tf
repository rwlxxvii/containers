# Elastic IP allocation
resource "aws_eip" "eip_1" {
  instance = aws_instance.instance_1.id
  domain   = "vpc"

  tags = {
    Name = "eip-ec2-1"
  }

  depends_on = [aws_vpc.vpc_1]
}
