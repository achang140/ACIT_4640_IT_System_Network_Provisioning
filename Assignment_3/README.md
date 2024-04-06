# ACIT 4640 - Assignment 3
By Amanda Chang (A01294905)

## Demo Video Link 
[Demo Video]()

## Directory Structure 
```
.
├── ansible
│   └── roles
│       ├── ansible.cfg
│       ├── backend
│       │   ├── README.md
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── files
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── meta
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   └── main.yml
│       │   ├── templates
│       │   ├── tests
│       │   │   ├── inventory
│       │   │   └── test.yml
│       │   └── vars
│       │       └── main.yml
│       ├── frontend
│       │   ├── README.md
│       │   ├── defaults
│       │   │   └── main.yml
│       │   ├── files
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── meta
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   └── main.yml
│       │   ├── templates
│       │   │   └── hello.conf.j2
│       │   ├── tests
│       │   │   ├── inventory
│       │   │   └── test.yml
│       │   └── vars
│       │       └── main.yml
│       ├── hosts.yml
│       └── site.yml
├── as3-files-4640-w24-main
│   ├── Caddyfile
│   ├── README.md
│   ├── hello-server
│   ├── hello-server.service
│   ├── hello.conf
│   └── index.html
└── terraform
    ├── backend
    │   ├── be_config.tf
    │   ├── provider.tf
    │   ├── terraform.tfstate
    │   ├── terraform.tfstate.backup
    │   ├── terraform.tfvars
    │   └── variables.tf
    └── infrastructure
        ├── acit4640_assignment.pem
        ├── acit4640_assignment.pem.pub
        ├── backend_config.tf
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

27 directories, 46 files
```

## Execution Steps 
1. /terraform/backend
2. /terraform/infrastructure
3. /ansible/roles/

## AWS CLI Commands - Terraform 

```sh
terraform init 

terraform validate

terraform plan

terraform apply
terraform apply -auto-approve
```

```sh
aws s3 ls
```
```
2024-04-06 13:39:26 acit4640-assign3-s3-amanda
```

```sh
terraform state list 
```
```
data.aws_ami.ubuntu
data.local_file.ssh_pub_key
aws_internet_gateway.acit4640_igw
aws_key_pair.ssh_key_pair
aws_route.default_route
aws_route.private_default_route
aws_route_table.private_rt
aws_route_table.public_rt
aws_route_table_association.private_subnet_rt
aws_route_table_association.public_subnet_rt
aws_subnet.private_subnet
aws_subnet.public_subnet
aws_vpc.acit4640_vpc
local_file.ansible_config
local_file.ansible_inventory
terraform_data.ssh_key_pair
module.ec2.aws_instance.ec2_instances[0]
module.ec2.aws_instance.ec2_instances[1]
module.sg.aws_security_group.private_sg
module.sg.aws_security_group.public_sg
module.sg.aws_vpc_security_group_egress_rule.private_egress_rule["allow_all_outbound"]
module.sg.aws_vpc_security_group_egress_rule.public_egress_rule["allow_all_outbound"]
module.sg.aws_vpc_security_group_ingress_rule.private_ingress_rules["0"]
module.sg.aws_vpc_security_group_ingress_rule.private_ingress_rules["2"]
module.sg.aws_vpc_security_group_ingress_rule.public_ingress_rules["publicly_accessible_via_http"]
module.sg.aws_vpc_security_group_ingress_rule.public_ingress_rules["publicly_accessible_via_ssh"]
```

### VPC 
```sh
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Project` && Value==`acit4640_assignment3`] && Tags[?Key==`Name` && Value==`acit4640_assignment3_vpc`]]' --output yaml 
```
```YAML
- CidrBlock: 10.0.0.0/16
  CidrBlockAssociationSet:
  - AssociationId: vpc-cidr-assoc-0cb662bb237d36065
    CidrBlock: 10.0.0.0/16
    CidrBlockState:
      State: associated
  DhcpOptionsId: dopt-09e444f7198473704
  InstanceTenancy: default
  IsDefault: false
  OwnerId: '776713581655'
  State: available
  Tags:
  - Key: Name
    Value: acit4640_assignment3_vpc
  - Key: Project
    Value: acit4640_assignment3
  VpcId: vpc-06f18abc8b4af527f
