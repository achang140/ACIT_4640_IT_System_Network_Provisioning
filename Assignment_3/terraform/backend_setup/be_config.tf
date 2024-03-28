# Retrieves the current AWS region where the Terraform configuration is being executed 
data "aws_region" "current" {} 

# Creates an S3 bucket for storing Terraform state files.
resource "aws_s3_bucket" "terraform_state" {
    bucket = var.bucket_name

    # Force the bucket to be destroyed when using terraform destroy (Not ideal in production)
    force_destroy = true
}

# Enables versioning for the Terraform state bucket to track changes 
resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

# Configures server-side encryption to protect data at rest in the Terraform state bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
        apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
        }
    }
}

# Configures public access settings to block public ACLs, policies, and restricts public bucket policies for the Terraform state bucket.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
    bucket                  = aws_s3_bucket.terraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# Creates a DynamoDB table to store Terraform state locking information.
# Allows mutual exclusion to prevent multiple users from modifying state at the same time.
resource "aws_dynamodb_table" "terraform_locks" {
    name         = var.dynamodb_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}

# Generates a local file containing the Terraform backend configuration
resource "local_file" "tf_backend_config" {
    content = <<EOF
terraform {
    backend "s3" {
        bucket         = "${var.bucket_name}"
        key            = "terraform.tfstate"
        dynamodb_table = "${var.dynamodb_name}"
        region         =  "${data.aws_region.current.name}" 
        encrypt        = true
    }
}
EOF
    filename = "../infra/backend_config.tf"
}