# ACIT 4640 - Assignment 1 
By Amanda Chang (A01294905)

## Demo Video Link 
[Demo Video](https://youtu.be/V6_yp2mArpc?si=VPUV4mjButocuKDu)

## AWS CLI Commands 

```sh
terraform state list 
```
```
data.aws_ami.ubuntu
data.local_file.ssh_pub_key
aws_instance.private_ec2
aws_instance.public_ec2
aws_internet_gateway.acit4640_igw
aws_key_pair.ssh_key_pair
aws_route.default_route
aws_route_table.private_rt
aws_route_table.public_rt
aws_route_table_association.private_subnet_rt
aws_route_table_association.public_subnet_rt
aws_security_group.private_sg
aws_security_group.public_sg
aws_subnet.private_subnet
aws_subnet.public_subnet
aws_vpc.acit4640_vpc
aws_vpc_security_group_egress_rule.outbound_private_sg
aws_vpc_security_group_egress_rule.outbound_public_sg
aws_vpc_security_group_ingress_rule.inbound_http_private_sg
aws_vpc_security_group_ingress_rule.inbound_http_public_sg
aws_vpc_security_group_ingress_rule.inbound_ssh_private_sg
aws_vpc_security_group_ingress_rule.inbound_ssh_public_sg
terraform_data.ssh_key_pair
```

### VPC 
```sh
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Project` && Value==`acit4640_assignment1`] && Tags[?Key==`Name` && Value==`acit4640_assignment1_vpc`]]' --output yaml 
```
```YAML
- CidrBlock: 10.0.0.0/16
  CidrBlockAssociationSet:
  - AssociationId: vpc-cidr-assoc-09b5b1138b24e2019
    CidrBlock: 10.0.0.0/16
    CidrBlockState:
      State: associated
  DhcpOptionsId: dopt-09e444f7198473704
  InstanceTenancy: default
  IsDefault: false
  OwnerId: '776713581655'
  State: available
  Tags:
  - Key: Project
    Value: acit4640_assignment1
  - Key: Name
    Value: acit4640_assignment1_vpc
  VpcId: vpc-03524577c945523d7
```

### Route Tables 

```sh
aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Key==`Name` && Value==`acit4640_assignment1_public_rt` || Value==`acit4640_assignment1_private_rt`]]' --output yaml
```

```YAML
- Associations:
  - AssociationState:
      State: associated
    Main: false
    RouteTableAssociationId: rtbassoc-0084ad9e28996f023
    RouteTableId: rtb-005b9ae7f1c3c68ab
    SubnetId: subnet-031cc0f8ee77b4206
  OwnerId: '776713581655'
  PropagatingVgws: []
  RouteTableId: rtb-005b9ae7f1c3c68ab
  Routes:
  - DestinationCidrBlock: 10.0.0.0/16
    GatewayId: local
    Origin: CreateRouteTable
    State: active
  - DestinationCidrBlock: 0.0.0.0/0
    GatewayId: igw-0bd7fa9f3ac7f63e1
    Origin: CreateRoute
    State: active
  Tags:
  - Key: Project
    Value: acit4640_assignment1
  - Key: Name
    Value: acit4640_assignment1_public_rt
  VpcId: vpc-03524577c945523d7
- Associations:
  - AssociationState:
      State: associated
    Main: false
    RouteTableAssociationId: rtbassoc-011f1a6471de97a6b
    RouteTableId: rtb-0448220b49a463c76
    SubnetId: subnet-0846bcc280a088ac1
  OwnerId: '776713581655'
  PropagatingVgws: []
  RouteTableId: rtb-0448220b49a463c76
  Routes:
  - DestinationCidrBlock: 10.0.0.0/16
    GatewayId: local
    Origin: CreateRouteTable
    State: active
  Tags:
  - Key: Project
    Value: acit4640_assignment1
  - Key: Name
    Value: acit4640_assignment1_private_rt
  VpcId: vpc-03524577c945523d7
```

### Internet Gateway 

```sh
aws ec2 describe-internet-gateways --query "InternetGateways[?Tags[?Key=='Name' && Value=='acit4640_assignment1_igw']]" --output yaml 
```

```YAML
- Attachments:
  - State: available
    VpcId: vpc-03524577c945523d7
  InternetGatewayId: igw-0bd7fa9f3ac7f63e1
  OwnerId: '776713581655'
  Tags:
  - Key: Name
    Value: acit4640_assignment1_igw
  - Key: Project
    Value: acit4640_assignment1
