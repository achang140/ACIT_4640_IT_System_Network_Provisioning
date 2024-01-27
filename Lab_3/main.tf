terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "base_cidr_block" {
  description = "default cidr block for vpc"
  default     = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block       = var.base_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-ipg"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-route"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# security group for instances COMPLETE ME!
resource "aws_security_group" "main" {
  
}

# security group egress rules COMPLETE ME!
resource "aws_vpc_security_group_egress_rule" "main" {
# make this open to everything from everywhere
}

# security group ingress rules COMPLETE ME!
resource "aws_vpc_security_group_ingress_rule" "main" {
# ssh and http in from everywhere
}

# get the most recent ami for Ubuntu 22.04
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
  public_key = file()
}

# ec2 instance COMPLETE ME!
resource "aws_instance" "ubuntu" {
  instance_type = "t2.micro"
  ami           = data.
  
  tags = {
    Name = "ubuntu-server"
  }

  key_name               =
  vpc_security_group_ids = 
  subnet_id              = aws_subnet.main.id

  root_block_device {
    volume_size = 10
  }
}

# output public ip address of the 2 instances
output "instance_public_ips" {
  value = aws_instance.ubuntu.public_ip
}


