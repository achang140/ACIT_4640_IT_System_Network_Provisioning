# Terraform Provider - Terraform can download and use the correct provider plugin 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider with the region to use 
provider "aws" {
  shared_config_files      = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile = "acit4640_admin"
  region = "us-west-2"
}

variable "base_cidr_block" {
  description = "default cidr block for vpc"
  default     = "10.0.0.0/16"
}

# Create a VPC named main 
resource "aws_vpc" "main" {
  cidr_block       = var.base_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# Creates a Subnet named main within the VPC 
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "main"
  }
}

# Creates an Internet Gateway named main that attaches to the VPC 
# Allows traffic to and from the internet 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-ipg"
  }
}

# Creates a Route Table named main that associates with the VPC 
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-route"
  }
}

# Creates a Route named default_route that is added to the Route Table 
# All traffic with the destination CIDR block of 0.0.0.0/0 (Any IP Address) should be routed to the Internet Gateway 
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Creates an association between the Subnet and the Route Table
# The subnet will use the Route Table for routing its traffic  
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# security group for instances COMPLETE ME!
resource "aws_security_group" "main" {
  name   = "main"
  vpc_id = aws_vpc.main.id 
}

# security group egress rules COMPLETE ME!
resource "aws_security_group_rule" "main_egress" {
# make this open to everything from everywhere
  type              = "egress"
  security_group_id = aws_security_group.main.id 
  from_port         = 0 
  to_port           = 0 
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# security group ingress rules COMPLETE ME!
resource "aws_security_group_rule" "main_ingress_ssh" {
# ssh in from everywhere
  type              = "ingress"
  security_group_id = aws_security_group.main.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp" 
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "main_ingress_http" {
# http in from everywhere
  type              = "ingress"
  security_group_id = aws_security_group.main.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp" 
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# Get the most recent ami for Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

# key pair from local key COMPLETE ME!
resource "aws_key_pair" "local_key" {
  key_name   = "4640-Key"
  public_key = file("/home/amanda/.ssh/4640-Key.pub")
}

# ec2 instance COMPLETE ME!
resource "aws_instance" "ubuntu" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id
  
  tags = {
    Name = "ubuntu-server"
  }

  key_name               = aws_key_pair.local_key.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = aws_subnet.main.id

  root_block_device {
    volume_size = 10
  }
}

# output public ip address of the 2 instances
output "instance_public_ips" {
  value = aws_instance.ubuntu.public_ip
}