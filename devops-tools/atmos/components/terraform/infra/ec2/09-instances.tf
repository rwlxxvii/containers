# EC2 Instance creation
resource "aws_instance" "instance_1" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  availability_zone      = var.ec2_availability_zone
  subnet_id              = aws_subnet.public_subnet_1a.id
  instance_type          = var.ec2_instance_1_type
  key_name               = var.key_pair_1_name
  monitoring             = var.ec2_monitoring
  vpc_security_group_ids = [aws_security_group.security_group_1.id]

  # Enforcing IMDSv2
  metadata_options {
    http_tokens                 = var.ec2_http_tokens
    http_put_response_hop_limit = var.ec2_http_put_response_hop_limit
    http_endpoint               = var.ec2_http_endpoint
  }

  # Root volume size configuration
  root_block_device {
    volume_size           = var.ec2_root_volume_1_size_gb
    volume_type           = var.ec2_root_volume_1_type
    encrypted             = var.ec2_root_volume_1_encryption
    delete_on_termination = var.ec2_delete_on_termination
  }

  # Instance connection establishment
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("./${var.key_pair_1_name}.pem")
    timeout     = "5m"
  }

  # Instance configuration
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt remove -y needrestart",
      "sudo apt upgrade -y",
      "sudo apt autoremove -y"
    ]
  }

  tags = {
    Name = "ec2-1"
  }

  depends_on = [
    aws_subnet.public_subnet_1a,
    aws_security_group.security_group_1,
    tls_private_key.private_key_1,
    aws_key_pair.key_pair_1
  ]
}
