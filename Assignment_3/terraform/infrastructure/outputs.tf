# ------------------------------------------------------------------------------------------------------------------
# Define module outputs - these output to the command line for main module
# ------------------------------------------------------------------------------------------------------------------

output "ec2_instance_ids" {
  value = module.ec2.ec2_instances[*].id
}

output "ec2_instance_public_ips" {
  value = module.ec2.ec2_instances[*].public_ip
}

output "ec2_instance_dns_names" {
  value = module.ec2.ec2_instances[*].public_dns
}

output "public_security_group" {
  value = module.sg.public_sg_id
}

output "private_security_group" {
  value = module.sg.private_sg_id
}

output "private_ssh_key_path" {
  value = "${path.module}/${var.ssh_key_name}.pem"
}

output "public_ssh_key_path" {
  value = "${path.module}/${var.ssh_key_name}.pem.pub"
}
