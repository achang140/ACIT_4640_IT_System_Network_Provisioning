## ----------------------------------------------------------------------------
## CREATE A VPC 
## Also creates array of IPv4 octets for use in creating subnets
## ----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name    = var.project_name
    Project = var.project_name
  }
}



## ----------------------------------------------------------------------------
## GET A LIST OF AVAILABILITY ZONES WITH EC2 INSTANCE TYPES AVAILABLE IN EACH
## This is restricted to those instance types specified in the variable instance_types  
## Note: each availability zone most support at least one of the instance types 
## or the resource will fail to create
## adopted from:
## https://stackoverflow.com/questions/63969173/terraform-how-to-request-aws-ec2-instances-only-in-zones-where-the-requested-in
## ----------------------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "main" {
  state = "available"
}

data "aws_ec2_instance_type_offering" "main" {
  for_each = toset(data.aws_availability_zones.main.names)

  # Only get instance types that are in the list of instance types
  filter {
    name   = "instance-type"
    values = var.instance_types
  }

  filter {
    name   = "location"
    values = [each.value]
  }

  location_type = "availability-zone"

  preferred_instance_types = var.instance_types
}

locals {
  # create list of availability zones that support the preferred instance type
  # I.E. the first one in var.instance_types
  # adopted from https://stackoverflow.com/questions/63969173/terraform-how-to-request-aws-ec2-instances-only-in-zones-where-the-requested-in
  availability_zones = keys({ for az, details in data.aws_ec2_instance_type_offering.main: az => details if details.instance_type == var.instance_types[0] })
}


## ----------------------------------------------------------------------------
## CREATE VPC Networking
## ----------------------------------------------------------------------------

# create local variable made of octets of VPC IPv4 Address
locals {
  vpc_ipv4_octets = split(".", cidrhost(aws_vpc.main.cidr_block, 0))

}

# Create a subnet for each availability zone 
# only creates subnets in availability zones that supports the most preferred
# ec2 instance type
resource "aws_subnet" "main" {

  count = length(local.availability_zones)
  vpc_id  = aws_vpc.main.id

  # the cidr_block is created by taking the first two octets of the VPC IPv4 address
  # and using the third octet from the count of the subnet
  cidr_block        = "${local.vpc_ipv4_octets[0]}.${local.vpc_ipv4_octets[1]}.${count.index}.0/24"
  availability_zone = "${local.availability_zones[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}_${local.availability_zones[count.index]}"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name    = var.project_name
    Project = var.project_name
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.default_route
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = var.project_name
    Project = var.project_name
  }
}

# Associate the route table with all of the subnets
resource "aws_route_table_association" "main" {
  count = length(aws_subnet.main)

  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}

## ----------------------------------------------------------------------------
## CONFIGURE VPC SECURITY 
## ----------------------------------------------------------------------------

resource "aws_security_group" "main" {
  name        = var.security_group.name
  description = var.security_group.description
  vpc_id      = aws_vpc.main.id
  tags = {
    Name    = "${var.project_name}_${var.security_group.name}"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  for_each = {
    for index, rule in var.security_group.ingress_rules : 
      rule.rule_name => rule
  }

  description       = each.value.description
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  security_group_id = aws_security_group.main.id
  tags = {
    Name    = each.value.rule_name
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "main" {
  for_each = {
    for index, rule in var.security_group.egress_rules : 
      rule.rule_name => rule
  }
 
  description       = each.value.description
  security_group_id = aws_security_group.main.id
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  to_port           = each.value.to_port

  tags = {
    Name    = "${var.project_name}_${each.value.rule_name}"
    Project = var.project_name
  }
}

## ----------------------------------------------------------------------------
## SETUP SSH KEY PAIR: LOCAL FILE AND AWS KEY PAIR
## ----------------------------------------------------------------------------

module "ssh_key" {
  source = "./modules/aws_ssh_key_pair"
  key_name = var.project_name
}

## ----------------------------------------------------------------------------
## CONFIGURE EC2 INSTANCES
## Create one ec2 instance of each server_type on each subnet
## ----------------------------------------------------------------------------

# Get the most recent Ubuntu 23.04 image ID
data "aws_ami" "ubuntu" {
  most_recent = true

  # this is the owner id for Canonical - the publisher of Ubuntu
  owners = ["099720109477"]

  filter {
    name = "name"
    # this is a glob expression - the * is a wildcard - that matches  the most
    # recent ubuntu 23.04 image x86 64-bit server image
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

# Create one ec2 isntance of each server_type per subnet
resource "aws_instance" "main" {
  # number of ec2 intances = number of subnets * number of server roles
  count           = length(aws_subnet.main) * length(var.server_roles)
  ami             = data.aws_ami.ubuntu.id

  # use the most preferred instance type, i.e. the first one
  instance_type   = var.instance_types[0]
  key_name        = module.ssh_key.key_name

  # Subnet taken from array of subnets using element function
  # calculates the remainder of the count.index divided by the length of the array 
  subnet_id       = element(aws_subnet.main, count.index).id
  security_groups = [aws_security_group.main.id]
  tags = {
    # Name of ec2 instance is a combination of the server role and availabiity zone 
    # see server role calculation below
    # Use '-' as separator so this name can also be used as linux hostname in ansible
    Name    = "${var.server_roles[floor(count.index/length(local.availability_zones))]}-${element(local.availability_zones,count.index)}"
    Project = var.project_name

    # server role is taken from array of server roles by taking the 
    # whole number result of dividing the count.index by the number of subnets
    # leaving a number that will cycle the index of the server roles
    Server_Role = "${var.server_roles[floor(count.index/length(local.availability_zones))]}"
  }
}

## ----------------------------------------------------------------------------
## CONFIGURE ANSIBLE
## Create Ansible variable file to specify the ssh key and user for connecting
## to the ec2 instances 
## ----------------------------------------------------------------------------

resource "local_file" "all_vars" {
  content = <<-EOF
  ansible_ssh_private_key_file: "${abspath(module.ssh_key.priv_key_file)}"
  ansible_user: ubuntu
  EOF
  filename = abspath("${path.root}/../ansible/group_vars/all.yml")
}
