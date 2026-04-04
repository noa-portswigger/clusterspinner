variable "region" {
  description = "AWS region to deploy the cluster in."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "owner" {
  description = "Owner tag applied to all resources."
  type        = string
}
