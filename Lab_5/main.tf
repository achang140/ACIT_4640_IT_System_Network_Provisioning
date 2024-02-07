# -----------------------------------------------------------------------------
# configure aws vpc with a single subnet, internet gateway, route table, and
# security group. create 5 ec2 instances in the subnet with a public ip address'
# and dns names
#
# Terraform configuration tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language
# Terraform language reference: https://developer.hashicorp.com/terraform/language
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Configure terraform settings
# https://developer.hashicorp.com/terraform/language/settings
# -----------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Define variables for use in main terraform module (aka this file)
# reference: https://developer.hashicorp.com/terraform/language/values/variables
# tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables
# -----------------------------------------------------------------------------
# define the aws region to deploy resources
variable "aws_region" {
  description = "the aws region to deploy resources"
  default     = "us-west-2"
  type        = string
}

# Attributes for the ec2 instances to create 
# Currently, the only attribute is the server_type, but this could be expanded
# for more modular configuration of the instances
variable "ec2_instances" {
  # Map Reference: https://developer.hashicorp.com/terraform/language/values/variables#map-variables
  # Map Tutorial: https://spacelift.io/blog/terraform-map-variable
  type = map(object({
    server_type = string
  }))
  description = "ec2 instances configuration data, with instance name as key and server_type as only attribute"
  default = {
    "web01" : { server_type = "web" },
    "web02" : { server_type = "web" },
    "db01" : { server_type = "db" },
    "be01" : { server_type = "backend" },
    "be02" : { server_type = "backend" }
  }
}

# -----------------------------------------------------------------------------
# Define local variables 
# reference: https://developer.hashicorp.com/terraform/language/values/locals
# tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language/locals
# -----------------------------------------------------------------------------
locals {
  base_cidr_block   = "10.0.0.0/16"
  subnet_cidr_block = "10.0.1.0/24"
  project_name      = "acit4640_wk05"
  availability_zone = "us-west-2a"
  ssh_key_name      = "acit4640_wk05"
}

# -----------------------------------------------------------------------------
# Configure the AWS provider 
# language reference: https://developer.hashicorp.com/terraform/language/providers
# aws reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags-configuration-block
  default_tags {
    tags = {
      project = "${local.project_name}"
    }
  }
}

# -----------------------------------------------------------------------------
# Setup the network infrastructure: vpc, subnet, internet gateway, route table
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  # reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
  cidr_block           = local.base_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    name = "${local.project_name}_vpc"
  }
}

resource "aws_subnet" "main" {
  # reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidr_block
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true
  tags = {
    name = "${local.project_name}_main_subnet"
  }
}

resource "aws_internet_gateway" "main" {
  # reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway 
  vpc_id = aws_vpc.main.id
  tags = {
    name = "${local.project_name}_main_igw"
  }
}

resource "aws_route_table" "main" {
  # reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
  vpc_id = aws_vpc.main.id
  tags = {
    name = "${local.project_name}_main_rt"
  }
}

