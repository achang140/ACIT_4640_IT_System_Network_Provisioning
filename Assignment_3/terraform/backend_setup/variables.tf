variable "bucket_name" {
    description = "S3 bucket name"
    type        = string
}

variable "dynamodb_name" {
    description = "DynamoDB table name"
    type        = string
}

# Does NOT require any arguments because it automatically detects the current region based on the Terraform execution.
data "aws_region" "aws_current_region" {}