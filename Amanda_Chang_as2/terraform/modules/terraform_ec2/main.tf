# ------------------------------------------------------------------------------------------------------------------
# Create and run the Public EC2 instances 
# count - Number of EC2 instances to create 
# ami - Amazon Machine Image; Determines the OS and other software for the instance 
# instance_type - Hardware of the host computer for the instance 
# key_name - Name of the key pair for the instance 
# subnet_id - ID of the subnet in which the instance will be launched
# availability_zone - Two AZs, each EC2 instance is launched in a different AZ 
# security_groups - ID of the SG that will be used by the instance 
# ------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "ec2_instances" {
  count             = var.instance_count
  ami               = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.ssh_key_name
  subnet_id         = count.index == 0 ? var.public_subnet_id_1 : count.index == 1 ? var.public_subnet_id_2 : null
  availability_zone = element(var.availability_zones, count.index)
  security_groups = var.security_group_id
  
  tags = {
    Name        = "${var.name_tag}"
    server_type = "web"
  }
}