```

### Security Groups  

```sh
aws ec2 describe-security-groups --query "SecurityGroups[?Tags[?Key=='Name' && Value=='acit4640_assignment1_public_sg' || Value=='acit4640_assignment1_private_sg']]" --output yaml 
```

```YAML
- Description: Allow SSH and HTTP in from within the VPC and allow all outbound traffic
  GroupId: sg-096f51b14b10060f9
  GroupName: acit4640_assignment1_private_sg
  IpPermissions:
  - FromPort: 80
    IpProtocol: tcp
    IpRanges: []
    Ipv6Ranges: []
    PrefixListIds: []
    ToPort: 80
    UserIdGroupPairs:
    - Description: Allow HTTP from within the VPC
      GroupId: sg-044c2c814b02c94fc
      UserId: '776713581655'
  - FromPort: 22
    IpProtocol: tcp
    IpRanges: []
    Ipv6Ranges: []
    PrefixListIds: []
    ToPort: 22
    UserIdGroupPairs:
    - Description: Allow SSH from within the VPC
      GroupId: sg-044c2c814b02c94fc
      UserId: '776713581655'
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
    Value: acit4640_assignment1_private_sg
  - Key: Project
    Value: acit4640_assignment1
  VpcId: vpc-03524577c945523d7
- Description: Allow SSH and HTTP in from everywhere and allow all outbound traffic
  GroupId: sg-044c2c814b02c94fc
  GroupName: acit4640_assignment1_public_sg
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
    Value: acit4640_assignment1_public_sg
  - Key: Project
    Value: acit4640_assignment1
  VpcId: vpc-03524577c945523d7
```

### EC2 Instances

```sh
aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='Name' && (Value=='acit4640_assignment1_public_ubuntu_server' || Value=='acit4640_assignment1_private_ubuntu_server')]]" --output yaml 
```

```YAML
- - AmiLaunchIndex: 0
    Architecture: x86_64
    BlockDeviceMappings:
    - DeviceName: /dev/sda1
      Ebs:
        AttachTime: '2024-02-04T23:50:00+00:00'
        DeleteOnTermination: true
        Status: attached
        VolumeId: vol-00d6678dac42fd5c5
    BootMode: uefi-preferred
    CapacityReservationSpecification:
      CapacityReservationPreference: open
    ClientToken: terraform-20240204234958015100000004
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
    InstanceId: i-07eee2c33779d90ff
    InstanceType: t2.micro
    KeyName: acit4640_assignment
    LaunchTime: '2024-02-04T23:50:00+00:00'
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
        PublicDnsName: ec2-35-167-152-18.us-west-2.compute.amazonaws.com
        PublicIp: 35.167.152.18
      Attachment:
        AttachTime: '2024-02-04T23:50:00+00:00'
        AttachmentId: eni-attach-0a321b3adfbbcb900
        DeleteOnTermination: true
        DeviceIndex: 0
        NetworkCardIndex: 0
        Status: attached
      Description: ''
      Groups:
      - GroupId: sg-044c2c814b02c94fc
        GroupName: acit4640_assignment1_public_sg
      InterfaceType: interface
      Ipv6Addresses: []
      MacAddress: 02:f0:f3:e1:de:79
      NetworkInterfaceId: eni-0abad15f3ee8d9598
      OwnerId: '776713581655'
      PrivateDnsName: ip-10-0-0-23.us-west-2.compute.internal
      PrivateIpAddress: 10.0.0.23
      PrivateIpAddresses:
      - Association:
          IpOwnerId: amazon
          PublicDnsName: ec2-35-167-152-18.us-west-2.compute.amazonaws.com
          PublicIp: 35.167.152.18
        Primary: true
        PrivateDnsName: ip-10-0-0-23.us-west-2.compute.internal
        PrivateIpAddress: 10.0.0.23
      SourceDestCheck: true
      Status: in-use
      SubnetId: subnet-031cc0f8ee77b4206
      VpcId: vpc-03524577c945523d7
    Placement:
      AvailabilityZone: us-west-2a
      GroupName: ''
      Tenancy: default
    PlatformDetails: Linux/UNIX
    PrivateDnsName: ip-10-0-0-23.us-west-2.compute.internal
    PrivateDnsNameOptions:
      EnableResourceNameDnsAAAARecord: false
      EnableResourceNameDnsARecord: false
      HostnameType: ip-name
    PrivateIpAddress: 10.0.0.23
    ProductCodes: []
    PublicDnsName: ec2-35-167-152-18.us-west-2.compute.amazonaws.com
    PublicIpAddress: 35.167.152.18
    RootDeviceName: /dev/sda1
    RootDeviceType: ebs
    SecurityGroups:
    - GroupId: sg-044c2c814b02c94fc
      GroupName: acit4640_assignment1_public_sg
    SourceDestCheck: true
    State:
      Code: 16
      Name: running
    StateTransitionReason: ''
    SubnetId: subnet-031cc0f8ee77b4206
    Tags:
    - Key: Name
      Value: acit4640_assignment1_public_ubuntu_server
    - Key: Project
      Value: acit4640_assignment1
    UsageOperation: RunInstances
    UsageOperationUpdateTime: '2024-02-04T23:50:00+00:00'
    VirtualizationType: hvm
    VpcId: vpc-03524577c945523d7
