terraform {
  backend "s3" {
    bucket         = "rosa-environment-state"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "rosa-environment"
    encrypt        = true
  }
}
