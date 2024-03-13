variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "home_net" {
  description = "CIDR block for home network"
  type        = string
}

variable "bcit_net" {
  description = "CIDR block for BCIT network"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

