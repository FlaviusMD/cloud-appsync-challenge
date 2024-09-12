variable "aws_region" {
  description = "AWS Region to deploy our resources to."
  default     = "eu-west-2"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store the Terraform state file."
  default     = "cloud-architect-challange-tf-state"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to store the Terraform state lock."
  default     = "terraform-lock"
}
