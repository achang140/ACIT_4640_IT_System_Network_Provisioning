##-#-#-#-#-#-#-#-#-#-#-#-#-##
#  ACIT 4640 Assignment 2  # 
# Amanda Chang - A01294905 #
##-#-#-#-#-#-#-#-#-#-#-#-#-##

# ------------------------------------------------------------------------------------------------------------------
# Configure an AWS VPC with a public and a private subnet, along with an internet gateway, route tables, and security groups. 
# Each subnet hosts an EC2 instance.
# ------------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------------
# Terraform Provider

# source: Location of AWS Provider
# version: Version of the provider to use; should be 5.0 or higher
# ------------------------------------------------------------------------------------------------------------------

# terraform {
#     required_providers {
#         aws = {
#             source = "hashicorp/aws"
#             version = "~> 5.0"
#         }
#     }
# }

# ------------------------------------------------------------------------------------------------------------------
# Define Local Variables to be used within the main Terraform module (main.tf)

# base_cidr_block - Base CIDR block for VPC 
# project_name - Specifies the name of the project 
# availability_zone - Availability Zone for public and private subnets 
# ssh_key_name - Name of the SSH key pair to use for EC2 instances
# ------------------------------------------------------------------------------------------------------------------

locals {
    base_cidr_block   = "10.0.0.0/16"
    project_name      = "acit4640_assignment1"
    # availability_zone = "us-west-2a" 
    ssh_key_name      = "acit4640_assignment"
}

# ------------------------------------------------------------------------------------------------------------------
# Configure the AWS Provider 

# region - Region where the AWS provider should operate (Oregon / us-west-2)
# default_tags block - Default tag that will apply to all resources created by the AWS provider
# ------------------------------------------------------------------------------------------------------------------

# provider "aws" {
#     region = "us-west-2"
    
#     default_tags {
#         tags = {
#             Project = "${local.project_name}"
#         }
#     }
# }

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Setup Network Infrastructure: VPC, Subnets (Public and Private), Internet Gateway, Route Tables 
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# ------------------------------------------------------------------------------------------------------------------
# VPC
# cidr_block - IP Address range for the VPC 
# instance_tenancy = "default" - Instances will be launched on the same hardware 
# enable_dns_hostnames = true - Any EC2 instances launched in the VPC will have an AWS-provided DNS hostname 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "acit4640_vpc" {
    cidr_block           = local.base_cidr_block
    instance_tenancy     = "default"
    enable_dns_hostnames = true 

    tags = {
        Name = "${local.project_name}_vpc"
    }
}

# ------------------------------------------------------------------------------------------------------------------
# Public and Private Subnets 

# vpc_id - ID of the VPC in which the Subnets will be created 
# cidr_block - IP Address range for the Subnet 
# availability_zone - Availability Zone in which the Subnets will be created  
# map_public_ip_on_launch = true - Instance launch in the Public Subnet will have a public IP address 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.acit4640_vpc.id
    cidr_block              = "10.0.0.0/20" 
    availability_zone       = local.availability_zone 
    map_public_ip_on_launch = true 

    tags = {
        Name = "${local.project_name}_public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id            = aws_vpc.acit4640_vpc.id
    cidr_block        = "10.0.128.0/20" 
    availability_zone = local.availability_zone 

    tags = {
        Name = "${local.project_name}_private_subnet"
    }
}

# ------------------------------------------------------------------------------------------------------------------
# Internet Gateway - Allows Public Instance within the VPC to communicate with the Internet 

# vpc_id - ID of the VPC in which the Internet Gateway will be created 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "acit4640_igw" {
    vpc_id = aws_vpc.acit4640_vpc.id

    tags = {
        Name = "${local.project_name}_igw"
    }
}

# ------------------------------------------------------------------------------------------------------------------
# Public Route Table 
# vpc_id - ID of the VPC in which the Public Route Table will be created

# Additional Route for Public RT 
### Enables all traffic with destination IP addresses outside of the VPC to reach the Internet Gateway
# route_table_id - ID of the Route Table where the Route will be created 
# destination_cidr_block = "0.0.0.0/0" - The Route applies to all IP addresses 
# gateway_id = ID of the Internet Gateway to use for the Route 

# Public Subnet and Public RT Association 
# subnet_id - ID of the Public Subnet to be associated with the Public RT
# route_table_id - ID of the Public Route Table to be associated with the Public Subnet 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.acit4640_vpc.id

    tags = {
        Name = "${local.project_name}_public_rt"
    }
}

