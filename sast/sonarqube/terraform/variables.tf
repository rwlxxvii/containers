variable "lambda_zip_location" {
  default = "../process_scans.zip"
}

variable "runtime" {
  description = "runtime for lambda"
  default     = "python3.11"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "dependabot_lambda_memory" {
  default = 2048
}

variable "dependabot_lambda_timeout" {
  default = 900
}

variable "fqdn" {
  default = "dev.sonarqube.io"
}

output "fqdn" {
  value = var.fqdn
}
