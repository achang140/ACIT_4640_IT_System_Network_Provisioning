terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-west-2"
}


resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "student_info_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "studentID"

  attribute {
    name="studentID"
    type="S"
  }

}

resource "aws_dynamodb_table_item" "student_info_item" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key

  item = <<ITEM
{
  "studentID": {"S": "A01074210"},
  "student_grade": {"M": {"math_grade": {"S": "46f"}}},
  "student_name": {"S": "John Doe"}
}
ITEM
}