resource "aws_route" "default_route" {
    route_table_id         = aws_route_table.public_rt.id 
    destination_cidr_block = "0.0.0.0/0" 
    gateway_id             = aws_internet_gateway.acit4640_igw.id 
}

resource "aws_route_table_association" "public_subnet_rt" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

# ------------------------------------------------------------------------------------------------------------------
# Private Route Table 
# vpc_id - ID of the VPC in which the Private Route Table will be created

# Private Subnet and Private RT Association 
# subnet_id - ID of the Private Subnet to be associated with the Private RT
# route_table_id - ID of the Private Route Table to be associated with the Private Subnet 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.acit4640_vpc.id 

    tags = {
        Name = "${local.project_name}_private_rt"
    }
}

resource "aws_route_table_association" "private_subnet_rt" {
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# Setup Security Groups and Rules 

# Security Group 
# name - Name of the Security Group 
# description - Description of the Security Group 
# vpc_id = ID of the VPC in which the Security Group will be created 

# SG Egress Rule (Outbound Rule)
# security_group_id - ID of the Security Group to which Egress Rule will be added 
# ip_protocol="-1" - Sets the IP protocol that the SG rules should apply to. -1 means ALL protocols. 
# cidr_ipv4="0.0.0.0/0" - SG Rule applies to all IPV4 addressess 

# SG Ingress Rule (Inbound Rule)
# security_group_id - ID of the Security Group to which Ingress Rule will be added 
# ip_protocol="tcp" - TCP IP protocol is used for SSH and HTTP 
# from_port and to_port - Set the range of port numbers that Ingress Rule should apply to 
# cidr_ipv4="0.0.0.0/0" - SG Rule applies to all IPV4 addressess 
# referenced_security_group_id - Allow traffic from a specified SG 
    # Private Ingress Rule - Allows inbound SSH and HTTP traffic from any instances associated with public_sg 

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# ------------------------------------------------------------------------------------------------------------------
# Security Group for Public EC2 Instance 

# Public SG Egress Rule 
# Allows all outbound traffic 

# Public SG Ingress Rule 
# Allows SSH and HTTP from everywhere 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "public_sg" {
    name        = "${local.project_name}_public_sg"
    description = "Allow SSH and HTTP in from everywhere and allow all outbound traffic"
    vpc_id      = aws_vpc.acit4640_vpc.id 

    tags = {
        Name = "${local.project_name}_public_sg"
    }
}