- - AmiLaunchIndex: 0
    Architecture: x86_64
    BlockDeviceMappings:
    - DeviceName: /dev/sda1
      Ebs:
        AttachTime: '2024-02-04T23:49:51+00:00'
        DeleteOnTermination: true
        Status: attached
        VolumeId: vol-008856f91a2732b4e
    BootMode: uefi-preferred
    CapacityReservationSpecification:
      CapacityReservationPreference: open
    ClientToken: terraform-20240204234948729700000003
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
    InstanceId: i-06545e9cce80268ae
    InstanceType: t2.micro
    KeyName: acit4640_assignment
    LaunchTime: '2024-02-04T23:49:50+00:00'
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
    - Attachment:
        AttachTime: '2024-02-04T23:49:50+00:00'
        AttachmentId: eni-attach-0277f8c57a575e1d2
        DeleteOnTermination: true
        DeviceIndex: 0
        NetworkCardIndex: 0
        Status: attached
      Description: ''
      Groups:
      - GroupId: sg-096f51b14b10060f9
        GroupName: acit4640_assignment1_private_sg
      InterfaceType: interface
      Ipv6Addresses: []
      MacAddress: 02:ff:85:8a:f0:b1
      NetworkInterfaceId: eni-0cad8538ae5a14460
      OwnerId: '776713581655'
      PrivateDnsName: ip-10-0-128-251.us-west-2.compute.internal
      PrivateIpAddress: 10.0.128.251
      PrivateIpAddresses:
      - Primary: true
        PrivateDnsName: ip-10-0-128-251.us-west-2.compute.internal
        PrivateIpAddress: 10.0.128.251
      SourceDestCheck: true
      Status: in-use
      SubnetId: subnet-0846bcc280a088ac1
      VpcId: vpc-03524577c945523d7
    Placement:
      AvailabilityZone: us-west-2a
      GroupName: ''
      Tenancy: default
    PlatformDetails: Linux/UNIX
    PrivateDnsName: ip-10-0-128-251.us-west-2.compute.internal
    PrivateDnsNameOptions:
      EnableResourceNameDnsAAAARecord: false
      EnableResourceNameDnsARecord: false
      HostnameType: ip-name
    PrivateIpAddress: 10.0.128.251
    ProductCodes: []
    PublicDnsName: ''
    RootDeviceName: /dev/sda1
    RootDeviceType: ebs
    SecurityGroups:
    - GroupId: sg-096f51b14b10060f9
      GroupName: acit4640_assignment1_private_sg
    SourceDestCheck: true
    State:
      Code: 16
      Name: running
    StateTransitionReason: ''
    SubnetId: subnet-0846bcc280a088ac1
    Tags:
    - Key: Name
      Value: acit4640_assignment1_private_ubuntu_server
    - Key: Project
      Value: acit4640_assignment1
    UsageOperation: RunInstances
    UsageOperationUpdateTime: '2024-02-04T23:49:50+00:00'
    VirtualizationType: hvm
    VpcId: vpc-03524577c945523d7
```