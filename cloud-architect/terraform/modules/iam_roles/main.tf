variable "aws_region" {
  type        = string
  description = "AWS region."
}

variable "dynamodb_users_table_arn" {
  type        = string
  description = "ARN of dynamodb Users table appsync should access."
}

variable "dynamodb_messages_table_arn" {
  type        = string
  description = "ARN of dynamodb Messages table appsync should access."
}

resource "aws_iam_role" "appsync_role" {
  name = "AppSyncDynamoDBRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "appsync.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "appsync_dynamodb_policy" {
  role = aws_iam_role.appsync_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        "Resource" : [
          var.dynamodb_users_table_arn,
          var.dynamodb_messages_table_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "appsync_cloudwatch_logging_policy" {
  role = aws_iam_role.appsync_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Resource" : "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/appsync/apis/*"
    }]
  })
}

data "aws_caller_identity" "current" {}


output "appsync_role_arn" {
  value = aws_iam_role.appsync_role.arn
}