resource "aws_vpc_security_group_egress_rule" "outbound_public_sg" {
    description       = "Allow all outbound traffic"
    security_group_id = aws_security_group.public_sg.id 
    ip_protocol       = "-1" # Matches all protocols 
    cidr_ipv4         = "0.0.0.0/0"

    tags = {
        Name = "${local.project_name}_outbound_public_sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_ssh_public_sg" {
    description       = "Allow SSH from everywhere"
    security_group_id = aws_security_group.public_sg.id 
    ip_protocol       = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_ipv4         = "0.0.0.0/0"
    
    tags = {
        Name = "${local.project_name}_inbound_ssh_public_sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_http_public_sg" {
    description       = "Allow HTTP from everywhere"
    security_group_id = aws_security_group.public_sg.id 
    ip_protocol       = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_ipv4         = "0.0.0.0/0"

    tags = {
        Name = "${local.project_name}_inbound_http_public_sg"
    }
} 

# ------------------------------------------------------------------------------------------------------------------
# Security Group for Private EC2 Instance 

# Private SG Egress Rule 
# Allows all outbound traffic 

# Private SG Ingress Rule 
# Allows SSH and HTTP from within the VPC  
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
# ------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "private_sg" {
    name        = "${local.project_name}_private_sg"
    description = "Allow SSH and HTTP in from within the VPC and allow all outbound traffic"
    vpc_id      = aws_vpc.acit4640_vpc.id 

    tags = {
        Name = "${local.project_name}_private_sg"
    }
}

resource "aws_vpc_security_group_egress_rule" "outbound_private_sg" {
    description       = "Allow all outbound traffic"
    security_group_id = aws_security_group.private_sg.id 
    ip_protocol       = "-1" # Matches all protocols 
    cidr_ipv4         = "0.0.0.0/0"

    tags = {
        Name = "${local.project_name}_outbound_private_sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_ssh_private_sg" {
    description       = "Allow SSH from within the VPC"
    security_group_id = aws_security_group.private_sg.id 
    ip_protocol       = "tcp"
    from_port         = 22
    to_port           = 22
    referenced_security_group_id = aws_security_group.public_sg.id 
    
    tags = {
        Name = "${local.project_name}_inbound_ssh_private_sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_http_private_sg" {
    description       = "Allow HTTP from within the VPC"
    security_group_id = aws_security_group.private_sg.id 
    ip_protocol       = "tcp"
    from_port         = 80
    to_port           = 80
    referenced_security_group_id = aws_security_group.public_sg.id 

    tags = {
        Name = "${local.project_name}_inbound_http_private_sg"
    }
} 

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Setup SSH Keys 
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# ------------------------------------------------------------------------------------------------------------------
# Generate local SSH key pair 
# Note: terraform_data is NOT an existing resource type 
# input - Stores the path to the Private Key 
# provisioner "local-exec" - Special Terraform resource called a provisioner that performs a local command 
    # 1st Command: Generate a new SSH key when the resource is created 
        # -C - Comment, -f - Filename, -m PEM - Key Format, -t ed25519 - Type of key, -N '' - Emptry Passphrase 
    # 2nd Command: Delete SSH key and its public counterpart when the resource is destroyed 
# ------------------------------------------------------------------------------------------------------------------

resource "terraform_data" "ssh_key_pair" {
    input = "${path.module}/${local.ssh_key_name}.pem"

    provisioner "local-exec" {
        command = "ssh-keygen -C \"${local.ssh_key_name}\" -f \"${path.module}/${local.ssh_key_name}.pem\" -m PEM -t ed25519 -N ''"
        when = create 
    }

    provisioner "local-exec" {
        command = "rm -f \"${self.output}\" \"${self.output}.pub\""
        when = destroy 
    }
}

# ------------------------------------------------------------------------------------------------------------------
# Get local SSH key pair 
# filename - Read the Public key file for the SSH key within the same directory as the Terraform file 
# depends_on - Terraform must create / update the ssh_key_pair resource (above) before reading the ssh_pub_key file 
# ------------------------------------------------------------------------------------------------------------------

data "local_file" "ssh_pub_key" {
    filename = "${path.module}/${local.ssh_key_name}.pem.pub"
    depends_on = [terraform_data.ssh_key_pair]
}

# ------------------------------------------------------------------------------------------------------------------
# Create AWS key from local key file 
# key_name - Name of the key pair on AWS 
# public_key - Public key that AWS will use for this key pair 
# depends_on - Terraform must create / update the ssh_key_pair resource before creating / updating this aws_key_pair resource for AWS  
# ------------------------------------------------------------------------------------------------------------------

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = local.ssh_key_name
  public_key = data.local_file.ssh_pub_key.content
  depends_on = [terraform_data.ssh_key_pair]
}

# ------------------------------------------------------------------------------------------------------------------
# Get the most recent ami for Ubuntu 22.04
# owners - Owner ID for Canonical - Publisher of Ubuntu 
# ------------------------------------------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

# ------------------------------------------------------------------------------------------------------------------
# Create and run the Public and Private EC2 instances 
# instance_type - Hardware of the host computer for the instance 
# ami - Amazon Machine Image; Determines the OS and other software for the instance 
# key_name - Name of the key pair for the instance 
# vpc_security_group_ids - ID of the SG that will be used by the instance 
# subnet_id - ID of the subnet in which the instance will be launched
# user_data - Bash script that runs as the root user, allowing automatic configuration of EC2 instance upon launch 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "public_ec2" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id

  key_name               = local.ssh_key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  user_data              = file("${path.module}/ec2_host_setup.sh")

  tags = {
    Name = "${local.project_name}_public_ubuntu_server"
  }
}

resource "aws_instance" "private_ec2" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id

  key_name               = local.ssh_key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  subnet_id              = aws_subnet.private_subnet.id

  tags = {
    Name = "${local.project_name}_private_ubuntu_server"
  }
}

# ------------------------------------------------------------------------------------------------------------------
# Define module outputs - these output to the command line for main module
# ------------------------------------------------------------------------------------------------------------------

# Output public ip address of the instance
output "instance_public_ip" {
  value = aws_instance.public_ec2.public_ip
}

# Output public dns name of the instance
output "instance_dns" {
  value = aws_instance.public_ec2.public_dns
}

# Output 
output "private_ssh_key_path" {
  value = "${path.module}/${local.ssh_key_name}.pem"
}

output "public_ssh_key_path" {
  value = "${path.module}/${local.ssh_key_name}.pem.pub"
}
