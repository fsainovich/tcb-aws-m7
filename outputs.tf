output "ec2_instance_ip_address" {
  description = "The address of the EC2 instance"
  value       = aws_instance.ecommerce1.public_ip
}

output "elastic_ip_address" {
  description = "The address of the elastic IP"
  value       = aws_eip.EXTERNAL_IP.public_ip
}