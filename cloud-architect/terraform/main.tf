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

module "iam_roles" {
  source = "./modules/iam_roles"

  aws_region                  = var.aws_region
  dynamodb_users_table_arn    = module.dynamodb.users_table_arn
  dynamodb_messages_table_arn = module.dynamodb.messages_table_arn
}

module "app_sync" {
  source = "./modules/app_sync"

  users_table_name    = module.dynamodb.users_table_name
  messages_table_name = module.dynamodb.messages_table_name
  iam_role_arn        = module.iam_roles.appsync_role_arn
}
