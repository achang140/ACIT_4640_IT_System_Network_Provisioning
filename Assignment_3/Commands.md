```sh
terraform init 

terraform validate

terraform plan

terraform apply

terraform state list 

# VPCs
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Project` && Value==`acit4640_assignment2`] && Tags[?Key==`Name` && Value==`acit4640_assignment2_vpc`]]' --output yaml 

# Route Tables
aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Key==`Name` && Value==`acit4640_assignment2_public_rt`]]' --output yaml

# Internet Gateways
aws ec2 describe-internet-gateways --query "InternetGateways[?Tags[?Key=='Name' && Value=='acit4640_assignment2_igw']]" --output yaml 

# Security Groups 
aws ec2 describe-security-groups --query "SecurityGroups[?Tags[?Key=='Name' && (Value=='acit4640_assignment3_public_sg' || Value=='acit4640_assignment3_private_sg')]]" --output yaml

# EC2 Instances 
aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='Name' && (Value=='Public EC2 Instance' || Value=='Private EC2 Instance')]]" --output yaml```



```sh
cat hosts.yml

cat ansible.cfg
```



```sh
ansible-playbook ansible_assign_2.yaml --syntax-check

ansible-playbook ansible_assign_2.yaml --list-tasks

ansible-playbook ansible_assign_2.yaml
ansible-playbook -v ansible_assign_2.yaml
```



```sh 
ls

ssh -i acit4640_assignment.pem ubuntu@
```



```sh
### Ubuntu ###

which bun # Should not output anything b/c bun runtime is installed in "bun" user 

# Check Caddyfile 
cd /etc/caddy
cat Caddyfile 

# Check Caddy Service is Active (Running)
sudo systemctl status caddy

### Bun ###
sudo su - bun 

which bun # Should output: /home/bun/.bun/bin/bun

# Application Files 
ls
ls bun-htmx-4640/

# Service File 
cd /etc/systemd/system
ls # Should see "bun-4640-project.service" listed first 

# Check Service is Active (Running)
sudo systemctl status bun-4640-project.service # Does not need to input password using sudo 

# Curl another server 
curl <EC2_PUBLIC_IP>

### REMEMBER to show the website ! 

```

