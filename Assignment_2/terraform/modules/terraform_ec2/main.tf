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

# resource "aws_instance" "ec2_instance_1" {
#   ami             = var.ami_id
#   instance_type   = var.type
#   key_name        = var.ssh_key_name
#   subnet_id       = var.public_subnet_id_1
#   availability_zone = var.availability_zone_1
#   security_groups = var.security_group_id
  
#   tags = {
#     Name = "${var.project_name}_public_ubuntu_server_1"
#   }
# }

# resource "aws_instance" "ec2_instance_2" {
#   ami             = var.ami_id
#   instance_type   = var.type
#   key_name        = var.ssh_key_name
#   subnet_id       = var.public_subnet_id_2
#   availability_zone = var.availability_zone_2
#   security_groups = var.security_group_id
  
#   tags = {
#     Name = "${var.project_name}_public_ubuntu_server_2"
#   }
# }
