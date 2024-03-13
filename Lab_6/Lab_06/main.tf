terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# provider block specify region
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "main"
  }
}

# create internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-ipg"
  }
}

# create route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-route"
  }
}

# create route to public internet
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# rout table association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# security group for instances
resource "aws_security_group" "main" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # open to all 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main"
  }
}

# get the most recent ami for Ubuntu 23.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

# key pair from local key
resource "aws_key_pair" "local_key" {
  key_name   = "AWS_Key"
  public_key = file("~/.ssh/4640-Key.pub")
}

# ec2 instances create 2 with count
#resource "aws_instance" "ubuntu" {
#  instance_type = "t2.micro"
#  ami           = data.aws_ami.ubuntu.id
#  count         = 2

#  tags = {
#    Name = "ubuntu-server-${count.index}"
#  }

#  key_name               = aws_key_pair.local_key.id
#  vpc_security_group_ids = [aws_security_group.main.id]
#  subnet_id              = aws_subnet.main.id
#}

#import {
#  to = aws_instance.ubuntu[0]
#  id = "i-05a994e924e5cea98"
#}

resource "aws_instance" "single_ubuntu" {
  instance_type = "t2.micro"
  ami = data.aws_ami.ubuntu.id
}

import {
  to = aws_instance.single_ubuntu
  id = "i-0f4b7c275957e77ef"
}