```

### Route Tables 

```sh
aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Key==`Name` && (Value==`acit4640_assignment3_public_rt` || Value==`acit4640_assignment3_private_rt`)]]' --output yaml
```

```YAML
- Associations:
  - AssociationState:
      State: associated
    Main: false
    RouteTableAssociationId: rtbassoc-0893e005bce904aa4
    RouteTableId: rtb-0c7ca60ab339a8a47
    SubnetId: subnet-0792da30204dcbfaf
  OwnerId: '776713581655'
  PropagatingVgws: []
  RouteTableId: rtb-0c7ca60ab339a8a47
  Routes:
  - DestinationCidrBlock: 10.0.0.0/16
    GatewayId: local
    Origin: CreateRouteTable
    State: active
  - DestinationCidrBlock: 0.0.0.0/0
    GatewayId: igw-068b1894af0260154
    Origin: CreateRoute
    State: active
  Tags:
  - Key: Project
    Value: acit4640_assignment3
  - Key: Name
    Value: acit4640_assignment3_private_rt
  VpcId: vpc-06f18abc8b4af527f
- Associations:
  - AssociationState:
      State: associated
    Main: false
    RouteTableAssociationId: rtbassoc-03fb78b696484fa49
    RouteTableId: rtb-0f8f2bf89aaec98ea
    SubnetId: subnet-0db3f720c13dfb568
  OwnerId: '776713581655'
  PropagatingVgws: []
  RouteTableId: rtb-0f8f2bf89aaec98ea
  Routes:
  - DestinationCidrBlock: 10.0.0.0/16
    GatewayId: local
    Origin: CreateRouteTable
    State: active
  - DestinationCidrBlock: 0.0.0.0/0
    GatewayId: igw-068b1894af0260154
    Origin: CreateRoute
    State: active
  Tags:
  - Key: Name
    Value: acit4640_assignment3_public_rt
  - Key: Project
    Value: acit4640_assignment3
  VpcId: vpc-06f18abc8b4af527f
```

### Internet Gateway 

```sh
aws ec2 describe-internet-gateways --query "InternetGateways[?Tags[?Key=='Name' && Value=='acit4640_assignment3_igw']]" --output yaml 
```

```YAML
- Attachments:
  - State: available
    VpcId: vpc-06f18abc8b4af527f
  InternetGatewayId: igw-068b1894af0260154
  OwnerId: '776713581655'
  Tags:
  - Key: Project
    Value: acit4640_assignment3
  - Key: Name
    Value: acit4640_assignment3_igw
```

### Security Groups  

```sh
aws ec2 describe-security-groups --query "SecurityGroups[?Tags[?Key=='Name' && (Value=='acit4640_assignment3_public_sg' || Value=='acit4640_assignment3_private_sg')]]" --output yaml
```

```YAML
- Description: Allow SSH from everywhere and HTTP in from within the VPC and allow all outbound traffic
  GroupId: sg-00c8a99db1fc56e91
  GroupName: acit4640_assignment3_private_sg
  IpPermissions:
  - FromPort: 80
    IpProtocol: tcp
    IpRanges:
    - CidrIp: 10.0.0.0/16
      Description: Allow HTTP from within the VPC
    Ipv6Ranges: []
    PrefixListIds: []
    ToPort: 80
    UserIdGroupPairs: []
  - FromPort: 22
    IpProtocol: tcp
    IpRanges:
    - CidrIp: 0.0.0.0/0
      Description: Allow SSH from everywhere
    Ipv6Ranges: []
    PrefixListIds: []
    ToPort: 22
    UserIdGroupPairs: []
  IpPermissionsEgress:
  - IpProtocol: '-1'
    IpRanges:
    - CidrIp: 0.0.0.0/0
      Description: Allow all outbound traffic
    Ipv6Ranges: []
    PrefixListIds: []
    UserIdGroupPairs: []
  OwnerId: '776713581655'
  Tags:
  - Key: Name
    Value: acit4640_assignment3_private_sg
  - Key: Project
    Value: acit4640_assignment3
  VpcId: vpc-06f18abc8b4af527f
