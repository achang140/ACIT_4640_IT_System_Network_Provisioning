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

variable "availability_zone" {
  description = "List of availability zones"
}

# variable "public_subnet_id" {
#   description = "The public subnet to launch the first instance on"
# }

# variable "private_subnet_id" {
#   description = "The public subnet to launch the second instance on"
# }

variable "subnet_ids" {
  description = "Public and private subnets"
}

variable "security_groups" {
  description = "The security groups to launch the corresponding instance in"
}

variable "ssh_key_name" {
  description = "AWS SSH key name"
}

variable "name_tags" {
  description = "Names of the EC2 instances"
  default = ["Public EC2 Instance", "Private EC2 Instance"]
}

variable "server_types" {
  description = "Types of EC2 instances"
  default = ["public_ec2", "private_ec2"]
}