resource "aws_route" "default_route" {
  # reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route 
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "main" {
  # reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# -----------------------------------------------------------------------------
# setup the security group and rules
# -----------------------------------------------------------------------------
resource "aws_security_group" "main" {
  # reference: https://registry.terraform.io/providers/-/aws/latest/docs/resources/security_group
  name        = "${local.project_name}_main_sg"
  description = "allow all outbound traffic and ssh and http in from everywhere"
  vpc_id      = aws_vpc.main.id
  tags = {
    name = "${local.project_name}_main_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "main" {
  # reference: https://registry.terraform.io/providers/-/aws/latest/docs/resources/vpc_security_group_egress_rule
  # make this open to everything to everywhere
  description       = "allow all outbound traffic"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "-1" # this matches all protocols
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    name = "${local.project_name}_main_egress_rule"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  # reference: https://registry.terraform.io/providers/-/aws/latest/docs/resources/vpc_security_group_ingress_rule 
  # ssh in from everywhere
  description       = "allow ssh from everywhere"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    name = "${local.project_name}_ssh_ingress_rule"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  # http in from everywhere
  description       = "allow http from everywhere"
  security_group_id = aws_security_group.main.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    name = "${local.project_name}_http_ingress_rule"
  }
}

# -----------------------------------------------------------------------------
# Setup ssh keys 
# -----------------------------------------------------------------------------
# generate local ssh key pair 
resource "terraform_data" "ssh_key_pair" {
  # https://developer.hashicorp.com/terraform/language/resources/terraform-data

  # this stores the path to the private key 
  input = "${path.module}/${local.ssh_key_name}.pem"

  provisioner "local-exec" {
    # https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    command = "ssh-keygen -C \"${local.ssh_key_name}\" -f \"${path.module}/${local.ssh_key_name}.pem\" -m pem -t ed25519 -N \"\""

    # https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#creation-time-provisioners
    # Only create the key pair when the resource is created by executing the local command
    when = create
  }

  provisioner "local-exec" {
    # glob expressions don't work - need to delete each file individually
    # self.outuput is the valude of the input in the resoursce block
    command = "rm -f \"${self.output}\" \"${self.output}.pub\""

    # https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#destroy-time-provisioners
    # Make sure to delete the key pair when the resource is destroyed by 
    # executing the local command
    when = destroy

  }
}

# -----------------------------------------------------------------------------
# Get local ssh key pair file
# -----------------------------------------------------------------------------
# get the public key from a local file which is assumed to be in the same
# directory as the terraform file
data "local_file" "ssh_pub_key" {
  # https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file
  # https://developer.hashicorp.com/terraform/language/expressions/references#filesystem-and-workspace-info
  filename = "${path.module}/${local.ssh_key_name}.pem.pub"

  # depends_on is used to ensure that the local key is reading the local file 
  # only when it exists
  depends_on = [terraform_data.ssh_key_pair]
}

# -----------------------------------------------------------------------------
# Create aws key from local key file
# -----------------------------------------------------------------------------
# the resource below assumes that we have created a local key pair but
# haven't imported it to aws yet. from the docs: 
# "currently this resource requires an existing user-supplied key pair. 
# this key pair's public key will be registered with aws to allow logging-in to
# ec2 instances." 
resource "aws_key_pair" "ssh_key_pair" {
  # https://registry.terraform.io/providers/-/aws/latest/docs/resources/key_pair
  key_name   = local.ssh_key_name
  public_key = data.local_file.ssh_pub_key.content

  # depends_on is used to ensure that the local public key has been created 
  # before the key is "imported" to AWS
  # https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on
  depends_on = [terraform_data.ssh_key_pair]
}

# -----------------------------------------------------------------------------
# get the most recent ami for ubuntu 22.04
# -----------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
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

# -----------------------------------------------------------------------------
# Create and run the ec2 instances
# -----------------------------------------------------------------------------
# Create and run an ec2 instance for each instance in the ec2_instances variable
resource "aws_instance" "ec2_set" {
  # EC2 Instance Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
  # For Each tutorial: https://spacelift.io/blog/terraform-for-each
  # For Each tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language/for-each
  # For Each Reference: https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
  for_each = var.ec2_instances
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id

  key_name               = local.ssh_key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = aws_subnet.main.id

  tags = {
    name        = "${local.project_name}_${each.key}"
    server_type = "${each.value.server_type}"
  }

}



# -----------------------------------------------------------------------------
# Define module outputs - these output to the command line for main module
#
# https://developer.hashicorp.com/terraform/language/values/outputs
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/outputs  
# -----------------------------------------------------------------------------

# output public ip address for each instance
output "ec2_ips" {
  value = {
    # Reference: https://developer.hashicorp.com/terraform/language/meta-arguments/for
    # Tutorial: https://spacelift.io/blog/terraform-for-loop
    # For each instance
    for instance in aws_instance.ec2_set :
    # create a map with instance name as key and public ip as value
    instance.tags["name"] => instance.public_ip
  }
}

# output public dns name for each instance
output "ec2_dns" {
  value = {
    # for each instance
    for instance in aws_instance.ec2_set :
    # create a map with instance name as key and public dns as value
    instance.tags["name"] => instance.public_dns
  }
}

# -----------------------------------------------------------------------------
# Generate inventory for use Ansible
# Ansible Inventory: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
# -----------------------------------------------------------------------------
# Local varialbles to used to build Ansible inventory file
locals {
  # String Templates: https://developer.hashicorp.com/terraform/language/expressions/strings#string-templates
  # Substring: https://developer.hashicorp.com/terraform/language/functions/substr
  # The projecet name is trimmed from the instance name to get the server alias for the inventory file
  # this is to make adhoc ansible commands easier to run
  prefix_length = length(local.project_name) + 1

  # Create a string for each server type that stores the server alias 
  # and public dns for each server this will be when writing the inventory file
  web_servers = <<-EOT
  %{for instance in aws_instance.ec2_set~}
    %{if instance.tags["server_type"] == "web"}
      ${substr(instance.tags["name"], local.prefix_length, -1)}:
        ansible_host: ${instance.public_dns}
    %{endif}
  %{endfor~}
  EOT

  db_servers = <<-EOT
  %{for instance in aws_instance.ec2_set~}
    %{if instance.tags["server_type"] == "db"}
      ${substr(instance.tags["name"], local.prefix_length, -1)}:
        ansible_host: ${instance.public_dns}
    %{endif}
  %{endfor~}
  EOT

  backend_servers = <<-EOT
  %{for instance in aws_instance.ec2_set~}
    %{if instance.tags["server_type"] == "backend"}
      ${substr(instance.tags["name"], local.prefix_length, -1)}:
        ansible_host: ${instance.public_dns}
    %{endif}
  %{endfor~}
  EOT
}

# Create Ansible Inventory file
# Specify the ssh key and user and the servers for each server type
resource "local_file" "inventory" {
  # File Reference: https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
  content = <<-EOF
  all:
    vars:
      ansible_ssh_private_key_file: "${path.module}/${local.ssh_key_name}.pem"
      ansible_user: ubuntu
  web:
    hosts:
      ${local.web_servers}
  db:
    hosts:
      ${local.db_servers}
  backend:
    hosts:
      ${local.backend_servers}
  EOF

  filename = "${path.module}/hosts.yml"

}

# -----------------------------------------------------------------------------
# Generate Ansible configuration file
# Reference: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
# Configure Ansible to use the inventory file created above and set ssh options
# -----------------------------------------------------------------------------
resource "local_file" "ansible_config" {
  # https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
  content = <<-EOT
  [defaults]
  inventory = hosts.yml
  stdout_callback = debug

  [ssh_connection]
  host_key_checking = False
  ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

  EOT

  filename = "${path.module}/ansible.cfg"

}