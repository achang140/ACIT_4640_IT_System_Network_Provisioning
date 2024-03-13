# These are the equivalent of unit tests for the module 
# The tests don't are validating the input so they use command = plan

run "invalid_vpc_cidr_not_private_low" {
  variables {
    project_name = "test_vpc_cidr"  
    vpc_cidr = "172.15.0.0/16"
    subnet_cidr = "172.15.1.0/24"
  }
  command = plan

  expect_failures = [ var.vpc_cidr ] 
}

run "invalid_vpc_cidr_not_private_high" {
  variables {
    project_name = "test_vpc_cidr"  
    vpc_cidr = "172.33.0.0/16"
    subnet_cidr = "172.33.1.0/24"
  }
  command = plan

  expect_failures = [ var.vpc_cidr ] 
}

run "invalid_vpc_cidr_reserved" {
  variables {
    project_name = "test_vpc_cidr"  
    vpc_cidr = "172.17.0.0/16"
    subnet_cidr = "172.17.1.0/24"
  }
  command = plan

  expect_failures = [ var.vpc_cidr ] 
}

run "invalid_vpc_cider_not_private_low" {
  variables {
    project_name = "test_vpc_cidr"  
    vpc_cidr = "172.15.0.0/16"
    subnet_cidr = "172.15.1.0/24"
  }
  command = plan

  expect_failures = [ var.vpc_cidr ] 
}

run "invalid_subnet_cider_not_in_vpc" {
  variables {
    project_name = "test_vpc_cidr"  
    vpc_cidr = "172.16.0.0/18"
    subnet_cidr = "172.16.128.0/24"
  }
  command = plan

  expect_failures = [ aws_subnet.sn_1 ]

}

run "valid_vpc_subnet_cidr" {
  variables {
    project_name = "test_vpc_cidr"  
    vpc_cidr = "192.168.128.0/17"
    subnet_cidr = "192.168.192.0/18"
  }

  command = plan
}