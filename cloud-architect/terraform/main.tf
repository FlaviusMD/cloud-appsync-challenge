provider "aws" {
  region = var.aws_region
}

module "backend_infra" {
  source = "./modules/backend_infra"

  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
}

module "dynamodb" {
  source = "./modules/dynamodb"
}
