### VPC 
```sh
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Project` && Value==`acit4640_assignment1`] && Tags[?Key==`Name` && Value==`acit4640_assignment1_vpc`]]' --output yaml 
```

### Route Tables 

```sh
aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Key==`Name` && Value==`acit4640_assignment1_public_rt` || Value==`acit4640_assignment1_private_rt`]]' --output yaml
```

### Internet Gateway 

```sh
aws ec2 describe-internet-gateways --query "InternetGateways[?Tags[?Key=='Name' && Value=='acit4640_assignment1_igw']]" --output yaml 
```

### Security Groups  

```sh
aws ec2 describe-security-groups --query "SecurityGroups[?Tags[?Key=='Name' && Value=='acit4640_assignment1_public_sg' || Value=='acit4640_assignment1_private_sg']]" --output yaml 
```

### EC2 Instances

```sh
aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='Name' && (Value=='acit4640_assignment1_public_ubuntu_server' || Value=='acit4640_assignment1_private_ubuntu_server')]]" --output yaml 
```