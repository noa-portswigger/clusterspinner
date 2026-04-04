terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "clusterspinner-state-658786808637-eu-west-2"
    key    = "cluster-terraform/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
