provider "aws" {
  region = var.aws_region
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "vpc_1" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name    = "vpc_1"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "sn_1" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.subnet_cidr
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "sn_1"
    Project = var.project_name
  }

  lifecycle {
    precondition {
      # Check if subnet_cidr is within vpc_cidr
      #   - verify that subnet cidr is within vpc cidr
      #   - get address of vpc_dir
      #   - split at bytes
      #   - convert to binary and reassamble
      #   - truncate at end of network bits 
      #   - check if the network bits of the vpc cidr are the same as the subnet cidr
      #     for the number of bits in the vpc_cidr network address
      condition = (
        substr(
          join( # Join each binary string byte together to make binary string address
            "",
            formatlist("%8.8b", split(".",cidrhost(var.vpc_cidr,0))) #Convert each byte to binary string
          ),
          0, # Slice starting at start of Binary Address
          tonumber(split("/",var.vpc_cidr)[1]) # Slice until length of network bits
        ) 
      == 
        substr(
          join( # Join each binary string byte together to make binary string address
            "",formatlist("%8.8b", #Convert each byte of IP address to binary string
            split(".",cidrhost(var.subnet_cidr,0)))), #Split IP address into bytes
            0, # start at high order bit of binary IP address
            tonumber(split("/",var.vpc_cidr)[1]) # continue until end of network bits
        )
      )
      error_message = "Subnet CIDR must be within VPC CIDR."
    }
  }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "gw_1" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name    = "gw_1"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "rt_1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = var.default_route
    gateway_id = aws_internet_gateway.gw_1.id
  }

  tags = {
    Name    = "rt_1"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "web_rt_assoc_1" {
  subnet_id      = aws_subnet.sn_1.id
  route_table_id = aws_route_table.rt_1.id
}
