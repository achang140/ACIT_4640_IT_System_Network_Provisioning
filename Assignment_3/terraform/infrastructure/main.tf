##-#-#-#-#-#-#-#-#-#-#-#-#-##
#  ACIT 4640 Assignment 3  # 
# Amanda Chang - A01294905 #
##-#-#-#-#-#-#-#-#-#-#-#-#-##

# ------------------------------------------------------------------------------------------------------------------
# Configure an AWS VPC with 2 public subnets, along with an internet gateway, route table, and security group. 
# Each subnet hosts an EC2 instance.
# ------------------------------------------------------------------------------------------------------------------

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Setup Network Infrastructure: VPC, Public Subnets, Internet Gateway, Route Tables 
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

resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.acit4640_vpc.id
    cidr_block              = "10.0.0.0/20" 
    availability_zone       = var.availability_zone
    map_public_ip_on_launch = true 

    tags = {
        Name = "${var.project_name}_public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.acit4640_vpc.id
    cidr_block              = "10.0.128.0/20" 
    availability_zone       = var.availability_zone

    tags = {
        Name = "${var.project_name}_private_subnet"
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
        Name = "${var.project_name}_private_rt"
    }
}

resource "aws_route_table_association" "private_subnet_rt" {
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

# ------------------------------------------------------------------------------------------------------------------
# Module Configuration: Creates Security Groups using custom Terraform module
# ------------------------------------------------------------------------------------------------------------------

module "sg" {
    source = "./modules/terraform_sg"
    project_name = var.project_name
    vpc_id = aws_vpc.acit4640_vpc.id

    ingress_rules = [
        {
            rule_name = "publicly_accessible_via_ssh"
            description = "Allow SSH from everywhere"
            ip_protocol       = "tcp"
            from_port         = 22
            to_port           = 22
            cidr_ipv4         = var.cidr_ipv4

        },
        {
            rule_name = "publicly_accessible_via_http"
            description       = "Allow HTTP from everywhere"
            ip_protocol       = "tcp"
            from_port         = 80
            to_port           = 80
            cidr_ipv4         = var.cidr_ipv4
        },
        {
            rule_name = "not_publicly_accessible_via_http"
            description       = "Allow HTTP from within the VPC"
            ip_protocol       = "tcp"
            from_port         = 80
            to_port           = 80
            cidr_ipv4         = aws_subnet.public_subnet.cidr_block
        }
    ]
    egress_rules = [ 
        {
        rule_name = "allow_all_outbound"
        description = "Allow all outbound traffic"
        ip_protocol = "-1"
        from_port = null 
        to_port = null 
        cidr_ipv4 = var.cidr_ipv4
        }
    ]
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
# Get the most recent ami for Ubuntu 23.04
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
# Module Configuration: Launches EC2 instances using custom Terraform module
# ------------------------------------------------------------------------------------------------------------------

module "ec2" {
    source = "./modules/terraform_ec2"
    instance_type = var.instance_type
    ami_id = data.aws_ami.ubuntu.id
    instance_count = var.instance_count
    aws_region = var.aws_region
    availability_zone = var.availability_zone
    subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
    # public_subnet_id = aws_subnet.public_subnet.id
    # private_subnet_id = aws_subnet.private_subnet.id
    security_groups = [module.sg.public_sg_id, module.sg.private_sg_id]
    ssh_key_name = var.ssh_key_name
}

# ------------------------------------------------------------------------------------------------------------------
# Generate inventory for use Ansible
# Ansible Inventory: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
# ------------------------------------------------------------------------------------------------------------------

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
# Specify the ssh key, user, and the servers for each server type

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
            new_user_group: sudo
    EOF

    filename = "${path.module}/hosts.yml"
}

# ------------------------------------------------------------------------------------------------------------------
# Generate Ansible configuration file
# Reference: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
# Configure Ansible to use the inventory file created above and set ssh options

# allow_world_readable_tmpfiles = True - Allows temporary files created during playbook execution to be world-readable.
# pipelining = True - Enables pipelining of tasks on remote hosts
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
