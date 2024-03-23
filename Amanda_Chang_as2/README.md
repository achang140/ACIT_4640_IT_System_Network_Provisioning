# ACIT 4640 - Assignment 2 
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
data.aws_ami.ubuntu
data.local_file.ssh_pub_key
aws_internet_gateway.acit4640_igw
aws_key_pair.ssh_key_pair
aws_route.default_route
aws_route_table.public_rt
aws_route_table_association.public_subnet_rt_1
aws_route_table_association.public_subnet_rt_2
aws_security_group.public_sg
aws_subnet.public_subnet_1
aws_subnet.public_subnet_2
aws_vpc.acit4640_vpc
aws_vpc_security_group_egress_rule.outbound_public_sg
aws_vpc_security_group_ingress_rule.inbound_http_public_sg
aws_vpc_security_group_ingress_rule.inbound_ssh_public_sg
local_file.ansible_config
local_file.ansible_inventory
terraform_data.ssh_key_pair
module.ec2.aws_instance.ec2_instances[0]
module.ec2.aws_instance.ec2_instances[1]
```

### VPC 
```sh
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Project` && Value==`acit4640_assignment2`] && Tags[?Key==`Name` && Value==`acit4640_assignment2_vpc`]]' --output yaml 
```
```YAML
- CidrBlock: 10.0.0.0/16
  CidrBlockAssociationSet:
  - AssociationId: vpc-cidr-assoc-03ddb47ac9d5ec30a
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
    Value: acit4640_assignment2_vpc
  - Key: Project
    Value: acit4640_assignment2
  VpcId: vpc-0a64818b5f31452fe
```

### Route Tables 

```sh
aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Key==`Name` && Value==`acit4640_assignment2_public_rt`]]' --output yaml
```

```YAML
- Associations:
  - AssociationState:
      State: associated
    Main: false
    RouteTableAssociationId: rtbassoc-0ea98d8dceda15778
    RouteTableId: rtb-0959233543eba60e8
    SubnetId: subnet-038592730240b05d3
  - AssociationState:
      State: associated
    Main: false
    RouteTableAssociationId: rtbassoc-0788ba1a69957735a
    RouteTableId: rtb-0959233543eba60e8
    SubnetId: subnet-0cc1f24aed76c743a
  OwnerId: '776713581655'
  PropagatingVgws: []
  RouteTableId: rtb-0959233543eba60e8
  Routes:
  - DestinationCidrBlock: 10.0.0.0/16
    GatewayId: local
    Origin: CreateRouteTable
    State: active
  - DestinationCidrBlock: 0.0.0.0/0
    GatewayId: igw-09b04399f5b9707c5
    Origin: CreateRoute
    State: active
  Tags:
  - Key: Project
    Value: acit4640_assignment2
  - Key: Name
    Value: acit4640_assignment2_public_rt
  VpcId: vpc-0a64818b5f31452fe
```

### Internet Gateway 

```sh
aws ec2 describe-internet-gateways --query "InternetGateways[?Tags[?Key=='Name' && Value=='acit4640_assignment2_igw']]" --output yaml 
```

```YAML
- Attachments:
  - State: available
    VpcId: vpc-0a64818b5f31452fe
  InternetGatewayId: igw-09b04399f5b9707c5
  OwnerId: '776713581655'
  Tags:
  - Key: Project
    Value: acit4640_assignment2
  - Key: Name
    Value: acit4640_assignment2_igw
```

### Security Groups  

```sh
aws ec2 describe-security-groups --query "SecurityGroups[?Tags[?Key=='Name' && Value=='acit4640_assignment2_public_sg']]" --output yaml 
```

```YAML
- Description: Allow SSH and HTTP in from everywhere and allow all outbound traffic
  GroupId: sg-061bf25b6523113ca
  GroupName: acit4640_assignment2_public_sg
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
  - Key: Name
    Value: acit4640_assignment2_public_sg
  - Key: Project
    Value: acit4640_assignment2
  VpcId: vpc-0a64818b5f31452fe
```

