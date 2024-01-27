#!/usr/bin/env bash
# Team Members: Amanda Chang (A01294905), Jace Kang (A00924648), Simon Freeman (A01074210)

set -eu

# Get vpc_id, subnet_id, key_name from infrastructure_data file 
source infrastructure_data

region="us-west-2"
key_name="MyKeyPair" #change this to the name of your key


# Get Ubuntu 23.04 image id owned by amazon (Most recent one of Ubuntu-lunar-23.04 image)
ubuntu_ami=$(aws ec2 describe-images --region $region \
 --owners amazon \
 --filters Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server* \
 --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)

instance_type="t2.micro"

# Create security group allowing SSH and HTTP from anywhere
security_group_id=$(aws ec2 create-security-group --group-name MySecurityGroup \
 --description "Allow SSH and HTTP" --vpc-id $vpc_id --query 'GroupId' \
 --region $region \
 --output text)

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region

# Launch an EC2 instance in the public subnet
# COMPLETE THIS PART
instance_id=$(aws ec2 run-instances \
  --image-id $ubuntu_ami \
  --key-name $key_name \
  --count 1 \
  --instance-type $instance_type \
  --subnet-id $subnet_id \
  --security-group-ids $security_group_id \
  --query 'Instances[0].InstanceId' \
  --output text \
  --associate-public-ip-address) 

# wait for ec2 instance to be running
aws ec2 wait instance-running --instance-ids $instance_id

# Get the public IP address of the EC2 instance
# COMPLETE THIS PART
public_ip=$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# Write instance data to a file
# COMPLETE THIS PART
echo "Public IP: $public_ip" > instance_data