- Description: Allow SSH and HTTP in from everywhere and allow all outbound traffic
  GroupId: sg-0e8dcc3778d9d4699
  GroupName: acit4640_assignment3_public_sg
  IpPermissions:
  - FromPort: 80
    IpProtocol: tcp
    IpRanges:
    - CidrIp: 0.0.0.0/0
      Description: Allow HTTP from everywhere
    Ipv6Ranges: []
    PrefixListIds: []
    ToPort: 80
    UserIdGroupPairs: []
  - FromPort: 22
    IpProtocol: tcp
    IpRanges:
    - CidrIp: 0.0.0.0/0
      Description: Allow SSH from everywhere
    Ipv6Ranges: []
    PrefixListIds: []
    ToPort: 22
    UserIdGroupPairs: []
  IpPermissionsEgress:
  - IpProtocol: '-1'
    IpRanges:
    - CidrIp: 0.0.0.0/0
      Description: Allow all outbound traffic
    Ipv6Ranges: []
    PrefixListIds: []
    UserIdGroupPairs: []
  OwnerId: '776713581655'
  Tags:
  - Key: Project
    Value: acit4640_assignment3
  - Key: Name
    Value: acit4640_assignment3_public_sg
  VpcId: vpc-06f18abc8b4af527f
```

### EC2 Instances

```sh
aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='Name' && (Value=='Public EC2 Instance' || Value=='Private EC2 Instance')]]" --output yaml
```

```YAML
- - AmiLaunchIndex: 0
    Architecture: x86_64
    BlockDeviceMappings:
    - DeviceName: /dev/sda1
      Ebs:
        AttachTime: '2024-04-06T20:40:11+00:00'
        DeleteOnTermination: true
        Status: attached
        VolumeId: vol-0f0c4ba98977c4b18
    BootMode: uefi-preferred
    CapacityReservationSpecification:
      CapacityReservationPreference: open
    ClientToken: terraform-20240406204008950400000004
    CpuOptions:
      CoreCount: 1
      ThreadsPerCore: 1
    CurrentInstanceBootMode: legacy-bios
    EbsOptimized: false
    EnaSupport: true
    EnclaveOptions:
      Enabled: false
    HibernationOptions:
      Configured: false
    Hypervisor: xen
    ImageId: ami-04eed88b1a6b28477
    InstanceId: i-02273b7002d6fe98f
    InstanceType: t2.micro
    KeyName: acit4640_assignment
    LaunchTime: '2024-04-06T20:40:10+00:00'
    MaintenanceOptions:
      AutoRecovery: default
    MetadataOptions:
      HttpEndpoint: enabled
      HttpProtocolIpv6: disabled
      HttpPutResponseHopLimit: 1
      HttpTokens: optional
      InstanceMetadataTags: disabled
      State: applied
    Monitoring:
      State: disabled
    NetworkInterfaces:
    - Association:
        IpOwnerId: amazon
        PublicDnsName: ec2-34-217-30-123.us-west-2.compute.amazonaws.com
        PublicIp: 34.217.30.123
      Attachment:
        AttachTime: '2024-04-06T20:40:10+00:00'
        AttachmentId: eni-attach-013c2489e320b081b
        DeleteOnTermination: true
        DeviceIndex: 0
        NetworkCardIndex: 0
        Status: attached
      Description: ''
      Groups:
      - GroupId: sg-00c8a99db1fc56e91
        GroupName: acit4640_assignment3_private_sg
      InterfaceType: interface
      Ipv6Addresses: []
      MacAddress: 02:a7:55:a2:de:05
      NetworkInterfaceId: eni-02a1ecdd38abcdce1
      OwnerId: '776713581655'
      PrivateDnsName: ip-10-0-21-117.us-west-2.compute.internal
      PrivateIpAddress: 10.0.21.117
      PrivateIpAddresses:
      - Association:
          IpOwnerId: amazon
          PublicDnsName: ec2-34-217-30-123.us-west-2.compute.amazonaws.com
          PublicIp: 34.217.30.123
        Primary: true
        PrivateDnsName: ip-10-0-21-117.us-west-2.compute.internal
        PrivateIpAddress: 10.0.21.117
      SourceDestCheck: true
      Status: in-use
      SubnetId: subnet-0792da30204dcbfaf
      VpcId: vpc-06f18abc8b4af527f
    Placement:
      AvailabilityZone: us-west-2a
      GroupName: ''
      Tenancy: default
    PlatformDetails: Linux/UNIX
    PrivateDnsName: ip-10-0-21-117.us-west-2.compute.internal
    PrivateDnsNameOptions:
      EnableResourceNameDnsAAAARecord: false
      EnableResourceNameDnsARecord: false
      HostnameType: ip-name
    PrivateIpAddress: 10.0.21.117
    ProductCodes: []
    PublicDnsName: ec2-34-217-30-123.us-west-2.compute.amazonaws.com
    PublicIpAddress: 34.217.30.123
    RootDeviceName: /dev/sda1
    RootDeviceType: ebs
    SecurityGroups:
    - GroupId: sg-00c8a99db1fc56e91
      GroupName: acit4640_assignment3_private_sg
    SourceDestCheck: true
    State:
      Code: 16
      Name: running
    StateTransitionReason: ''
    SubnetId: subnet-0792da30204dcbfaf
    Tags:
    - Key: Name
      Value: Private EC2 Instance
    - Key: server_type
      Value: private_ec2
    - Key: Project
      Value: acit4640_assignment3
    UsageOperation: RunInstances
    UsageOperationUpdateTime: '2024-04-06T20:40:10+00:00'
    VirtualizationType: hvm
    VpcId: vpc-06f18abc8b4af527f
