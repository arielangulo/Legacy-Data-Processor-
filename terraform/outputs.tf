output "public_ip" {
  description = "Public IP address of the Data Processor server"
  value       = aws_instance.dataproc.public_ip
}