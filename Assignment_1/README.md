# ACIT 4640 - Assignment 1 
By Amanda Chang (A01294905)

## Demo Video Link 
[Demo Video]()

## AWS CLI Commands 

### VPC 
```sh
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Project` && Value==`acit4640_assignment1`] && Tags[?Key==`Name` && Value==`acit4640_assignment1_vpc`]]'
```
```JSON
[
    {
        "CidrBlock": "10.0.0.0/16",
        "DhcpOptionsId": "dopt-09e444f7198473704",
        "State": "available",
        "VpcId": "vpc-03c80b029f8675dce",
        "OwnerId": "776713581655",
        "InstanceTenancy": "default",
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-00e8d820fbe5b7cd9",
                "CidrBlock": "10.0.0.0/16",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false,
        "Tags": [
            {
                "Key": "Project",
                "Value": "acit4640_assignment1"
            },
            {
                "Key": "Name",
                "Value": "acit4640_assignment1_vpc"
            }
        ]
    }
]
```

### Route Tables 

```sh
aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Key==`Name` && Value==`acit4640_assignment1_public_rt` || Value==`acit4640_assignment1_private_rt`]]'
```

```JSON
[
    // Private RT 
    {
        "Associations": [
            {
                "Main": false,
                "RouteTableAssociationId": "rtbassoc-06a220f0fc9d069a0",
                "RouteTableId": "rtb-038c427876cdbdbde",
                "SubnetId": "subnet-02855623c1a36178f",
                "AssociationState": {
                    "State": "associated"
                }
            }
        ],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-038c427876cdbdbde",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [
            {
                "Key": "Project",
                "Value": "acit4640_assignment1"
            },
            {
                "Key": "Name",
                "Value": "acit4640_assignment1_private_rt"
            }
        ],
        "VpcId": "vpc-03c80b029f8675dce",
        "OwnerId": "776713581655"
    },
    // Public RT 
    {
        "Associations": [
            {
                "Main": false,
                "RouteTableAssociationId": "rtbassoc-019f0f5b0854c9e49",
                "RouteTableId": "rtb-064764938e5679819",
                "SubnetId": "subnet-016f3bbe62b3b37df",
                "AssociationState": {
                    "State": "associated"
                }
            }
        ],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-064764938e5679819",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            },
            {
                "DestinationCidrBlock": "0.0.0.0/0",
                "GatewayId": "igw-080e969977f0fcff9",
                "Origin": "CreateRoute",
                "State": "active"
            }
        ],
        "Tags": [
            {
                "Key": "Project",
                "Value": "acit4640_assignment1"
            },
            {
                "Key": "Name",
                "Value": "acit4640_assignment1_public_rt"
            }
        ],
        "VpcId": "vpc-03c80b029f8675dce",
        "OwnerId": "776713581655"
    }
]
```

### Internet Gateway 

```sh
aws ec2 describe-internet-gateways --query "InternetGateways[?Tags[?Key=='Name' && Value=='acit4640_assignment1_igw']]"
```

```JSON
[
    {
        "Attachments": [
            {
                "State": "available",
                "VpcId": "vpc-03c80b029f8675dce"
            }
        ],
        "InternetGatewayId": "igw-080e969977f0fcff9",
        "OwnerId": "776713581655",
        "Tags": [
            {
                "Key": "Name",
                "Value": "acit4640_assignment1_igw"
            },
            {
                "Key": "Project",
                "Value": "acit4640_assignment1"
            }
        ]
    }
]
```

### Security Groups  

```sh
aws ec2 describe-security-groups --query "SecurityGroups[?Tags[?Key=='Name' && Value=='acit4640_assignment1_public_sg' || Value=='acit4640_assignment1_private_sg']]"
```

```JSON
[
    // Private Security Group 
    {
        "Description": "Allow SSH and HTTP in from within the VPC and allow all outbound traffic",
        "GroupName": "acit4640_assignment1_private_sg",
        "IpPermissions": [
            {
                "FromPort": 80,
                "IpProtocol": "tcp",
                "IpRanges": [],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "ToPort": 80,
                "UserIdGroupPairs": [
                    {
                        "Description": "Allow HTTP from within the VPC",
                        "GroupId": "sg-0b00c39dd17afa46e",
                        "UserId": "776713581655"
                    }
                ]
            },
            {
                "FromPort": 22,
                "IpProtocol": "tcp",
                "IpRanges": [],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "ToPort": 22,
                "UserIdGroupPairs": [
                    {
                        "Description": "Allow SSH from within the VPC",
                        "GroupId": "sg-0b00c39dd17afa46e",
                        "UserId": "776713581655"
                    }
                ]
            }
        ],
        "OwnerId": "776713581655",
        "GroupId": "sg-0507f9d0de8696305",
        "IpPermissionsEgress": [
            {
                "IpProtocol": "-1",
                "IpRanges": [
                    {
                        "CidrIp": "0.0.0.0/0",
                        "Description": "Allow all outbound traffic"
                    }
                ],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "UserIdGroupPairs": []
            }
        ],
        "Tags": [
            {
                "Key": "Name",
                "Value": "acit4640_assignment1_private_sg"
            },
            {
                "Key": "Project",
                "Value": "acit4640_assignment1"
            }
        ],
        "VpcId": "vpc-03c80b029f8675dce"
    },
    // // Public Security Group
    {
        "Description": "Allow SSH and HTTP in from everywhere and allow all outbound traffic",
        "GroupName": "acit4640_assignment1_public_sg",
        "IpPermissions": [
            {
                "FromPort": 80,
                "IpProtocol": "tcp",
                "IpRanges": [
                    {
                        "CidrIp": "0.0.0.0/0",
                        "Description": "Allow HTTP from everywhere"
                    }
                ],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "ToPort": 80,
                "UserIdGroupPairs": []
            },
            {
                "FromPort": 22,
                "IpProtocol": "tcp",
                "IpRanges": [
                    {
                        "CidrIp": "0.0.0.0/0",
                        "Description": "Allow SSH from everywhere"
                    }
                ],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "ToPort": 22,
                "UserIdGroupPairs": []
            }
        ],
        "OwnerId": "776713581655",
        "GroupId": "sg-0b00c39dd17afa46e",
        "IpPermissionsEgress": [
            {
                "IpProtocol": "-1",
                "IpRanges": [
                    {
                        "CidrIp": "0.0.0.0/0",
                        "Description": "Allow all outbound traffic"
                    }
                ],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "UserIdGroupPairs": []
            }
        ],
        "Tags": [
            {
                "Key": "Name",
                "Value": "acit4640_assignment1_public_sg"
            },
            {
                "Key": "Project",
                "Value": "acit4640_assignment1"
            }
        ],
        "VpcId": "vpc-03c80b029f8675dce"
    }
]
```

### EC2 Instances

```sh
aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='Name' && (Value=='acit4640_assignment1_public_ubuntu_server' || Value=='acit4640_assignment1_private_ubuntu_server')]]"
```

```JSON
[
    // Private EC2 Instance 
    [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-04eed88b1a6b28477",
            "InstanceId": "i-097b85439b4816537",
            "InstanceType": "t2.micro",
            "KeyName": "acit4640_assignment",
            "LaunchTime": "2024-02-03T03:33:18+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "us-west-2a",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-10-0-132-22.us-west-2.compute.internal",
            "PrivateIpAddress": "10.0.132.22",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 16,
                "Name": "running"
            },
            "StateTransitionReason": "",
            "SubnetId": "subnet-02855623c1a36178f",
            "VpcId": "vpc-03c80b029f8675dce",
            "Architecture": "x86_64",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/sda1",
                    "Ebs": {
                        "AttachTime": "2024-02-03T03:33:18+00:00",
                        "DeleteOnTermination": true,
                        "Status": "attached",
                        "VolumeId": "vol-0834539d31797795d"
                    }
                }
            ],
            "ClientToken": "terraform-20240203033316107900000003",
            "EbsOptimized": false,
            "EnaSupport": true,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2024-02-03T03:33:18+00:00",
                        "AttachmentId": "eni-attach-0e2263bee972f0d02",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attached",
                        "NetworkCardIndex": 0
                    },
                    "Description": "",
                    "Groups": [
                        {
                            "GroupName": "acit4640_assignment1_private_sg",
                            "GroupId": "sg-0507f9d0de8696305"
                        }
                    ],
                    "Ipv6Addresses": [],
                    "MacAddress": "02:53:c1:01:21:e1",
                    "NetworkInterfaceId": "eni-0a5c0908b9b5eddf5",
                    "OwnerId": "776713581655",
                    "PrivateDnsName": "ip-10-0-132-22.us-west-2.compute.internal",
                    "PrivateIpAddress": "10.0.132.22",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateDnsName": "ip-10-0-132-22.us-west-2.compute.internal",
                            "PrivateIpAddress": "10.0.132.22"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Status": "in-use",
                    "SubnetId": "subnet-02855623c1a36178f",
                    "VpcId": "vpc-03c80b029f8675dce",
                    "InterfaceType": "interface"
                }
            ],
            "RootDeviceName": "/dev/sda1",
            "RootDeviceType": "ebs",
            "SecurityGroups": [
                {
                    "GroupName": "acit4640_assignment1_private_sg",
                    "GroupId": "sg-0507f9d0de8696305"
                }
            ],
            "SourceDestCheck": true,
            "Tags": [
                {
                    "Key": "Project",
                    "Value": "acit4640_assignment1"
                },
                {
                    "Key": "Name",
                    "Value": "acit4640_assignment1_private_ubuntu_server"
                }
            ],
            "VirtualizationType": "hvm",
            "CpuOptions": {
                "CoreCount": 1,
                "ThreadsPerCore": 1
            },
            "CapacityReservationSpecification": {
                "CapacityReservationPreference": "open"
            },
            "HibernationOptions": {
                "Configured": false
            },
            "MetadataOptions": {
                "State": "applied",
                "HttpTokens": "optional",
                "HttpPutResponseHopLimit": 1,
                "HttpEndpoint": "enabled",
                "HttpProtocolIpv6": "disabled",
                "InstanceMetadataTags": "disabled"
            },
            "EnclaveOptions": {
                "Enabled": false
            },
            "BootMode": "uefi-preferred",
            "PlatformDetails": "Linux/UNIX",
            "UsageOperation": "RunInstances",
            "UsageOperationUpdateTime": "2024-02-03T03:33:18+00:00",
            "PrivateDnsNameOptions": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            },
            "MaintenanceOptions": {
                "AutoRecovery": "default"
            },
            "CurrentInstanceBootMode": "legacy-bios"
        }
    ],
    // Public EC2 Instance 
    [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-04eed88b1a6b28477",
            "InstanceId": "i-06a5a0b41786503f5",
            "InstanceType": "t2.micro",
            "KeyName": "acit4640_assignment",
            "LaunchTime": "2024-02-03T03:33:27+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "us-west-2a",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-10-0-0-242.us-west-2.compute.internal",
            "PrivateIpAddress": "10.0.0.242",
            "ProductCodes": [],
            "PublicDnsName": "ec2-35-91-191-156.us-west-2.compute.amazonaws.com",
            "PublicIpAddress": "35.91.191.156",
            "State": {
                "Code": 16,
                "Name": "running"
            },
            "StateTransitionReason": "",
            "SubnetId": "subnet-016f3bbe62b3b37df",
            "VpcId": "vpc-03c80b029f8675dce",
            "Architecture": "x86_64",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/sda1",
                    "Ebs": {
                        "AttachTime": "2024-02-03T03:33:27+00:00",
                        "DeleteOnTermination": true,
                        "Status": "attached",
                        "VolumeId": "vol-0eddf705a4a2d2ff4"
                    }
                }
            ],
            "ClientToken": "terraform-20240203033325501700000004",
            "EbsOptimized": false,
            "EnaSupport": true,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Association": {
                        "IpOwnerId": "amazon",
                        "PublicDnsName": "ec2-35-91-191-156.us-west-2.compute.amazonaws.com",
                        "PublicIp": "35.91.191.156"
                    },
                    "Attachment": {
                        "AttachTime": "2024-02-03T03:33:27+00:00",
                        "AttachmentId": "eni-attach-095f186b8eddc39c3",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attached",
                        "NetworkCardIndex": 0
                    },
                    "Description": "",
                    "Groups": [
                        {
                            "GroupName": "acit4640_assignment1_public_sg",
                            "GroupId": "sg-0b00c39dd17afa46e"
                        }
                    ],
                    "Ipv6Addresses": [],
                    "MacAddress": "02:ee:85:88:db:d3",
                    "NetworkInterfaceId": "eni-03bbe967fe0d64e39",
                    "OwnerId": "776713581655",
                    "PrivateDnsName": "ip-10-0-0-242.us-west-2.compute.internal",
                    "PrivateIpAddress": "10.0.0.242",
                    "PrivateIpAddresses": [
                        {
                            "Association": {
                                "IpOwnerId": "amazon",
                                "PublicDnsName": "ec2-35-91-191-156.us-west-2.compute.amazonaws.com",
                                "PublicIp": "35.91.191.156"
                            },
                            "Primary": true,
                            "PrivateDnsName": "ip-10-0-0-242.us-west-2.compute.internal",
                            "PrivateIpAddress": "10.0.0.242"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Status": "in-use",
                    "SubnetId": "subnet-016f3bbe62b3b37df",
                    "VpcId": "vpc-03c80b029f8675dce",
                    "InterfaceType": "interface"
                }
            ],
            "RootDeviceName": "/dev/sda1",
            "RootDeviceType": "ebs",
            "SecurityGroups": [
                {
                    "GroupName": "acit4640_assignment1_public_sg",
                    "GroupId": "sg-0b00c39dd17afa46e"
                }
            ],
            "SourceDestCheck": true,
            "Tags": [
                {
                    "Key": "Project",
                    "Value": "acit4640_assignment1"
                },
                {
                    "Key": "Name",
                    "Value": "acit4640_assignment1_public_ubuntu_server"
                }
            ],
            "VirtualizationType": "hvm",
            "CpuOptions": {
                "CoreCount": 1,
                "ThreadsPerCore": 1
            },
            "CapacityReservationSpecification": {
                "CapacityReservationPreference": "open"
            },
            "HibernationOptions": {
                "Configured": false
            },
            "MetadataOptions": {
                "State": "applied",
                "HttpTokens": "optional",
                "HttpPutResponseHopLimit": 1,
                "HttpEndpoint": "enabled",
                "HttpProtocolIpv6": "disabled",
                "InstanceMetadataTags": "disabled"
            },
            "EnclaveOptions": {
                "Enabled": false
            },
            "BootMode": "uefi-preferred",
            "PlatformDetails": "Linux/UNIX",
            "UsageOperation": "RunInstances",
            "UsageOperationUpdateTime": "2024-02-03T03:33:27+00:00",
            "PrivateDnsNameOptions": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            },
            "MaintenanceOptions": {
                "AutoRecovery": "default"
            },
            "CurrentInstanceBootMode": "legacy-bios"
        }
    ]
]
```