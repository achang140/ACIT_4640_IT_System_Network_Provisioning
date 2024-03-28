output "ec2_instances" {
  value = aws_instance.ec2_instances
}

output "server_types" {
  value = aws_instance.ec2_instances[*].tags["server_type"]
}
