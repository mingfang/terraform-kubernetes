terraform {
  backend "s3" {
    # key must be different for each step-#
    key = "step-1/terraform.tfstate"

    # everything below must be same for all steps
    bucket         = "terraform-state"
    dynamodb_table = "terraform-state"
    region         = "us-east-1"
    encrypt        = true

    shared_credentials_file = "../step-0/aws_credentials"
  }
}