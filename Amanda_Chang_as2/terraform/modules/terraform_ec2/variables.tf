variable "instance_type" {
  description = "EC2 instance type"
}

variable "ami_id" {
  description = "AMI ID"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
}

variable "aws_region" {
  description = "AWS region"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "public_subnet_id_1" {
  description = "The public subnet to launch the first instance on"
}

variable "public_subnet_id_2" {
  description = "The public subnet to launch the second instance on"
}

variable "security_group_id" {
  description = "The security group to launch the instance in"
}

variable "ssh_key_name" {
  description = "AWS SSH key name"
}

variable "name_tag" {
  description = "Name of the EC2 instances"
  default = "Public EC2 Instance"
}
