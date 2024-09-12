terraform {
  backend "s3" {
    bucket         = "cloud-architect-challange-tf-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
  }
}
