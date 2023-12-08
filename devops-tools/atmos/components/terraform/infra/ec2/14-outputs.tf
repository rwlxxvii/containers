output "eip_id" {
  description = "The unique identifier of the Elastic IP address allocated in AWS for this deployment"
  value       = aws_eip.eip_1.id
}

output "aws_eip_1_public_ip" {
  description = "The public IP address assigned to the Elastic IP, which can be used to connect to resources from the public internet"
  value       = aws_eip.eip_1.public_ip
}

output "eip_1_public_dns" {
  description = "The fully qualified domain name (FQDN) associated with the Elastic IP, which can also be used to connect to resources from the public internet"
  value       = aws_eip.eip_1.public_dns
}

output "instance_1_private_ip" {
  description = "The private IP address assigned to the EC2 instance, which is used for internal communication within the AWS network"
  value       = aws_instance.instance_1.private_ip
}

output "bucket_1_name" {
  description = "The name of the S3 bucket that is being used to store the Terraform state file"
  value       = aws_s3_bucket.bucket_1.bucket
}
