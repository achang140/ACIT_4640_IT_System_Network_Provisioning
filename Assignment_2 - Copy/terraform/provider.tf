# ------------------------------------------------------------------------------------------------------------------
# Terraform Provider

# source: Location of AWS Provider
# version: Version of the provider to use; should be 5.0 or higher
# ------------------------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
  required_version = ">= 1.3.0"
}

# ------------------------------------------------------------------------------------------------------------------
# Configure the AWS Provider 

# region - Region where the AWS provider should operate (Oregon / us-west-2)
# default_tags block - Default tag that will apply to all resources created by the AWS provider
# ------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "us-west-2"

    default_tags {
        tags = {
            Project = "${var.project_name}"
        }
    }
}