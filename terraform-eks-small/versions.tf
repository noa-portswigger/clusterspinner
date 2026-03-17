terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "noa-tf-state-658786808637-eu-west-2-an"
    key    = "terraform-eks-small/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
