run "all_egress_protocols" {
  variables {
    name = "test_sg"
    description = "test all protocols egress and ingress"
    project_name = "test_proj"
    vpc_id = "vpc-123456"
 
    ingress_rules = [ 
    {
      description = "allow all egress traffic"
      ip_protocol = "-1"
      from_port = -1
      to_port = -1
      cidr_ipv4 = "0.0.0.0/0"
      rule_name = "allow_all_ingress"
    }
    ]

    egress_rules = [ 
    {
      description = "allow all egress traffic"
      ip_protocol = "-1"
      from_port = 80
      to_port = 80
      cidr_ipv4 = "0.0.0.0/0"
      rule_name = "allow_all_egress"
    }
   ]

  }

  command = plan

  expect_failures = [var.egress_rules, var.ingress_rules]
}
