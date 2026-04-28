# SPDX-FileCopyrightText: 2026 The clusterspinner contributors
# SPDX-License-Identifier: MIT

variable "cluster_name" {
  type        = string
  description = "EKS cluster name, used for aws eks update-kubeconfig."
}

variable "region" {
  type        = string
  description = "AWS region the cluster runs in."
}

variable "release_name" {
  type        = string
  description = "Helm release name."
}

variable "namespace" {
  type        = string
  description = "Namespace to install the chart into. Created idempotently."
}

variable "chart" {
  type        = string
  description = "Chart reference. A chart name (paired with `repository`) or a full URL like oci://..."
}

variable "repository" {
  type        = string
  description = "Helm repository URL. Leave empty for OCI charts where `chart` is a full oci:// URL."
  default     = ""
}

variable "chart_version" {
  type        = string
  description = "Chart version to install."
}

variable "values" {
  type        = string
  description = "Helm values YAML content."
}

variable "triggers_replace" {
  type        = any
  description = "Value that, when changed, re-runs the provisioner. Typically the cluster ID for a one-shot bootstrap."
}
