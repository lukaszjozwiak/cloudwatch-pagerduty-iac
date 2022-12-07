terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default"
  # region     = "<aws_region>"
  # access_key = "<aws_access_key>"
  # secret_key = "<aws_secret_key>"
}
