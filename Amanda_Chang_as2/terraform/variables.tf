variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "base_cidr_block" {
    description = "Base CIDR Block"
}

variable "project_name" {
  description = "Project name"
}

variable "ssh_key_name"{
  description = "AWS SSH key name"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["us-west-2a", "us-west-2b"]
}
