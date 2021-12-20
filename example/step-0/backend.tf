# auto generated by step-0; do not edit

terraform {
  backend "s3" {
    # key must be different for each step-#
    key = "step-0/terraform.tfstate"

    # everything below must be same for all steps
    bucket         = "example123-terraform-state"
    dynamodb_table = "example123-terraform-state"
    region         = "us-east-1"
    encrypt        = true

    shared_credentials_file = "../step-0/aws_credentials"
  }
}
