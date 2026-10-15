variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name to identify project resources"
  type        = string
  default     = "akamai-assessment"
}

variable "instance_type" {
  description = "EC2 instance type for the server"
  type        = string
  default     = "t3.micro"
}
variable "ssh_key" {
  description = "Name of the EC2 key pair registered"
  type        = string
  default     = "akamai-assessment"
}
variable "ssh_allowed_cidr" {
  description = "CIDR allowed to ssh into the server (public ip/32)"
  type        = string
}
