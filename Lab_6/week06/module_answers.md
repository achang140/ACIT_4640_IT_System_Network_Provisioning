# ACIT 4640 - Lab 6 

* Amanda Chang 

## Module Exercise 

**Unzip the zip file in the exercise starter files below and use it to answer the following questions.**

1. **How is data passed into a module?**

    Variable 

2. **How is data passed out of a module?**

    Output 

3. **Modify the `mod_demo` module to create a `security group module` for use in the mod_demo project?**

* Created a new directory named `terraform_sg_simple` that contains `main.tf`, `variables.tf`, and `output.tf`

`main.tf` 
```bash
resource "aws_security_group" "sg_1" {
  name        = "sg_1"
  description = "Allow http,ssh, port 5000 access to ec2 from home and bcit"
  vpc_id      = aws_vpc.vpc_1.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name    = "egress_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "ssh_home_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "ssh_home_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "ssh_bcit_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "ssh_bcit_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "http_home_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "http_home_rule"
    Project = var.project_name
  }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "http_bcit_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "http_bcit_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "nc_home_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 5000
  to_port           = 5000
  cidr_ipv4         = var.home_net
  tags = {
    Name    = "nc_home_rule"
    Project = var.project_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "nc_bcit_rule" {
  security_group_id = aws_security_group.sg_1.id
  ip_protocol       = "tcp"
  from_port         = 5000 
  to_port           = 5000 
  cidr_ipv4         = var.bcit_net
  tags = {
    Name    = "nc_bcit_rule"
    Project = var.project_name
  }
}
```

`variables.tf`

```bash
variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "home_net" {
  description = "CIDR block for home network"
  type        = string
}

variable "bcit_net" {
  description = "CIDR block for BCIT network"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}
```

`outputs.tf`

```bash
output "security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.sg_1.id
}
```