### EC2 Instances

```sh
aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='Name' && (Value=='Public EC2 Instance')]]" --output yaml
```

```YAML
- - AmiLaunchIndex: 0
    Architecture: x86_64
    BlockDeviceMappings:
    - DeviceName: /dev/sda1
      Ebs:
        AttachTime: '2024-03-13T17:37:06+00:00'
        DeleteOnTermination: true
        Status: attached
        VolumeId: vol-0f00a705f5f4d305b
    BootMode: uefi-preferred
    CapacityReservationSpecification:
      CapacityReservationPreference: open
    ClientToken: terraform-20240313173702469200000003
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
    InstanceId: i-02c68602fb5e83408
    InstanceType: t2.micro
    KeyName: acit4640_assignment
    LaunchTime: '2024-03-13T17:37:05+00:00'
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
        PublicDnsName: ec2-35-87-188-111.us-west-2.compute.amazonaws.com
        PublicIp: 35.87.188.111
      Attachment:
        AttachTime: '2024-03-13T17:37:05+00:00'
        AttachmentId: eni-attach-0388962d5bfc9d7b4
        DeleteOnTermination: true
        DeviceIndex: 0
        NetworkCardIndex: 0
        Status: attached
      Description: ''
      Groups:
      - GroupId: sg-061bf25b6523113ca
        GroupName: acit4640_assignment2_public_sg
      InterfaceType: interface
      Ipv6Addresses: []
      MacAddress: 06:d2:0f:bb:8a:4f
      NetworkInterfaceId: eni-09e4555cdeacb3e46
      OwnerId: '776713581655'
      PrivateDnsName: ip-10-0-29-74.us-west-2.compute.internal
      PrivateIpAddress: 10.0.29.74
      PrivateIpAddresses:
      - Association:
          IpOwnerId: amazon
          PublicDnsName: ec2-35-87-188-111.us-west-2.compute.amazonaws.com
          PublicIp: 35.87.188.111
        Primary: true
        PrivateDnsName: ip-10-0-29-74.us-west-2.compute.internal
        PrivateIpAddress: 10.0.29.74
      SourceDestCheck: true
      Status: in-use
      SubnetId: subnet-038592730240b05d3
      VpcId: vpc-0a64818b5f31452fe
    Placement:
      AvailabilityZone: us-west-2b
      GroupName: ''
      Tenancy: default
    PlatformDetails: Linux/UNIX
    PrivateDnsName: ip-10-0-29-74.us-west-2.compute.internal
    PrivateDnsNameOptions:
      EnableResourceNameDnsAAAARecord: false
      EnableResourceNameDnsARecord: false
      HostnameType: ip-name
    PrivateIpAddress: 10.0.29.74
    ProductCodes: []
    PublicDnsName: ec2-35-87-188-111.us-west-2.compute.amazonaws.com
    PublicIpAddress: 35.87.188.111
    RootDeviceName: /dev/sda1
    RootDeviceType: ebs
    SecurityGroups:
    - GroupId: sg-061bf25b6523113ca
      GroupName: acit4640_assignment2_public_sg
    SourceDestCheck: true
    State:
      Code: 16
      Name: running
    StateTransitionReason: ''
    SubnetId: subnet-038592730240b05d3
    Tags:
    - Key: server_type
      Value: web
    - Key: Name
      Value: Public EC2 Instance
    - Key: Project
      Value: acit4640_assignment2
    UsageOperation: RunInstances
    UsageOperationUpdateTime: '2024-03-13T17:37:05+00:00'
    VirtualizationType: hvm
    VpcId: vpc-0a64818b5f31452fe
- - AmiLaunchIndex: 0
    Architecture: x86_64
    BlockDeviceMappings:
    - DeviceName: /dev/sda1
      Ebs:
        AttachTime: '2024-03-13T17:37:05+00:00'
        DeleteOnTermination: true
        Status: attached
        VolumeId: vol-0cd519200baf008c2
    BootMode: uefi-preferred
    CapacityReservationSpecification:
      CapacityReservationPreference: open
    ClientToken: terraform-20240313173702444500000002
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
    InstanceId: i-0f93fd8c2dc0dcbbe
    InstanceType: t2.micro
    KeyName: acit4640_assignment
    LaunchTime: '2024-03-13T17:37:05+00:00'
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
        PublicDnsName: ec2-54-202-121-30.us-west-2.compute.amazonaws.com
        PublicIp: 54.202.121.30
      Attachment:
        AttachTime: '2024-03-13T17:37:05+00:00'
        AttachmentId: eni-attach-047859365627d669e
        DeleteOnTermination: true
        DeviceIndex: 0
        NetworkCardIndex: 0
        Status: attached
      Description: ''
      Groups:
      - GroupId: sg-061bf25b6523113ca
        GroupName: acit4640_assignment2_public_sg
      InterfaceType: interface
      Ipv6Addresses: []
      MacAddress: 02:7f:5c:e6:93:eb
      NetworkInterfaceId: eni-0740af1532c4cf47b
      OwnerId: '776713581655'
      PrivateDnsName: ip-10-0-1-119.us-west-2.compute.internal
      PrivateIpAddress: 10.0.1.119
      PrivateIpAddresses:
      - Association:
          IpOwnerId: amazon
          PublicDnsName: ec2-54-202-121-30.us-west-2.compute.amazonaws.com
          PublicIp: 54.202.121.30
        Primary: true
        PrivateDnsName: ip-10-0-1-119.us-west-2.compute.internal
        PrivateIpAddress: 10.0.1.119
      SourceDestCheck: true
      Status: in-use
      SubnetId: subnet-0cc1f24aed76c743a
      VpcId: vpc-0a64818b5f31452fe
    Placement:
      AvailabilityZone: us-west-2a
      GroupName: ''
      Tenancy: default
    PlatformDetails: Linux/UNIX
    PrivateDnsName: ip-10-0-1-119.us-west-2.compute.internal
    PrivateDnsNameOptions:
      EnableResourceNameDnsAAAARecord: false
      EnableResourceNameDnsARecord: false
      HostnameType: ip-name
    PrivateIpAddress: 10.0.1.119
    ProductCodes: []
    PublicDnsName: ec2-54-202-121-30.us-west-2.compute.amazonaws.com
    PublicIpAddress: 54.202.121.30
    RootDeviceName: /dev/sda1
    RootDeviceType: ebs
    SecurityGroups:
    - GroupId: sg-061bf25b6523113ca
      GroupName: acit4640_assignment2_public_sg
    SourceDestCheck: true
    State:
      Code: 16
      Name: running
    StateTransitionReason: ''
    SubnetId: subnet-0cc1f24aed76c743a
    Tags:
    - Key: Name
      Value: Public EC2 Instance
    - Key: server_type
      Value: web
    - Key: Project
      Value: acit4640_assignment2
    UsageOperation: RunInstances
    UsageOperationUpdateTime: '2024-03-13T17:37:05+00:00'
    VirtualizationType: hvm
    VpcId: vpc-0a64818b5f31452fe
```

## AWS CLI Commands - Ansible Playbook 

```sh
ansible-playbook ansible_assign_2.yaml --syntax-check

ansible-playbook ansible_assign_2.yaml --list-tasks

ansible-playbook ansible_assign_2.yaml
ansible-playbook -v ansible_assign_2.yaml
```

## Ansible Inventory File (hosts.yml)

```
all:
  vars:
    ansible_ssh_private_key_file: "./acit4640_assignment.pem"
    ansible_user: ubuntu
web:
  hosts:

    Public EC2 Instance-0:
      ansible_host: ec2-54-202-121-30.us-west-2.compute.amazonaws.com


    Public EC2 Instance-1:
      ansible_host: ec2-35-87-188-111.us-west-2.compute.amazonaws.com


  vars:
      new_user: bun
      new_user_groups: sudo
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
