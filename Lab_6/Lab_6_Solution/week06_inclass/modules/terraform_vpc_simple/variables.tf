variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name"
}


variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "192.168.0.0/16"

  # https://developer.hashicorp.com/terraform/language/expressions/custom-conditions#input-variable-validation
  #
  # Valid AWS VPC CIDR ranges:
  #  - 10.0.0.0/16 to 10.0.255.248/28
  #  - 172.16.0.0/16 to 10.16.255.248/28 (excluding 172.17.0.0/16)
  #  - 192.168.0.0/16 to 192.16.255.248/28
  #
  # References:
  #  - AWS VPC CIDR Ranges: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html
  #  - cidrhost function: https://www.terraform.io/docs/language/functions/cidrhost.html
  #  - substr function: https://www.terraform.io/docs/language/functions/substr.html
  #  - formatlist function: https://www.terraform.io/docs/language/functions/formatlist.html
  #  - join function: https://www.terraform.io/docs/language/functions/join.html
  #  - split function: https://www.terraform.io/docs/language/functions/split.html
  #  - tonumber function: https://www.terraform.io/docs/language/functions/tonumber.html

  # Verify the VPC CIDR is a valid CIDR block
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }

  # Verify the VPC CIDR has a network mask between /16 and /28
  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 28
    error_message = "VPC CIDR must have a network mask between /16 and /28."
  }

  # Verify the VPC CIDR is within the valid AWS VPC CIDR ranges
  validation {
    condition = (
      # check if starts with 10.x.x.x/8
      substr(cidrhost(var.vpc_cidr, 0), 0, 2) == "10"

      ||

      # check if starts with 172.16.x.x/12
      substr(
        # Convert each byte in ip to binary string and combine together to make binary string address
        join(
          "",
          formatlist("%8.8b", split(".", cidrhost(var.vpc_cidr, 0))) #Convert each byte to binary string
        ),
        0, #Slice starting at start of Binary Address
        12 # tonumber(split("/",var.vpc_cidr)[1]) # Slice until length of network bits
        ) == (
        substr(
          join("", formatlist("%8.8b", ["172", "16", "0", "0"])),
          0,
          12
        )
      )

      ||

      # Check starts with 192.168.x.x/16
    substr(cidrhost(var.vpc_cidr, 0), 0, 7) == "192.168")
    error_message = "VPC CIDR must in 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16"
  }

  # Verify the VPC CIDR isn't in the reserved range
  validation {
    condition     = substr(var.vpc_cidr, 0, 6) != "172.17"
    error_message = "VPC CIDR of 172.17.0.0/16 is reserved"
  }
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  default     = "192.168.1.0/24"

  # Verify the Subnet CIDR is a valid CIDR block
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid CIDR block."
  }
}

variable "default_route" {
  description = "Default route"
  default     = "0.0.0.0/0"
}

variable "home_net" {
  description = "Home network"
  default     = "142.232.0.0/16"
}

variable "bcit_net" {
  description = "BCIT network"
  default     = "142.232.0.0/16"
}
