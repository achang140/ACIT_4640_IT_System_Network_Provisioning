variable "project_name" {
    description = "Project name"
    type = string 
}

variable "vpc_id" {
    description = "ID of the VPC"
}

variable "ingress_rules" {
    type = list(object(
        {
            rule_name    = string
            description  = string
            ip_protocol  = string
            from_port    = number
            to_port      = number
            cidr_ipv4    = string
        }
    ))

    # Validation block ensures that ingress rules with an ip_protocol = -1 do not have specified values for from_port and to_port 
    validation {
        condition = alltrue([
        # Loop over all rules
        for rule in var.ingress_rules :
            # Check if the from_port and to_port are null if the ip_protocol is -1
            alltrue([rule.from_port == null, rule.to_port == null])
            if rule.ip_protocol == "-1"
        ])
        error_message = "Ingress rules with ip_protocol = -1 must not have a from_port or to_port"
    }
}

variable "egress_rules" {
  type = list(object(
    {
      rule_name   = string
      description = string
      ip_protocol = string
      from_port   = number
      to_port     = number
      cidr_ipv4   = string
    }
  ))

    validation {
        condition = alltrue([
        #loop over all rules
        for rule in var.egress_rules : 
            #check if the from_port and to_port are null if the ip_protocol is -1
            alltrue([rule.from_port == null, rule.to_port == null]) 
            if rule.ip_protocol == "-1"
        ])
        error_message = "Egress rules with ip_protocol = -1 must not have a from_port or to_port"
    }
}

