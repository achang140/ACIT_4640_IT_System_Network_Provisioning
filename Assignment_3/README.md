# ACIT 4640 - Assignment 3
By Amanda Chang (A01294905)

## Demo Video Link 
[Demo Video]()

## Directory Structure 
```
.
├── ansible
│   └── ansible_assign_3.yaml
├── as3-files-4640-w24-main
│   ├── Caddyfile
│   ├── README.md
│   ├── hello-server
│   ├── hello-server.service
│   ├── hello.conf
│   └── index.html
└── terraform
    ├── backend_setup
    │   ├── be_config.tf
    │   ├── provider.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
    └── infrastructure
        ├── main.tf
        ├── modules
        │   ├── terraform_ec2
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── variables.tf
        │   └── terraform_sg
        │       ├── main.tf
        │       ├── output.tf
        │       └── variables.tf
        ├── outputs.tf
        ├── provider.tf
        ├── terraform.tfvars
        └── variables.tf

8 directories, 22 files
```

## Execution Steps 
1. /terraform/backend_setup - Terraform commands 
2. /terraform/infrastructure - Terraform commands 
3. /ansible/ansible_assign_3.yaml - Ansible Playbook commands 

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
