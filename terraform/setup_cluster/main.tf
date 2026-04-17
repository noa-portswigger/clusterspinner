provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name, "--region", var.region]
    }
  }
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  cluster_version   = "1.35"
  vpc_cidr          = "10.0.0.0/16"
  node_instance_types = ["t3a.large"]
  node_desired_size = 3
  node_min_size     = 3
  node_max_size     = 3
  azs               = data.aws_availability_zones.available.names

  common_tags = {
    Project = var.cluster_name
    OWNER   = var.owner
    EXPIRES = "2026-04-01"
    "karpenter.sh/discovery" = var.cluster_name
  }
}
