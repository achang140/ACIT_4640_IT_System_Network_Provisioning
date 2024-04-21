# ------------------------------------------------------------------------------------------------------------------
# Security Group for Public EC2 Instances 

# Public SG Ingress Rule 
# Allows SSH and HTTP from everywhere 

# Public SG Egress Rule 
# Allows all outbound traffic 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "public_sg" {
    name        = "${var.project_name}_public_sg"
    description = "Allow SSH and HTTP in from everywhere and allow all outbound traffic"
    vpc_id      = var.vpc_id

    tags = {
        Name = "${var.project_name}_public_sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "public_ingress_rules" {
    for_each = {
        for idx, rule in var.ingress_rules: 
        rule.rule_name => rule
        if idx == 0 || idx == 1
        # if rule.rule_name == "publicly_accessible_via_ssh" || rule.rule_name == "publicly_accessible_via_http"
    }

    security_group_id = aws_security_group.public_sg.id 
    description       = each.value.description
    ip_protocol       = each.value.ip_protocol
    from_port         = each.value.from_port
    to_port           = each.value.to_port
    cidr_ipv4         = each.value.cidr_ipv4
  
    tags = {
        Name    = each.value.rule_name
        Project = var.project_name
    }
}

resource "aws_vpc_security_group_egress_rule" "public_egress_rule" {
    for_each = {
        for idx, rule in var.egress_rules:
        rule.rule_name => rule
    }

    security_group_id = aws_security_group.public_sg.id
    description       = each.value.description
    ip_protocol       = each.value.ip_protocol
    from_port         = each.value.from_port
    to_port           = each.value.to_port
    cidr_ipv4         = each.value.cidr_ipv4

    tags = {
        Name    = each.value.rule_name
        Project = var.project_name
    }
}

# ------------------------------------------------------------------------------------------------------------------
# Security Group for Private EC2 Instances 

# Public SG Ingress Rule 
# Allows SSH from everywhere but HTTP from within VPC 

# Public SG Egress Rule 
# Allows all outbound traffic 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "private_sg" {
    name        = "${var.project_name}_private_sg"
    description = "Allow SSH from everywhere and HTTP in from within the VPC and allow all outbound traffic"
    vpc_id      = var.vpc_id

    tags = {
        Name = "${var.project_name}_private_sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "private_ingress_rules" {
    for_each = {
        for idx, rule in var.ingress_rules : 
        idx => rule
        if idx == 0 || idx == 2
    }

    security_group_id = aws_security_group.private_sg.id 
    description       = each.value.description
    ip_protocol       = each.value.ip_protocol
    from_port         = each.value.from_port
    to_port           = each.value.to_port
    cidr_ipv4         = each.value.cidr_ipv4

    tags = {
        Name    = each.value.rule_name
        Project = var.project_name
    }
}

resource "aws_vpc_security_group_egress_rule" "private_egress_rule" {
    for_each = {
        for index, rule in var.egress_rules:
        rule.rule_name => rule
    }

    security_group_id = aws_security_group.private_sg.id
    description       = each.value.description
    ip_protocol       = each.value.ip_protocol
    from_port         = each.value.from_port
    to_port           = each.value.to_port
    cidr_ipv4         = each.value.cidr_ipv4

    tags = {
        Name    = each.value.rule_name
        Project = var.project_name
    }
}