- - AmiLaunchIndex: 0
    Architecture: x86_64
    BlockDeviceMappings:
    - DeviceName: /dev/sda1
      Ebs:
        AttachTime: '2024-04-06T20:40:11+00:00'
        DeleteOnTermination: true
        Status: attached
        VolumeId: vol-0391b7d2fa4247745
    BootMode: uefi-preferred
    CapacityReservationSpecification:
      CapacityReservationPreference: open
    ClientToken: terraform-20240406204008950400000003
    CpuOptions:
      CoreCount: 1
      ThreadsPerCore: 1
    CurrentInstanceBootMode: legacy-bios
    EbsOptimized: false
    EnaSupport: true
    EnclaveOptions:
      Enabled: false
    HibernationOptions:
      Configured: false
    Hypervisor: xen
    ImageId: ami-04eed88b1a6b28477
    InstanceId: i-02ba30addeee7c5bb
    InstanceType: t2.micro
    KeyName: acit4640_assignment
    LaunchTime: '2024-04-06T20:40:10+00:00'
    MaintenanceOptions:
      AutoRecovery: default
    MetadataOptions:
      HttpEndpoint: enabled
      HttpProtocolIpv6: disabled
      HttpPutResponseHopLimit: 1
      HttpTokens: optional
      InstanceMetadataTags: disabled
      State: applied
    Monitoring:
      State: disabled
    NetworkInterfaces:
    - Association:
        IpOwnerId: amazon
        PublicDnsName: ec2-52-40-80-101.us-west-2.compute.amazonaws.com
        PublicIp: 52.40.80.101
      Attachment:
        AttachTime: '2024-04-06T20:40:10+00:00'
        AttachmentId: eni-attach-042179266f1906da7
        DeleteOnTermination: true
        DeviceIndex: 0
        NetworkCardIndex: 0
        Status: attached
      Description: ''
      Groups:
      - GroupId: sg-0e8dcc3778d9d4699
        GroupName: acit4640_assignment3_public_sg
      InterfaceType: interface
      Ipv6Addresses: []
      MacAddress: 02:6f:9c:fa:c3:e7
      NetworkInterfaceId: eni-0df69648712cef586
      OwnerId: '776713581655'
      PrivateDnsName: ip-10-0-11-35.us-west-2.compute.internal
      PrivateIpAddress: 10.0.11.35
      PrivateIpAddresses:
      - Association:
          IpOwnerId: amazon
          PublicDnsName: ec2-52-40-80-101.us-west-2.compute.amazonaws.com
          PublicIp: 52.40.80.101
        Primary: true
        PrivateDnsName: ip-10-0-11-35.us-west-2.compute.internal
        PrivateIpAddress: 10.0.11.35
      SourceDestCheck: true
      Status: in-use
      SubnetId: subnet-0db3f720c13dfb568
      VpcId: vpc-06f18abc8b4af527f
    Placement:
      AvailabilityZone: us-west-2a
      GroupName: ''
      Tenancy: default
    PlatformDetails: Linux/UNIX
    PrivateDnsName: ip-10-0-11-35.us-west-2.compute.internal
    PrivateDnsNameOptions:
      EnableResourceNameDnsAAAARecord: false
      EnableResourceNameDnsARecord: false
      HostnameType: ip-name
    PrivateIpAddress: 10.0.11.35
    ProductCodes: []
    PublicDnsName: ec2-52-40-80-101.us-west-2.compute.amazonaws.com
    PublicIpAddress: 52.40.80.101
    RootDeviceName: /dev/sda1
    RootDeviceType: ebs
    SecurityGroups:
    - GroupId: sg-0e8dcc3778d9d4699
      GroupName: acit4640_assignment3_public_sg
    SourceDestCheck: true
    State:
      Code: 16
      Name: running
    StateTransitionReason: ''
    SubnetId: subnet-0db3f720c13dfb568
    Tags:
    - Key: Project
      Value: acit4640_assignment3
    - Key: server_type
      Value: public_ec2
    - Key: Name
      Value: Public EC2 Instance
    UsageOperation: RunInstances
    UsageOperationUpdateTime: '2024-04-06T20:40:10+00:00'
    VirtualizationType: hvm
    VpcId: vpc-06f18abc8b4af527f
