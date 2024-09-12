resource "aws_dynamodb_table" "users" {
  name         = "Users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userUuid"

  attribute {
    name = "userUuid"
    type = "S"
  }

  tags = {
    Name = "Users Table"
  }
}

resource "aws_dynamodb_table" "messages" {
  name         = "Messages"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userUuid"
  range_key    = "messageTimestamp"

  attribute {
    name = "userUuid"
    type = "S"
  }

  attribute {
    name = "messageTimestamp"
    type = "N"
  }

  tags = {
    Name = "Messages Table"
  }
}
