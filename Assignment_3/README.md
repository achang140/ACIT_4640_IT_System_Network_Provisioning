# ACIT 4640 - Assignment 3
By Amanda Chang (A01294905)

## Demo Video Link 
[Demo Video](https://youtu.be/SKRl3do4XQk)

## AWS CLI Commands - Terraform 

```sh
terraform init 

terraform validate

terraform plan

terraform apply
```

```sh
terraform state list 
```
```

```

### VPC 
```sh
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Project` && Value==`acit4640_assignment3`] && Tags[?Key==`Name` && Value==`acit4640_assignment3_vpc`]]' --output yaml 
```
```YAML

```

### Route Tables 

```sh
aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Key==`Name` && Value==`acit4640_assignment3_public_rt`]]' --output yaml
```

```YAML

```

### Internet Gateway 

```sh
aws ec2 describe-internet-gateways --query "InternetGateways[?Tags[?Key=='Name' && Value=='acit4640_assignment3_igw']]" --output yaml 
```

```YAML

```

### Security Groups  

```sh
aws ec2 describe-security-groups --query "SecurityGroups[?Tags[?Key=='Name' && (Value=='acit4640_assignment3_public_sg' || Value=='acit4640_assignment3_private_sg')]]" --output yaml
```

```YAML

```

### EC2 Instances

```sh
aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='Name' && (Value=='Public EC2 Instance' || Value=='Private EC2 Instance')]]" --output yaml
```

```YAML

```

## AWS CLI Commands - Ansible Playbook 

```sh
ansible-playbook ansible_assign_3.yaml --syntax-check

ansible-playbook ansible_assign_3.yaml --list-tasks

ansible-playbook ansible_assign_3.yaml
ansible-playbook -v ansible_assign_3.yaml
```

## Ansible Inventory File (hosts.yml)

```

```

## Ansible Configuration File (ansible.cfg)

```

```
