##-#-#-#-#-#-#-#-#-#-#-#-#-##
#  ACIT 4640 Assignment 1  # 
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

terraform {
    required_providers {
        aws {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

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
    availability_zone = "us-west-2a" 
    ssh_key_name      = "acit4640_assignment"
}

# ------------------------------------------------------------------------------------------------------------------
# Configure the AWS Provider 

# region - Region where the AWS provider should operate (Oregon / us-west-2)
# default_tags block - Default tag that will apply to all resources created by the AWS provider
# ------------------------------------------------------------------------------------------------------------------

provider "aws" {
    region = "us-west-2"
    
    default_tags {
        tags = {
            Project = "${local.project_name}"
        }
    }
}

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
    route_table_id = aws_route_table.public_rt
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
    route_table_id = aws_route_table.private_rt
}

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Setup Security Groups and Rules 
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# ------------------------------------------------------------------------------------------------------------------
# Security Group for Public EC2 Instance  
# name - Name of the Public Security Group 
# description - Description of the Public Security Group 
# vpc_id = ID of the VPC in which the Public Security Group will be created 

# Security Group Rules 
# 

# Public SG Egress Rule 
#

# Public SG Ingress Rule 
# 
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

# name - Name of the Private Security Group 
# description - Description of the Private Security Group 
# vpc_id = ID of the VPC in which the Private Security Group will be created 

# Private SG Egress Rule 
#


# Private SG Ingress Rule 
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
#  
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

# ------------------------------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------------------------------





