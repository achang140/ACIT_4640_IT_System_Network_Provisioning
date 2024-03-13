##-#-#-#-#-#-#-#-#-#-#-#-#-##
#  ACIT 4640 Assignment 2  # 
# Amanda Chang - A01294905 #
##-#-#-#-#-#-#-#-#-#-#-#-#-##

# ------------------------------------------------------------------------------------------------------------------
# Configure an AWS VPC with a public and a private subnet, along with an internet gateway, route tables, and security groups. 
# Each subnet hosts an EC2 instance.
# ------------------------------------------------------------------------------------------------------------------

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
    cidr_block           = var.base_cidr_block
    instance_tenancy     = "default"
    enable_dns_hostnames = true 

    tags = {
        Name = "${var.project_name}_vpc"
    }
}

# ------------------------------------------------------------------------------------------------------------------
# Public and Private Subnets 

# vpc_id - ID of the VPC in which the Subnets will be created 
# cidr_block - IP Address range for the Subnet 
# availability_zone - Availability Zone in which the Subnets will be created  
# map_public_ip_on_launch = true - Instance launch in the Public Subnet will have a public IP address 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public_subnet_1" {
    vpc_id                  = aws_vpc.acit4640_vpc.id
    cidr_block              = "10.0.0.0/20" 
    availability_zone       = element(var.availability_zones, 0) # var.availability_zone_1 
    map_public_ip_on_launch = true 

    tags = {
        Name = "${var.project_name}_public_subnet_1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id                  = aws_vpc.acit4640_vpc.id
    cidr_block              = "10.0.16.0/20" 
    availability_zone       = element(var.availability_zones, 1) # var.availability_zone_2 
    map_public_ip_on_launch = true 

    tags = {
        Name = "${var.project_name}_public_subnet_2"
    }
}

# ------------------------------------------------------------------------------------------------------------------
# Internet Gateway - Allows Public Instance within the VPC to communicate with the Internet 

# vpc_id - ID of the VPC in which the Internet Gateway will be created 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "acit4640_igw" {
    vpc_id = aws_vpc.acit4640_vpc.id

    tags = {
        Name = "${var.project_name}_igw"
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
        Name = "${var.project_name}_public_rt"
    }
}

resource "aws_route" "default_route" {
    route_table_id         = aws_route_table.public_rt.id 
    destination_cidr_block = "0.0.0.0/0" 
    gateway_id             = aws_internet_gateway.acit4640_igw.id 
}

resource "aws_route_table_association" "public_subnet_rt_1" {
    subnet_id      = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_rt_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
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
# Security Group for Public EC2 Instances 

# Public SG Egress Rule 
# Allows all outbound traffic 

# Public SG Ingress Rule 
# Allows SSH and HTTP from everywhere 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "public_sg" {
    name        = "${var.project_name}_public_sg"
    description = "Allow SSH and HTTP in from everywhere and allow all outbound traffic"
    vpc_id      = aws_vpc.acit4640_vpc.id 

    tags = {
        Name = "${var.project_name}_public_sg"
    }
}

resource "aws_vpc_security_group_egress_rule" "outbound_public_sg" {
    description       = "Allow all outbound traffic"
    security_group_id = aws_security_group.public_sg.id 
    ip_protocol       = "-1" # Matches all protocols 
    cidr_ipv4         = "0.0.0.0/0"

    tags = {
        Name = "${var.project_name}_outbound_public_sg"
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
        Name = "${var.project_name}_inbound_ssh_public_sg"
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
        Name = "${var.project_name}_inbound_http_public_sg"
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
    input = "${path.module}/${var.ssh_key_name}.pem"

    provisioner "local-exec" {
        command = "ssh-keygen -C \"${var.ssh_key_name}\" -f \"${path.module}/${var.ssh_key_name}.pem\" -m PEM -t ed25519 -N ''"
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
    filename = "${path.module}/${var.ssh_key_name}.pem.pub"
    depends_on = [terraform_data.ssh_key_pair]
}

# ------------------------------------------------------------------------------------------------------------------
# Create AWS key from local key file 
# key_name - Name of the key pair on AWS 
# public_key - Public key that AWS will use for this key pair 
# depends_on - Terraform must create / update the ssh_key_pair resource before creating / updating this aws_key_pair resource for AWS  
# ------------------------------------------------------------------------------------------------------------------

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = var.ssh_key_name
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
# Create and run the Public EC2 instances 
# instance_type - Hardware of the host computer for the instance 
# ami - Amazon Machine Image; Determines the OS and other software for the instance 
# key_name - Name of the key pair for the instance 
# vpc_security_group_ids - ID of the SG that will be used by the instance 
# subnet_id - ID of the subnet in which the instance will be launched
# user_data - Bash script that runs as the root user, allowing automatic configuration of EC2 instance upon launch 
# ------------------------------------------------------------------------------------------------------------------

module "ec2" {
  source = "./modules/terraform_ec2"
  project_name = var.project_name
  instance_type = var.instance_type
  ami_id = data.aws_ami.ubuntu.id
  instance_count = var.instance_count
  aws_region = var.aws_region
  availability_zones = var.availability_zones
  public_subnet_id_1 = aws_subnet.public_subnet_1.id
  public_subnet_id_2 = aws_subnet.public_subnet_2.id
  security_group_id = [aws_security_group.public_sg.id]
  ssh_key_name = var.ssh_key_name
}

# ------------------------------------------------------------------------------------------------------------------
# Generate inventory for use Ansible
# Ansible Inventory: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
# ------------------------------------------------------------------------------------------------------------------

# locals {
#   web_servers = <<-EOT
#   %{for instance in module.ec2.ec2_instances~}
#     %{if instance.tags["server_type"] == "web"}
#       ${instance.tags["Name"]}:
#         ansible_host: ${instance.public_dns}
#     %{endif}
#   %{endfor~}
#   EOT
# }

locals {
  web_servers = <<-EOT
  %{for idx, instance in module.ec2.ec2_instances~}
    %{if instance.tags["server_type"] == "web"}
      ${instance.tags["Name"]}-${idx}:
        ansible_host: ${instance.public_dns}
    %{endif}
  %{endfor~}
  EOT
}


# Create Ansible Inventory file
# Specify the ssh key and user and the servers for each server type

resource "local_file" "ansible_inventory" {
  content = <<-EOF
  all:
    vars:
      ansible_ssh_private_key_file: "${path.module}/${var.ssh_key_name}.pem"
      ansible_user: ubuntu
  web:
    hosts:
        ${local.web_servers}
    vars:
        new_user: bun
        new_user_groups: sudo
  EOF

  filename = "${path.module}/hosts.yml"
}


# resource "local_file" "ansible_inventory" {
#   content = <<-EOF
#   all:
#     vars:
#       ansible_ssh_private_key_file: "${path.module}/${var.ssh_key_name}.pem"
#       ansible_user: ubuntu 
#   [web]
#   ${join("\n", module.ec2.ec2_instances[*].public_ip)} ansible_ssh_user=ubuntu 
#   EOF

#   filename = "${path.module}/hosts.yml"
# }

# ------------------------------------------------------------------------------------------------------------------
# Generate Ansible configuration file
# Reference: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
# Configure Ansible to use the inventory file created above and set ssh options
# ------------------------------------------------------------------------------------------------------------------

resource "local_file" "ansible_config" {
  # https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
  content = <<-EOT
  [defaults]
  inventory = hosts.yml
  stdout_callback = debug
  allow_world_readable_tmpfiles = True
  pipelining = True

  [ssh_connection]
  host_key_checking = False
  ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
  EOT

  filename = "${path.module}/ansible.cfg"
}