```

## AWS CLI Commands - Ansible Playbook 

```sh
ansible-playbook site.yml --syntax-check
```

```sh
ansible-playbook site.yml --list-tasks
```
```
playbook: site.yml

  play #1 (private_ec2): Configure backend EC2 instance TAGS: [backend]
    tasks:
      Run backend role  TAGS: [backend]

  play #2 (public_ec2): Configure frontend EC2 instance TAGS: [frontend]
    tasks:
      Run frontend role TAGS: [frontend]
```

```sh
ansible-playbook --tags backend -v site.yml
ansible-playbook --tags frontend -v site.yml
```

## Ansible Inventory File (hosts.yml)

```
all:
    vars:
        ansible_ssh_private_key_file: "../../terraform/infrastructure/acit4640_assignment.pem"
        ansible_user: ubuntu

public_ec2:
    hosts:
      Public EC2 Instance:
        ansible_host: ec2-52-40-80-101.us-west-2.compute.amazonaws.com

private_ec2:
    hosts:
      Private EC2 Instance:
        ansible_host: 34.217.30.123
        reverse_proxy_ip: 10.0.21.117
```

## Ansible Configuration File (ansible.cfg)

```
[defaults]
inventory = hosts.yml
stdout_callback = debug
allow_world_readable_tmpfiles = True
pipelining = True

[ssh_connection]
host_key_checking = False
ssh_common_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```
## Frontend and Backend 

### Testing Frontend 
```sh
curl http://52.40.80.101 # Public EC2 Instance's Public IP
```

### Testing Backend 
```sh
curl -X POST -H "Content-Type: application/json" \
  -d '{"message": "Hello from your server"}' \
  http://52.40.80.101/echo
```
No Error, should return: 
```
{"message": "Hello from your server"}
```