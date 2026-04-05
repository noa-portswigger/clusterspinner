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

variable "zone_name" {
  description = "Name of the Route53 hosted zone to use for DNS."
  type        = string
}

variable "github_namespace" {
  description = "GitHub organisation or user under which the cluster manifests repo is hosted."
  type        = string
  default     = "noa-portswigger"
}
