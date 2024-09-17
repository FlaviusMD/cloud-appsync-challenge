variable "users_table_name" {
  type        = string
  description = "dynamodb Users table name."
}

variable "messages_table_name" {
  type        = string
  description = "DynamoDB Messages table name."
}

variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN to allow appsync to access dynamodb"
}


resource "aws_appsync_graphql_api" "api" {
  name                = var.appsync_api_name
  authentication_type = "API_KEY"

  log_config {
    cloudwatch_logs_role_arn = var.iam_role_arn
    field_log_level          = "ALL"
  }

  schema = file("${path.module}/schema.graphql")
}

resource "aws_appsync_api_key" "api_key" {
  api_id  = aws_appsync_graphql_api.api.id
  expires = timeadd(timestamp(), "2592000s")
}

resource "aws_appsync_datasource" "dynamodb_users" {
  api_id = aws_appsync_graphql_api.api.id
  name   = "UsersTable"
  type   = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = var.users_table_name
  }

  service_role_arn = var.iam_role_arn
}

resource "aws_appsync_datasource" "dynamodb_messages" {
  api_id = aws_appsync_graphql_api.api.id
  name   = "MessagesTable"
  type   = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = var.messages_table_name
  }

  service_role_arn = var.iam_role_arn
}

resource "aws_appsync_datasource" "none" {
  api_id = aws_appsync_graphql_api.api.id
  name   = "None"
  type   = "NONE"
}

resource "aws_appsync_function" "generate_timestamp" {
  api_id      = aws_appsync_graphql_api.api.id
  data_source = aws_appsync_datasource.none.name
  name        = "GenerateTimestamp"

  code = file("${path.module}/resolvers/generateTimestamp.js")
  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_function" "update_users_table" {
  api_id      = aws_appsync_graphql_api.api.id
  data_source = aws_appsync_datasource.dynamodb_users.name
  name        = "UpdateUsersTable"

  code = file("${path.module}/resolvers/updateUsersTable.js")
  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_function" "add_messages_table" {
  api_id      = aws_appsync_graphql_api.api.id
  data_source = aws_appsync_datasource.dynamodb_messages.name
  name        = "PutMessagesTable"

  code = file("${path.module}/resolvers/addMessagesTable.js")
  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_resolver" "add_comment" {
  api_id = aws_appsync_graphql_api.api.id
  type   = "Mutation"
  field  = "addComment"
  kind   = "PIPELINE"

  pipeline_config {
    functions = [
      aws_appsync_function.generate_timestamp.function_id,
      aws_appsync_function.update_users_table.function_id,
      aws_appsync_function.add_messages_table.function_id
    ]
  }

  code = "export function request() { return {}; } export function response(ctx) { return ctx.prev.result; }"
  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }

  depends_on = [
    aws_appsync_function.generate_timestamp,
    aws_appsync_function.update_users_table,
    aws_appsync_function.add_messages_table
  ]
}
